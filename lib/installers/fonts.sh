#!/bin/bash

function install_fonts {
	local dotfiles_dir
	dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin vers la racine du dépôt
	local themes_dir="$dotfiles_dir/home/themes"
	local fonts_source_dir="$themes_dir/fonts"
	local icons_source_dir="$themes_dir/icons/$BUUF_ICONS_NAME"

	#local sys_fonts_dir="/usr/share/fonts/truetype/custom"
	#local icon_dest_dir="/usr/share/icons/$BUUF_ICONS_NAME"
	local user_fonts_dir="$HOME/.local/share/fonts"
	local icon_dest_dir="$HOME/.local/share/icons/$BUUF_ICONS_NAME"

	local exit_code=0
	if [[ "$DRY_RUN" == "true" ]]; then
		log "INFO" "[DRY-RUN] Would install custom fonts and icons."
		log "INFO" "MesloLGS NF fonts would be copied to '$user_fonts_dir'."
		log "INFO" "Buuf Nestort icons would be cloned to '$icon_dest_dir'."
		return exit_code
	fi

	if [ -s "$user_fonts_dir/MesloLGS NF Regular.ttf" ]; then
		log "INFO" "Fonts seem to be already installed."
	else
		if [ ! -d "$fonts_source_dir" ] || [ -z "$(ls -A $fonts_source_dir/*.ttf 2>/dev/null)" ]; then
			log "ERROR" "Font source directory '$fonts_source_dir' is empty or does not exist."
			exit_code=1
		else
			mkdir -p "$user_fonts_dir"
			cp "$fonts_source_dir"/*.ttf "$user_fonts_dir/" >>${LOG_FILE} 2>&1
			fc-cache -fv "$user_fonts_dir" >>${LOG_FILE} 2>&1
		fi
	fi

	if [ -L "$icon_dest_dir" ]; then
		log "INFO" "Icon symlink already exists."
		return exit_code
	else
		if [ ! -d "$icons_source_dir" ]; then
			log "ERROR" "Icons source directory '$icons_source_dir' does not exist."
			return 1
		else
			mkdir -p "$icons_source_dir"
			ln -sfn "$icons_source_dir" "$icon_dest_dir"
		fi
	fi

	if [ -f "$icon_dest_dir/index.theme" ]; then
		gtk-update-icon-cache -f -t "$icon_dest_dir" >>${LOG_FILE} 2>&1
	else
		log "WARNING" "index.theme not found for Buuf icons, skipping cache update."
	fi
	return exit_code
}

