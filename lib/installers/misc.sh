#!/usr/bin/env bash

# INSTALL FIREFOX WITH FLATPAK
function install_firefox {
    log "INFO" "Installing Firefox with Flatpak..."
	install_package "flatpak"
	flatpak remote-add --if-not-exists flathub "$URL_FLATHUB_REPO"
	flatpak install "$URL_FLATHUB_FIREFOX" -y
    log "SUCCESS" "Firefox installed successfully via Flatpak."
}

# SET BINARIES

function set_bin {
    echo -e "${BLUEHI}Setting up custom binaries in $PATH_LOCAL_BIN...${RESET}"
    mkdir -p "$PATH_LOCAL_BIN"

    if [[ ! -d "$PATH_USER_SCRIPTS" ]]; then
        echo -e "${YELLOW}Warning: Source scripts directory not found at $PATH_USER_SCRIPTS. Skipping.${RESET}"
        return 1
    fi

    for script_map in "${SCRIPTS_TO_LINK[@]}"; do
        IFS=':' read -r link_name source_file <<< "$script_map"
        local source_path="$PATH_USER_SCRIPTS/$source_file"
        local link_path="$PATH_LOCAL_BIN/$link_name"

        if [[ -f "$source_path" ]]; then
            ln -sfn "$source_path" "$link_path"
            echo "✅ Linked $link_path -> $source_path"
        else
            echo "❌ ERROR: Source script not found: $source_path"
        fi
    done
}

# SET VLC DEFAULT VIDEO PLAYER
function setup_vlc {
	for type in video/mp4 video/x-matroska video/x-msvideo video/quicktime video/webm video/x-flv video/mpeg; do
		xdg-mime default vlc.desktop $type
	done
}
