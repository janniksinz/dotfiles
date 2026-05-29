DaVinci Resolve on Arch Linux + Hyprland — Ansible Integration Guide
Based on your successful installation, here's a step-by-step breakdown for your playbook:
Prerequisites Your System Had

GPU: NVIDIA with nvidia-open-dkms and nvidia-utils already installed
Display: Hyprland (Wayland) with XWayland available
AUR helper: yay installed
Disk space: Sufficient /home (1.5TB+), small /root (49GB)


Step-by-Step Installation Flow
1. Install GPU drivers and OpenCL
bashpacman -S nvidia-open-dkms nvidia-utils opencl-nvidia cuda
2. Install yay (AUR helper) if not present
bashpacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
3. Configure yay to build in /home (avoids /root space issues)
bashyay --builddir ~/builds --save
4. Fix gobject-introspection Python module path issue
This is critical — without this, gtk2 build fails:
bashsudo ln -s /usr/lib/gobject-introspection/giscanner /usr/lib/python3.14/giscanner
5. Install AUR dependencies
bashyay --builddir ~/builds -S libpng12 gtk2 qt5-websockets qt5-webengine
6. Manually download DaVinci Resolve
⚠️ This step cannot be fully automated — Blackmagic requires account registration:

Go to: https://www.blackmagicdesign.com/products/davinciresolve
Register/log in
Download Linux ZIP (e.g., DaVinci_Resolve_20.3.2_Linux.zip)
Place in: ~/Downloads/

7. Place ZIP in yay cache and build
bashcp ~/Downloads/DaVinci_Resolve_20.3.2_Linux.zip ~/builds/davinci-resolve/DaVinci_Resolve_20.3.2_Linux.zip
yay --builddir ~/builds -S davinci-resolve --mflags "--skipchecksums"
8. Handle /opt mount (if /root is small)
If df -h / shows <3GB free:
bashsudo mkdir -p /home/.opt
sudo cp -a /opt/. /home/.opt/
sudo rm -rf /opt
sudo mkdir /opt
echo '/home/.opt /opt none bind 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount --bind /home/.opt /opt
9. Configure for XWayland on Hyprland
Edit the desktop entry to force X11 rendering:
bashsudo nano /usr/share/applications/com.blackmagicdesign.resolve.desktop
Replace Exec= line with:
Exec=env QT_QPA_PLATFORM=xcb /opt/resolve/bin/resolve %u

