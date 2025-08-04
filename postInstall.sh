#!/bin/bash

VERBOSE=false
DRY_RUN=false
ASSUME_YES=false

source config/settings.conf
source config/packages.conf

source lib/system.sh
source lib/package_manager.sh
source lib/audit.sh

for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -v|--verbose) VERBOSE=true; shift ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -y|--yes) ASSUME_YES=true; shift ;;
        -h|--help)
            echo "Usage: $0 [-v|--verbose] [-d|--dry-run] [-y|--yes] [-h|--help]"
            echo "  -v, --verbose    Enable verbose output."
            echo "  -d, --dry-run    Simulate installation without making changes."
            echo "  -y, --yes        Assume 'yes' to all prompts."
            echo "  -h, --help       Show this help message."
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

display_logo
check_sudo
run_audit

echo ""
read -p "Do you want to install the packages? [y/n]: " confirm_install
if [[ "$confirm_install" != "y" && "$confirm_install" != "Y" && "$confirm_install" != "o" && "$confirm_install" != "O" ]]; then
	echo "Installation aborted."
	exit 0
fi

echo "Select installation type:"
echo "1) Full (everything)"
echo "2) Light (minimal: PACMAN, COMPILER, TERM, NVIM DEPENDENCIES, ZSH)"
read -p "Enter your choice [1-2]: " install_type

case $install_type in
1)
	SELECTED_PKGS=("${FULL_PKGS[@]}")
	;;
2)
	SELECTED_PKGS=("${LIGHT_PKGS[@]}")
	;;
*)
	echo "Invalid choice. Exiting."
	exit 1
	;;
esac

read -p "Do you want to include EMBEDDED packages? [y/n]: " include_embedded
if [[ "$include_embedded" == "y" || "$include_embedded" == "Y" || "$include_embedded" == "o" || "$include_embedded" == "O" ]]; then
	SELECTED_PKGS+=("${PKGS_EMBEDDED[@]}")
fi

if [[ "$install_type" == "1" ]]; then
	read -p "Do you want to include LibreOffice? [y/n]: " include_libreoffice
	if [[ "$include_libreoffice" == "y" || "$include_libreoffice" == "Y" ]]; then
		SELECTED_PKGS+=("${PKGS_OFFICE[@]}")
	fi
fi

INSTALL_LIST=()
for pkg in "${SELECTED_PKGS[@]}"; do
	if [[ ! $pkg == "#"* ]]; then
		INSTALL_LIST+=("$pkg")
	fi
done

if ! show_installation_summary "${INSTALL_LIST[@]}"; then
    log "WARNING" "Installation aborted by user."
    exit 0
fi

log "INFO" "Starting package installation..."
p_update

local total=${#INSTALL_LIST[@]}
local current=0

for PKG in "${INSTALL_LIST[@]}"; do
    current=$((current + 1))
    if [[ "$VERBOSE" != "true" ]]; then
        show_progress "$current" "$total" "$PKG"
    fi
    install_package "${PKG}"
done

# Terminer la ligne de la barre de progression
if [[ "$VERBOSE" != "true" ]]; then
    echo
fi
log "SUCCESS" "Package installation phase complete."

# INSTALL SPECIFIC PACKAGES
install_git
install_fonts
install_nvim
install_veracrypt
install_docker
install_node
install_zsh
install_zconfig

case "$DESKTOP" in
    kde)      setup_kde ;;
    gnome)    setup_gnome ;;
    xfce)     setup_xfce ;;
    lxde)     setup_lxde ;;
    lxqt)     setup_lxqt ;;
    mate)     setup_mate ;;
    cinnamon) setup_cinnamon ;;
    *) echo -e "${YELLOW}No specific desktop configuration for '$DESKTOP'.${RESET}" ;;
esac

setup_vlc
# set-bin
create_ssh_key

p_update
p_clean


echo -e "${GREENHI}✅ Post-installation script finished! Please reboot your system for all changes to take effect.${RESET}"
# A AJOUTER
# icon fix
# driver nvidia sudo apt install nvidia-driver-550
# raccourcis
# tableau de bord
# pipx install compiledb
# ledger live
# ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
