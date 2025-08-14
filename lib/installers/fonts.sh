#!/bin/bash

function install_fonts {
	local dotfiles_dir
	dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
	local themes_dir="$dotfiles_dir/home/themes"
	local fonts_source_dir="$themes_dir/fonts"

	#local sys_fonts_dir="/usr/share/fonts/truetype/custom"
	#local icons_dest_dir="/usr/share/icons/$BUUF_ICONS_NAME"
	local fonts_dest_dir="$HOME/.local/share/fonts"

	if [[ "$DRY_RUN" == "true" ]]; then
		log "INFO" "[DRY-RUN] Would install custom fonts."
		log "INFO" "MesloLGS NF fonts would be copied to '$fonts_dest_dir'."
		return 0
	fi

	if [ -s "$fonts_dest_dir/MesloLGS NF Regular.ttf" ]; then
		log "INFO" "Fonts seem to be already installed."
	else
		if [ ! -d "$fonts_source_dir" ] || [ -z "$(ls -A $fonts_source_dir/*.ttf 2>/dev/null)" ]; then
			log "ERROR" "Font source directory '$fonts_source_dir' is empty or does not exist."
			return 1
		else
			mkdir -p "$fonts_dest_dir"
			cp "$fonts_source_dir"/*.ttf "$fonts_dest_dir/" >>${LOG_FILE} 2>&1
			fc-cache -fv "$fonts_dest_dir" >>${LOG_FILE} 2>&1
		fi
	fi
}
