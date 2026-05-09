# dotfiles

Ansible-based dotfiles for Arch Linux + Hyprland + Nvidia.

## Fresh Install

### 1. Base Arch install

Use `archinstall` with:
- Filesystem: ext4 (or btrfs)
- Swap: 8GB partition
- Desktop: none (minimal)
- Network: NetworkManager

### 2. Install 1Password CLI

```bash
sudo pacman -S 1password-cli
```

### 3. Sign in to 1Password

```bash
op signin
```

Required vaults: `api_keys`, `MCB`.

### 4. Run bootstrap

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/janniksinz/dotfiles/main/bin/dotfiles) \
  -e '{"exclude_roles": ["nvidia","swap","sddm"]}'
```

The bootstrap script will:
- Install Ansible, yay, and dependencies
- Configure sudoers (OP token passthrough, `pacman` NOPASSWD for AUR builds)
- Install Ansible Galaxy collections
- Clone this repo to `~/.dotfiles`
- Run the full playbook

Nvidia, swap, and sddm are excluded on the first run — they require a reboot with the full system in place.

### 5. Reboot

```bash
reboot
```

### 6. Run remaining roles

```bash
~/.dotfiles/bin/dotfiles
```

This runs the full playbook including nvidia, swap, and sddm.

### 7. Reboot again

Required for nvidia kernel modules and sddm to take effect.

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

## Notes

- If upgrading from a system with `hyprland-git` / `hyprutils-git` etc., remove them first:
  ```bash
  sudo pacman -Rdd hyprutils-git hyprlang-git hyprgraphics-git hyprwayland-scanner-git
  sudo pacman -Syu
  ```
- 1Password GUI must be installed separately (not managed by ansible)
- `op signin` must be run before every fresh bootstrap (session expires)
