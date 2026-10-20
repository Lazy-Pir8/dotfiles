#!/usr/bin/env bash
# ==============================================================================
#  Lazy-Pir8 Dotfiles Installer & Restore Script
#  Repository: https://github.com/Lazy-Pir8/dotfiles
# ==============================================================================

set -euo pipefail

# Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_CYAN="\033[36m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

MODE="symlink"  # or "copy"
DRY_RUN=false
INSTALL_DEPS=false

usage() {
    cat <<EOF
${C_BOLD}Usage:${C_RESET} ./install.sh [OPTIONS]

${C_BOLD}Options:${C_RESET}
  -s, --symlink      Symlink configuration folders into ~/.config (default)
  -c, --copy         Copy configuration folders into ~/.config instead of symlinking
  -d, --deps         Install recommended packages for detected distribution
  -n, --dry-run      Print operations without making any filesystem changes
  -h, --help         Show this help message

${C_BOLD}Managed configurations:${C_RESET}
  hypr, waybar, rofi, wallust, quickshell, kitty, ghostty,
  swaync, wlogout, cava, fastfetch, Kvantum, qt5ct, qt6ct, zsh (.zshrc)
EOF
}

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--symlink) MODE="symlink"; shift ;;
        -c|--copy)    MODE="copy"; shift ;;
        -d|--deps)    INSTALL_DEPS=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            echo -e "${C_RED}Unknown option: $1${C_RESET}"; usage; exit 1 ;;
    esac
done

echo -e "${C_CYAN}${C_BOLD}====================================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}      Lazy-Pir8 Hyprland Dotfiles Setup             ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}====================================================${C_RESET}"
echo -e "Mode:        ${C_BOLD}${MODE}${C_RESET}"
echo -e "Source:      ${DOTFILES_DIR}"
echo -e "Destination: ${CONFIG_DIR}"
echo ""

# Detect Linux Distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

DISTRO="$(detect_distro)"

install_dependencies() {
    echo -e "${C_BLUE}--> Checking dependencies for ${C_BOLD}${DISTRO}${C_RESET}..."
    case "$DISTRO" in
        fedora)
            echo -e "Installing core dependencies via ${C_BOLD}dnf${C_RESET}..."
            sudo dnf install -y \
                hyprland hypridle hyprlock hyprsunset hyprpicker \
                xdg-desktop-portal-hyprland waybar rofi-wayland swww wallust \
                quickshell kitty ghostty SwayNotificationCenter wlogout cava \
                fastfetch luajit kvantum qt5ct qt6ct grim slurp swappy \
                wl-clipboard pavucontrol playerctl brightnessctl \
                zsh util-linux-user || true
            ;;
        arch|manjaro|endeavouros)
            echo -e "Installing core dependencies via ${C_BOLD}pacman${C_RESET}..."
            sudo pacman -S --needed --noconfirm \
                hyprland hypridle hyprlock hyprsunset hyprpicker \
                xdg-desktop-portal-hyprland waybar rofi-wayland swww wallust \
                quickshell kitty ghostty swaync wlogout cava fastfetch \
                luajit kvantum qt5ct qt6ct grim slurp swappy wl-clipboard \
                tesseract pavucontrol playerctl brightnessctl zsh || true
            ;;
        *)
            echo -e "${C_YELLOW}Auto-installation is not tailored for distro '${DISTRO}'.${C_RESET}"
            echo -e "Please ensure hyprland, waybar, rofi-wayland, swww, wallust, quickshell, etc. are installed."
            ;;
    esac
}

if [[ "$INSTALL_DEPS" == true ]]; then
    install_dependencies
fi

# List of folders to manage in ~/.config
CONFIG_FOLDERS=(
    "hypr"
    "waybar"
    "rofi"
    "wallust"
    "quickshell"
    "kitty"
    "ghostty"
    "swaync"
    "wlogout"
    "cava"
    "fastfetch"
    "Kvantum"
    "qt5ct"
    "qt6ct"
)

mkdir -p "$CONFIG_DIR"

backup_target() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${C_YELLOW}[DRY-RUN] Would backup:${C_RESET} $target -> $BACKUP_DIR/$(basename "$target")"
        else
            mkdir -p "$BACKUP_DIR"
            echo -e "  ${C_YELLOW}Backing up:${C_RESET} $target -> $BACKUP_DIR/"
            mv "$target" "$BACKUP_DIR/"
        fi
    fi
}

