#!/bin/bash

source postList
source postFunctions.sh

display_logo
check_sudo

run_audit

# Prompt user for installation type
echo "Select installation type:"
echo "1) Full (everything)"
echo "2) Light (minimal: PACMAN, COMPILER, TERM, NVIM DEPENDENCIES, ZSH)"
read -p "Enter your choice [1-2]: " install_type

case $install_type in
	1)
		SELECTED_PKGS=("${FULL_PKGS[@]}")
		read -p "Do you want to include EMBEDDED packages? [y/n]: " include_embedded
		if [[ "$include_embedded" == "y" || "$include_embedded" == "Y" ]]; then
			SELECTED_PKGS+=("${EMBEDDED_PKGS[@]}")
		fi
		read -p "Do you want to include LibreOffice? [y/n]: " include_libreoffice
		if [[ "$include_libreoffice" == "y" || "$include_libreoffice" == "Y" ]]; then
			SELECTED_PKGS+=("${OPTIONAL_PKGS[@]}")
		fi
		;;
	2)
		SELECTED_PKGS=("${LIGHT_PKGS[@]}")
		read -p "Do you want to include EMBEDDED packages? [y/n]: " include_embedded
		if [[ "$include_embedded" == "y" || "$include_embedded" == "Y" ]]; then
			SELECTED_PKGS+=("${EMBEDDED_PKGS[@]}")
		fi
		;;
	*)
		echo "Invalid choice. Exiting."
		exit 1
		;;
esac

# INSTALL PACKAGES

p_update

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

# INSTALL SPEC

install_git

install_nvim

install_veracrypt

install_fonts

# CLEANING

p_clean

# INSTALL OH MY ZSH

install_zsh

# INSTALL ZSH CONFIG

install_zconfig

p_update

# INSTALL DESKTOP CONFIG
if [[ "$DESKTOP" == "kde" ]]; then
	setup_kde
	install_docker_ubuntu
elif [[ "$DESKTOP" == "gnome" ]]; then
	setup_gnome
elif [[ "$DESKTOP" == "xfce" ]]; then
	setup_xfce
elif [[ "$DESKTOP" == "lxde" ]]; then
	setup_lxde
elif [[ "$DESKTOP" == "lxqt" ]]; then
	setup_lxqt
elif [[ "$DESKTOP" == "mate" ]]; then
	setup_mate
elif [[ "$DESKTOP" == "cinnamon" ]]; then
	setup_cinnamon
fi

setup_vlc

# set-bin

create_ssh_key
install_node

p_update
p_clean

# A AJOUTER
# icon fix
# driver nvidia sudo apt install nvidia-driver-550
# raccourcis
# tableau de bord
# pipx install compiledb
# ledger live
# ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
