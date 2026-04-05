#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Hanabie Plasma Theme — Install Script
# Installs the full theme system-wide on Arch Linux + KDE Plasma 6
# Usage: sudo ./install.sh
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install destinations
LNF_DIR="/usr/share/plasma/look-and-feel"
PLASMA_THEME_DIR="/usr/share/plasma/desktoptheme"
AURORAE_DIR="/usr/share/aurorae/themes"
ICON_DIR="/usr/share/icons"
COLOR_DIR="/usr/share/color-schemes"
WALLPAPER_DIR="/usr/share/wallpapers/hanabie"
SDDM_THEME_DIR="/usr/share/sddm/themes"
SDDM_CONF_DIR="/etc/sddm.conf.d"

# =============================================================================
# Helpers
# =============================================================================

info()    { echo -e "${CYAN}==> ${NC}$*"; }
success() { echo -e "${GREEN} ✓  ${NC}$*"; }
warn()    { echo -e "${YELLOW}[!] ${NC}$*"; }
die()     { echo -e "${RED}[✗] $*${NC}" >&2; exit 1; }

check_root() {
    [[ $EUID -eq 0 ]] || die "Run with sudo: sudo ./install.sh"
}

check_deps() {
    info "Checking dependencies..."
    local required=(plasma-desktop sddm kpackage papirus-icon-theme kvantum noto-fonts)
    local missing=()

    for pkg in "${required[@]}"; do
        pacman -Q "$pkg" &>/dev/null || missing+=("$pkg")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Missing packages: ${missing[*]}"
        read -rp "Install them now with pacman? [Y/n] " inst
        if [[ "${inst,,}" != "n" ]]; then
            pacman -S --noconfirm "${missing[@]}" || die "Failed to install dependencies"
        else
            read -rp "Continue without installing? [y/N] " cont
            [[ "${cont,,}" == "y" ]] || exit 1
        fi
    else
        success "All dependencies found"
    fi
}

# =============================================================================
# Install steps
# =============================================================================

install_lookandfeel() {
    info "Installing Look-and-Feel package (org.ookami.hanabie)..."
    install -d "$LNF_DIR/org.ookami.hanabie"
    cp -r "$SCRIPT_DIR/org.ookami.hanabie/." "$LNF_DIR/org.ookami.hanabie/"

    # Fix wallpaper path to absolute installed location
    sed -i "s|Image=hanabie-galaxy.jpg|Image=$WALLPAPER_DIR/hanabie-galaxy.jpg|" \
        "$LNF_DIR/org.ookami.hanabie/contents/kdeglobals"

    success "Look-and-Feel package installed"
}

install_splash() {
    info "Installing BeautifulTreeAnimation splash screen..."
    install -d "$LNF_DIR/BeautifulTreeAnimation"
    cp -r "$SCRIPT_DIR/BeautifulTreeAnimation/." "$LNF_DIR/BeautifulTreeAnimation/"
    success "Splash screen installed"
}

install_wallpapers() {
    info "Installing wallpapers..."
    install -d "$WALLPAPER_DIR"
    cp "$SCRIPT_DIR/org.ookami.hanabie/contents/wallpapers/"*.jpg "$WALLPAPER_DIR/"
    success "Wallpapers installed to $WALLPAPER_DIR"
}

install_plasma_theme() {
    info "Installing Plasma shell theme (Hanabie)..."
    install -d "$PLASMA_THEME_DIR/Hanabie"
    cp -r "$SCRIPT_DIR/org.ookami.hanabie/contents/plasmatheme/." "$PLASMA_THEME_DIR/Hanabie/"
    success "Plasma shell theme installed"
}

install_decoration() {
    info "Installing Aurorae window decoration (Hanabie)..."
    install -d "$AURORAE_DIR/Hanabie"
    cp -r "$SCRIPT_DIR/org.ookami.hanabie/contents/windowdecoration/Hanabie/." \
        "$AURORAE_DIR/Hanabie/"
    success "Window decoration installed"
}

install_icons() {
    info "Installing icon theme (HanabieNeonIcons)..."
    install -d "$ICON_DIR/HanabieNeonIcons"
    cp -r "$SCRIPT_DIR/org.ookami.hanabie/contents/icons/HanabieNeonIcons/." \
        "$ICON_DIR/HanabieNeonIcons/"
    gtk-update-icon-cache -f -t "$ICON_DIR/HanabieNeonIcons" 2>/dev/null || true
    success "Icon theme installed"
}

install_colors() {
    info "Installing color scheme (HanabieColors)..."
    install -d "$COLOR_DIR"
    cp "$SCRIPT_DIR/org.ookami.hanabie/contents/colors/HanabieColors.colors" "$COLOR_DIR/"
    success "Color scheme installed"
}

install_sddm() {
    info "Installing SDDM theme (eucalyptus-drop)..."

    if [[ -d "$SDDM_THEME_DIR/eucalyptus-drop" ]]; then
        warn "eucalyptus-drop already exists at $SDDM_THEME_DIR/eucalyptus-drop"
        read -rp "Overwrite? [y/N] " ow
        [[ "${ow,,}" == "y" ]] || { warn "Skipping SDDM theme install."; return; }
        rm -rf "$SDDM_THEME_DIR/eucalyptus-drop"
    fi

    install -d "$SDDM_THEME_DIR/eucalyptus-drop"
    cp -r "$SCRIPT_DIR/org.ookami.hanabie/contents/loginmanager/eucalyptus-drop/." \
        "$SDDM_THEME_DIR/eucalyptus-drop/"

    # Configure SDDM to use this theme
    install -d "$SDDM_CONF_DIR"
    cat > "$SDDM_CONF_DIR/hanabie-theme.conf" <<EOF
[Theme]
Current=eucalyptus-drop
EOF

    success "SDDM theme installed and configured"
}

apply_theme() {
    # plasma-apply-lookandfeel must run as the real user, not root
    local real_user="${SUDO_USER:-}"

    if [[ -z "$real_user" ]]; then
        warn "Could not detect invoking user — skipping auto-apply."
        warn "Apply manually: plasma-apply-lookandfeel -a org.ookami.hanabie"
        return
    fi

    info "Applying Look-and-Feel theme as $real_user..."
    if sudo -u "$real_user" plasma-apply-lookandfeel -a org.ookami.hanabie 2>/dev/null; then
        success "Theme applied"
    else
        warn "Auto-apply failed. Run manually after logging in:"
        warn "  plasma-apply-lookandfeel -a org.ookami.hanabie"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${GREEN}  Hanabie Plasma Theme — Installer${NC}"
    echo -e "  KDE Plasma 6 / Arch Linux"
    echo ""

    check_root
    check_deps

    install_wallpapers
    install_lookandfeel
    install_splash
    install_plasma_theme
    install_decoration
    install_icons
    install_colors
    install_sddm
    apply_theme

    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "Post-install steps:"
    echo "  1. Log out and back in (or restart plasmashell: kquitapp6 plasmashell && kstart plasmashell)"
    echo "  2. Window decoration: System Settings > Appearance > Window Decorations > Hanabie"
    echo "  3. Active window glow: System Settings > Workspace > Desktop Effects > enable 'Window Outline'"
    echo "     Set the outline color to #ff80e0 to match the theme"
    echo "  4. Kvantum: open Kvantum Manager and select a dark Kvantum theme for app styling"
    echo "  5. SDDM change takes effect on next logout/reboot"
    echo ""
}

main "$@"
