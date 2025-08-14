#!/bin/bash

function install_icons {
	local dotfiles_dir
	dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
	local themes_dir="$dotfiles_dir/home/themes"
	local icons_source_dir="$themes_dir/icons/$BUUF_ICONS_NAME"

	local icons_dest_dir="$HOME/.local/share/icons"
	local icons_dest="$HOME/.local/share/icons/$BUUF_ICONS_NAME"

	if [[ "$DRY_RUN" == "true" ]]; then
		log "INFO" "[DRY-RUN] Would install custom icons."
		log "INFO" "Buuf Nestort icons would be cloned to '$icons_dest_dir'."
		return 0
	fi

	if [ -L "$icons_dest" ]; then
		log "INFO" "Icon symlink already exists."
		return 0
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
}

