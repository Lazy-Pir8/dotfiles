# ⚓ Lazy-Pir8's Personal Hyprland Dotfiles

A modern, fluid, and fully customized **Hyprland** desktop environment running on Linux (Fedora 43+). Built with the new **Lua configuration architecture (`hyprland.lua`)**, dynamic theming via **Wallust**, interactive 10-workspace gesture overview via **Quickshell**, and tailored keybindings.

---

## 📁 Repository Structure

All configurations match the standard `~/.config/` hierarchy for seamless manual or automated installation:

| Folder | Target Destination | Description |
| :--- | :--- | :--- |
| **[`hypr/`](./hypr)** | `~/.config/hypr` | Hyprland compositor (Lua config `hyprland.lua`, `UserConfigs/`, `scripts/`, `animations/`, `Monitor_Profiles/`) |
| **[`waybar/`](./waybar)** | `~/.config/waybar` | Status bar configs, modular components, and custom CSS stylesheets |
| **[`rofi/`](./rofi)** | `~/.config/rofi` | Application launcher, theme selector, clipboard manager, emoji picker |
| **[`wallust/`](./wallust)** | `~/.config/wallust` | Automated color palette generator and application template definitions |
| **[`quickshell/`](./quickshell)** | `~/.config/quickshell` | Quickshell 10-workspace interactive gesture switcher (3-finger swipe) |
| **[`kitty/`](./kitty)** | `~/.config/kitty` | Kitty GPU-accelerated terminal configuration and color themes |
| **[`ghostty/`](./ghostty)** | `~/.config/ghostty` | Ghostty terminal configuration and Wallust palette synchronization |
| **[`swaync/`](./swaync)** | `~/.config/swaync` | SwayNotificationCenter notification panel and quick settings |
| **[`wlogout/`](./wlogout)** | `~/.config/wlogout` | Power menu layout and icons (Lock, Suspend, Logout, Shutdown, Reboot) |
| **[`cava/`](./cava)** | `~/.config/cava` | Audio visualizer configuration and custom shaders |
| **[`fastfetch/`](./fastfetch)** | `~/.config/fastfetch` | System info presets (including Pokemon colorscripts configuration) |
| **[`Kvantum/`](./Kvantum)** | `~/.config/Kvantum` | Qt Kvantum themes (`catppuccin-latte-blue`, `catppuccin-mocha-blue`) |
| **[`qt5ct/`](./qt5ct)** | `~/.config/qt5ct` | Qt5 theme and font configuration |
| **[`qt6ct/`](./qt6ct)** | `~/.config/qt6ct` | Qt6 theme and font configuration |
| **[`zsh/`](./zsh)** | `~/.zshrc` | Zsh shell configuration (plugins, aliases, fastfetch prompt) |

---

## 🚀 Installation & Restoration Guide

If you ever reinstall Linux or set up a new machine, you can restore your complete desktop environment in two ways:

### Method A: Automated Restore Script (Recommended)

Clone the repository and run the included installer:

```bash
git clone git@github.com:Lazy-Pir8/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
chmod +x install.sh
./install.sh
```

#### Installer Options:
- **`./install.sh`** : Symlinks all configurations into `~/.config/` (safely backs up any existing configs to `~/.config/dotfiles_backup_<timestamp>`).
- **`./install.sh --copy`** : Copies the folders directly into `~/.config/` instead of creating symlinks.
- **`./install.sh --deps`** : Automatically installs all required packages using your package manager (`dnf` on Fedora or `pacman` on Arch).
- **`./install.sh --dry-run`** : Preview the operations without making any changes.

---

### Method B: Manual Copy

If you prefer to copy the folders manually into place:

```bash
# 1. Clone repository
git clone git@github.com:Lazy-Pir8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Copy all desktop config folders into ~/.config/
mkdir -p ~/.config
cp -r hypr waybar rofi wallust quickshell kitty ghostty swaync wlogout cava fastfetch Kvantum qt5ct qt6ct ~/.config/

# 3. Copy zsh configuration
cp zsh/.zshrc ~/.zshrc

# 4. Make all scripts executable
find ~/.config/hypr/scripts ~/.config/hypr/UserScripts -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
chmod +x ~/.config/hypr/initial-boot.sh
```

---

## 📦 Required Packages

### Fedora (`dnf`)

```bash
sudo dnf install -y \
    hyprland hypridle hyprlock hyprsunset hyprpicker \
    xdg-desktop-portal-hyprland waybar rofi-wayland swww wallust \
    quickshell kitty ghostty SwayNotificationCenter wlogout cava \
    fastfetch luajit kvantum qt5ct qt6ct grim slurp swappy \
    wl-clipboard pavucontrol playerctl brightnessctl zsh
```

### Arch Linux (`pacman`)

```bash
sudo pacman -S --needed \
    hyprland hypridle hyprlock hyprsunset hyprpicker \
    xdg-desktop-portal-hyprland waybar rofi-wayland swww wallust \
    quickshell kitty ghostty swaync wlogout cava fastfetch \
    luajit kvantum qt5ct qt6ct grim slurp swappy \
    wl-clipboard pavucontrol playerctl brightnessctl zsh
```

---

## ⌨️ Essential Keybindings & Gestures

| Key Combination | Action |
| :--- | :--- |
| **Touchpad: 3-Finger Swipe Up** | Toggle Quickshell 10-Workspace Overview grid |
| **Touchpad: 3-Finger Swipe Left / Right** | Switch workspaces horizontally |
| **Touchpad: 4-Finger Swipe Up / Down** | Smooth screen zoom in / zoom out |
| **`SUPER + Return`** | Open Terminal (`kitty`) |
| **`SUPER + D`** | Open Application Launcher (`rofi`) |
| **`SUPER + E`** | Open File Manager (`thunar`) |
| **`SUPER + Q`** | Close focused window |
| **`SUPER + SPACE`** | Toggle floating mode for active window |
| **`SUPER + SHIFT + B`** | Toggle Waybar on / off |
| **`SUPER + SHIFT + Arrow`** | **Continuously resize/move window panes** (repeat on hold) |
| **`SUPER + CTRL + Arrow`** | Move window position (left / right / up / down) |
| **`SUPER + ALT + Arrow`** | Swap window position with neighbor |
| **`SUPER + 1..9`** | Switch to Workspace 1..9 |
| **`SUPER + SHIFT + 1..9`** | Move active window to Workspace 1..9 |
| **`SUPER + W`** | Open Wallpaper Selector (auto-updates Wallust palette) |
| **`SUPER + SHIFT + W`** | Wallpaper Effects Menu |
| **`SUPER + SHIFT + K`** | Searchable Keybindings Cheat Sheet (`rofi`) |
| **`SUPER + SHIFT + E`** | Quick Settings Menu |
| **`CTRL + ALT + Delete`** | Power / Logout Menu (`wlogout`) |