echo -e "${C_BLUE}--> Deploying configuration folders...${C_RESET}"
for folder in "${CONFIG_FOLDERS[@]}"; do
    src="$DOTFILES_DIR/$folder"
    dest="$CONFIG_DIR/$folder"

    if [[ ! -d "$src" ]]; then
        echo -e "${C_YELLOW}Skipping missing source folder:${C_RESET} $folder"
        continue
    fi

    backup_target "$dest"

    if [[ "$MODE" == "symlink" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${C_GREEN}[DRY-RUN] Symlink:${C_RESET} $dest -> $src"
        else
            ln -sfn "$src" "$dest"
            echo -e "  ${C_GREEN}Symlinked:${C_RESET} $folder -> $dest"
        fi
    else
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${C_GREEN}[DRY-RUN] Copy:${C_RESET} $src -> $dest"
        else
            cp -r "$src" "$dest"
            echo -e "  ${C_GREEN}Copied:${C_RESET} $folder -> $dest"
        fi
    fi
done

# Deploy ~/.zshrc
if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
    zsh_dest="$HOME/.zshrc"
    backup_target "$zsh_dest"
    if [[ "$MODE" == "symlink" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${C_GREEN}[DRY-RUN] Symlink:${C_RESET} $zsh_dest -> $DOTFILES_DIR/zsh/.zshrc"
        else
            ln -sfn "$DOTFILES_DIR/zsh/.zshrc" "$zsh_dest"
            echo -e "  ${C_GREEN}Symlinked:${C_RESET} .zshrc -> $zsh_dest"
        fi
    else
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${C_GREEN}[DRY-RUN] Copy:${C_RESET} $DOTFILES_DIR/zsh/.zshrc -> $zsh_dest"
        else
            cp "$DOTFILES_DIR/zsh/.zshrc" "$zsh_dest"
            echo -e "  ${C_GREEN}Copied:${C_RESET} .zshrc -> $zsh_dest"
        fi
    fi
fi

# Fix executable permissions on all shell scripts
if [[ "$DRY_RUN" == false ]]; then
    echo -e "${C_BLUE}--> Ensuring executable permissions on scripts...${C_RESET}"
    if [[ -d "$CONFIG_DIR/hypr/scripts" ]]; then
        find "$CONFIG_DIR/hypr/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
    fi
    if [[ -d "$CONFIG_DIR/hypr/UserScripts" ]]; then
        find "$CONFIG_DIR/hypr/UserScripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
    fi
    if [[ -f "$CONFIG_DIR/hypr/initial-boot.sh" ]]; then
        chmod +x "$CONFIG_DIR/hypr/initial-boot.sh"
    fi
fi

# Ensure relative internal symlinks are intact
if [[ "$DRY_RUN" == false ]]; then
    echo -e "${C_BLUE}--> Verifying internal symlinks...${C_RESET}"
    # Wallust templates link
    mkdir -p "$CONFIG_DIR/hypr/wallust"
    ln -sf "../../wallust/templates" "$CONFIG_DIR/hypr/wallust/templates" 2>/dev/null || true
    ln -sf "../../wallust/wallust.toml" "$CONFIG_DIR/hypr/wallust/wallust.toml" 2>/dev/null || true

    # Waybar relative link
    mkdir -p "$CONFIG_DIR/waybar"
    ln -sf "../hypr/waybar/config" "$CONFIG_DIR/waybar/config" 2>/dev/null || true
    ln -sf "../hypr/waybar/style.css" "$CONFIG_DIR/waybar/style.css" 2>/dev/null || true
fi

echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Dotfiles deployment completed successfully!${C_RESET}"
if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${C_YELLOW}Existing configs were safely backed up to: ${BACKUP_DIR}${C_RESET}"
fi
echo ""
echo -e "${C_BOLD}Next steps:${C_RESET}"
echo -e "  1. If Hyprland is currently running, run: ${C_CYAN}hyprctl reload${C_RESET}"
echo -e "  2. Or start Hyprland via your display manager or login terminal."
echo -e "  3. To refresh palettes and wallpapers, press ${C_CYAN}SUPER + W${C_RESET} and select a wallpaper."

