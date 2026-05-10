# dotfiles

Ansible-based dotfiles for Arch Linux + Hyprland + Nvidia.

## Fresh Install

### 1. Base Arch install

Use `archinstall` with:
- Filesystem: ext4 (or btrfs)
- Swap: 8GB partition
- Desktop: Hyprland (minimal)
- Network: NetworkManager

### 2. Pre-setup (no secrets needed)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/janniksinz/dotfiles/main/bin/dotfiles) --bootstrap
```

This installs and configures the auth dependency chain:
- **gnome-keyring** — OS keyring with PAM auto-unlock and Hyprland session integration
- **Brave browser** — needed to sign into 1Password
- **1Password** (GUI + CLI) — secret management for the main playbook
- **yay** — AUR helper for package installation
- Sudoers configuration for the main playbook

### 3. Sign into 1Password

Reboot so gnome-keyring auto-unlocks via SDDM, then:
1. Open Brave browser
2. Sign into 1Password (browser or GUI app)
3. Authenticate the CLI:

```bash
op signin
```

Required vaults: `api_keys`, `MCB`.

### 4. Run full setup

```bash
~/.dotfiles/bin/dotfiles -e '{"exclude_roles": ["nvidia","swap","sddm"]}'
```

Nvidia, swap, and sddm are excluded on the first run — they require a reboot.

### 5. Run remaining roles

After reboot:

```bash
~/.dotfiles/bin/dotfiles
```

This runs the full playbook including nvidia, swap, and sddm. Reboot again for nvidia kernel modules and sddm to take effect.

---

## Existing system / re-run

```bash
~/.dotfiles/bin/dotfiles
```

To exclude specific roles:

```bash
~/.dotfiles/bin/dotfiles -e '{"exclude_roles": ["nvidia","swap"]}'
```

## Uninstall a role

```bash
~/.dotfiles/bin/dotfiles --uninstall <role>
```

## Customization

Edit `group_vars/all.yml` to enable/disable roles or change settings.

## Verification

### Keyring + Brave

After logging in via SDDM, verify Brave is using gnome-keyring:

```bash
secret-tool search --all xdg:schema chrome_libsecret_os_crypt_password_v2
```

You should see `label = Brave Safe Storage` with a secret value. If missing, Brave is not using the OS keyring.

Full keyring health check:

```bash
# gnome-keyring-daemon running?
pgrep -x gnome-keyring-d

# Login keyring exists?
ls ~/.local/share/keyrings/login.keyring

# D-Bus session available?
echo $DBUS_SESSION_BUS_ADDRESS

# Store and retrieve a test secret
secret-tool store --label="test" test-key test-val <<< "hello"
secret-tool lookup test-key test-val
secret-tool clear test-key test-val
```

## Notes

- If upgrading from a system with `hyprland-git` / `hyprutils-git` etc., remove them first:
  ```bash
  sudo pacman -Rdd hyprutils-git hyprlang-git hyprgraphics-git hyprwayland-scanner-git
  sudo pacman -Syu
  ```
- `op signin` must be run before every fresh run (session expires)
