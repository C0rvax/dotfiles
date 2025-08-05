#!/usr/bin/env bash

# INSTALL FIREFOX WITH FLATPAK
function install_firefox {
    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
        log "WARNING" "Firefox installation from Mozilla repo is only for Debian/Ubuntu. Skipping."
        return
    fi
    log "INFO" "Setting up Mozilla APT repository to install the official Firefox version..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would perform all steps to install Firefox from Mozilla's APT repository."
        return
    fi

    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc  > /dev/null
	
    local key_fingerprint
    key_fingerprint=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')
    
    if [[ "$key_fingerprint" == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]]; then
        log "SUCCESS" "Key fingerprint verified successfully."
    else
        log "ERROR" "Fingerprint verification FAILED. Expected '...DC6315A3', but got '$key_fingerprint'. Aborting."
        return 1
    fi

    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo '
    Package: *
    Pin: origin packages.mozilla.org
    Pin-Priority: 1000
    ' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install firefox firefox-l10n-fr -y >> "$LOG_FILE" 2>&1
    # install_package "flatpak"
	# flatpak remote-add --if-not-exists flathub "$URL_FLATHUB_REPO"
	# flatpak install "$URL_FLATHUB_FIREFOX" -y
    log "SUCCESS" "Firefox installed successfully from the official Mozilla repository."
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
