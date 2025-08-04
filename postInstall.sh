#!/bin/bash

source config/settings.conf
source config/packages.conf

source lib/system.sh
source lib/package_manager.sh
source lib/audit.sh

for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

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

for PKG in "${INSTALL_LIST[@]}"; do
	install_package "${PKG}"
	echo -e "${RESET}"
done

p_update

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