Ansible Playbook Template
Here's how to integrate this into your dotfiles:
yaml---
- name: Install DaVinci Resolve on Arch Linux + Hyprland
  hosts: localhost
  vars:
    resolve_version: "20.3.2"
    builds_dir: "{{ ansible_env.HOME }}/builds"
    downloads_dir: "{{ ansible_env.HOME }}/Downloads"
  
  tasks:
    - name: Install GPU drivers and OpenCL
      community.general.pacman:
        name:
          - nvidia-open-dkms
          - nvidia-utils
          - opencl-nvidia
          - cuda
        state: present
      become: yes
    
    - name: Install yay if not present
      block:
        - name: Check if yay exists
          stat:
            path: /usr/bin/yay
          register: yay_check
        
        - name: Clone yay repository
          git:
            repo: https://aur.archlinux.org/yay.git
            dest: /tmp/yay
          when: not yay_check.stat.exists
        
        - name: Build and install yay
          shell: cd /tmp/yay && makepkg -si --noconfirm
          when: not yay_check.stat.exists
    
    - name: Create yay build directory in /home
      file:
        path: "{{ builds_dir }}"
        state: directory
        mode: '0755'
    
    - name: Configure yay to use /home for builds
      shell: yay --builddir {{ builds_dir }} --save
    
    - name: Fix gobject-introspection symlink
      block:
        - name: Check Python version
          shell: python3 --version | grep -oP '(?<=Python )\d+\.\d+'
          register: python_version
          changed_when: false
        
        - name: Create giscanner symlink
          file:
            src: /usr/lib/gobject-introspection/giscanner
            dest: "/usr/lib/python{{ python_version.stdout }}/giscanner"
            state: link
          become: yes
          ignore_errors: yes
    
    - name: Install AUR dependencies
      shell: yay --builddir {{ builds_dir }} -S libpng12 gtk2 qt5-websockets qt5-webengine --noconfirm
      environment:
        TERM: xterm
    
    - name: Check if DaVinci Resolve ZIP exists
      stat:
        path: "{{ downloads_dir }}/DaVinci_Resolve_{{ resolve_version }}_Linux.zip"
      register: resolve_zip
    
    - name: Alert user to download DaVinci Resolve manually
      debug:
        msg: |
          DaVinci Resolve ZIP not found at {{ downloads_dir }}/DaVinci_Resolve_{{ resolve_version }}_Linux.zip
          
          Please download manually from:
          https://www.blackmagicdesign.com/products/davinciresolve
          
          Place the downloaded file at: {{ downloads_dir }}/DaVinci_Resolve_{{ resolve_version }}_Linux.zip
          
          Then re-run this playbook.
      when: not resolve_zip.stat.exists
      failed_when: not resolve_zip.stat.exists
    
    - name: Copy Resolve ZIP to yay cache
      copy:
        src: "{{ downloads_dir }}/DaVinci_Resolve_{{ resolve_version }}_Linux.zip"
        dest: "{{ builds_dir }}/davinci-resolve/DaVinci_Resolve_{{ resolve_version }}_Linux.zip"
        remote_src: yes
      when: resolve_zip.stat.exists
    
    - name: Build davinci-resolve from AUR
      shell: yay --builddir {{ builds_dir }} -S davinci-resolve --mflags "--skipchecksums" --noconfirm
      environment:
        TERM: xterm
      when: resolve_zip.stat.exists
    
    - name: Check root partition free space
      shell: df / | tail -1 | awk '{print $4}'
      register: root_free_kb
      changed_when: false
    
    - name: Handle small /root partition with /home bind mount
      block:
        - name: Create /home/.opt directory
          file:
            path: /home/.opt
            state: directory
            mode: '0755'
          become: yes
        
        - name: Backup and copy /opt contents
          shell: |
            mkdir -p /home/.opt
            cp -a /opt/. /home/.opt/ 2>/dev/null || true
            rm -rf /opt
            mkdir /opt
          become: yes
        
        - name: Add /opt bind mount to fstab
          lineinfile:
            path: /etc/fstab
            line: '/home/.opt /opt none bind 0 0'
            state: present
          become: yes
        
        - name: Reload systemd and mount /opt
          shell: |
            systemctl daemon-reload
            mount --bind /home/.opt /opt
          become: yes
      when: root_free_kb.stdout | int < 3145728  # 3GB in KB
    
    - name: Configure Resolve desktop entry for XWayland on Hyprland
      lineinfile:
        path: /usr/share/applications/com.blackmagicdesign.resolve.desktop
        regexp: '^Exec='
        line: 'Exec=env QT_QPA_PLATFORM=xcb /opt/resolve/bin/resolve %u'
      become: yes
    
    - name: Verify DaVinci Resolve installation
      shell: /opt/resolve/bin/resolve --version
      register: resolve_version_check
      ignore_errors: yes
    
    - name: Report installation status
      debug:
        msg: |
          DaVinci Resolve installation complete!
          Version: {{ resolve_version_check.stdout | default('Could not verify') }}
          
          Launch with:
          env QT_QPA_PLATFORM=xcb /opt/resolve/bin/resolve
          
          Or find it in your application menu.

Important Notes for Your Playbook

Manual Download Step: The ZIP download cannot be automated due to Blackmagic's registration requirement. Your playbook will check for it and fail with instructions if missing.
Alternative Approach — Pre-download and host:

yaml   - name: Download Resolve from custom host
     get_url:
       url: "https://your-mirror.example.com/DaVinci_Resolve_{{ resolve_version }}_Linux.zip"
       dest: "{{ downloads_dir }}/"
     when: you have your own download server

Environment Variables: Your environment is already correct (Wayland + XWayland), so the QT_QPA_PLATFORM=xcb flag is all that's needed.
Idempotency: The playbook can be re-run safely; most tasks have ignore_errors: yes where appropriate.
Python Version: The gobject-introspection symlink dynamically detects your Python version, so it works across upgrades.