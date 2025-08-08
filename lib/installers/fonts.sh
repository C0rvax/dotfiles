#!/bin/bash

function install_fonts {
	local dotfiles_dir
	dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin vers la racine du dépôt
	local themes_dir="$dotfiles_dir/home/themes"
	local fonts_source_dir="$themes_dir/fonts"
	local icons_source_dir="$themes_dir/icons/$BUUF_ICONS_NAME"
	

	#local sys_fonts_dir="/usr/share/fonts/truetype/custom"
	#local icons_dest_dir="/usr/share/icons/$BUUF_ICONS_NAME"
	local fonts_dest_dir="$HOME/.local/share/fonts"
	local icons_dest_dir="$HOME/.local/share/icons"
	local icons_dest="$HOME/.local/share/icons/$BUUF_ICONS_NAME"


	local exit_code=0
	if [[ "$DRY_RUN" == "true" ]]; then
		log "INFO" "[DRY-RUN] Would install custom fonts and icons."
		log "INFO" "MesloLGS NF fonts would be copied to '$fonts_dest_dir'."
		log "INFO" "Buuf Nestort icons would be cloned to '$icons_dest_dir'."
		return exit_code
	fi

	if [ -s "$fonts_dest_dir/MesloLGS NF Regular.ttf" ]; then
		log "INFO" "Fonts seem to be already installed."
	else
		if [ ! -d "$fonts_source_dir" ] || [ -z "$(ls -A $fonts_source_dir/*.ttf 2>/dev/null)" ]; then
			log "ERROR" "Font source directory '$fonts_source_dir' is empty or does not exist."
			exit_code=1
		else
			mkdir -p "$fonts_dest_dir"
			cp "$fonts_source_dir"/*.ttf "$fonts_dest_dir/" >>${LOG_FILE} 2>&1
			fc-cache -fv "$fonts_dest_dir" >>${LOG_FILE} 2>&1
		fi
	fi

	if [ -L "$icons_dest" ]; then
		log "INFO" "Icon symlink already exists."
		return exit_code
	else
		if [ ! -d "$icons_source_dir" ]; then
			log "ERROR" "Icons source directory '$icons_source_dir' does not exist."
			return 1
		else
			mkdir -p "$icons_dest_dir"
			ln -sfn "$icons_source_dir" "$icons_dest"
		fi
	fi

	if [ -f "$icons_dest/index.theme" ]; then
		gtk-update-icon-cache -f -t "$icons_dest" >>${LOG_FILE} 2>&1
	else
		log "WARNING" "index.theme not found for Buuf icons, skipping cache update."
	fi
	return exit_code
}
