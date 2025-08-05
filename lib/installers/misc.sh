#!/usr/bin/env bash

# INSTALL FIREFOX WITH FLATPAK
# function install_firefox {
#     if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
#         log "WARNING" "Firefox installation from Mozilla repo is only for Debian/Ubuntu. Skipping."
#         return
#     fi
#     log "INFO" "Setting up Mozilla APT repository to install the official Firefox version..."

#     if [[ "$DRY_RUN" == "true" ]]; then
#         log "INFO" "[DRY-RUN] Would perform all steps to install Firefox from Mozilla's APT repository."
#         return
#     fi

#     wget -q "$URL_SIGN_KEY_FIREFOX" -O- | sudo tee "$FIREFOX_KEYRING" > /dev/null
#     #wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc  > /dev/null
	
#     local key_fingerprint
#     key_fingerprint=$(gpg -n -q --import --import-options import-show "$FIREFOX_KEYRING" 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

#     if [[ "$key_fingerprint" == "$FIREFOX_GPG_FINGERPRINT" ]]; then
#         log "SUCCESS" "Key fingerprint verified successfully."
#     else
#         log "ERROR" "Fingerprint verification FAILED. Expected '...DC6315A3', but got '$key_fingerprint'. Aborting."
#         return 1
#     fi

#     echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
#     echo '
#     Package: *
#     Pin: origin packages.mozilla.org
#     Pin-Priority: 1000
#     ' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
#     sudo apt update >> "$LOG_FILE" 2>&1
#     sudo apt install firefox firefox-l10n-fr -y >> "$LOG_FILE" 2>&1
#     log "SUCCESS" "Firefox installed successfully from the official Mozilla repository."
# }

# dotfiles/lib/installers/misc.sh (version corrigée et améliorée)

# INSTALL FIREFOX FROM MOZILLA'S OFFICIAL REPOSITORY
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

    # ÉTAPE 1: Télécharger la clé GPG
    log "INFO" "  -> Step 1/5: Downloading Mozilla GPG key..."
    # On isole la commande pour mieux la déboguer
    if ! (wget -q "$URL_SIGN_KEY_FIREFOX" -O- | sudo tee "$FIREFOX_KEYRING" > /dev/null); then
        log "ERROR" "Failed to download or write the GPG key. Check network connection or sudo permissions."
        return 1
    fi
    # VÉRIFICATION: S'assurer que le fichier de clé a bien été créé et n'est pas vide
    if [ ! -s "$FIREFOX_KEYRING" ]; then
        log "ERROR" "The GPG key file '$FIREFOX_KEYRING' was not created or is empty."
        return 1
    fi
    log "SUCCESS" "  -> Key downloaded successfully to '$FIREFOX_KEYRING'."

    # ÉTAPE 2: Vérifier l'empreinte de la clé
    log "INFO" "  -> Step 2/5: Verifying key fingerprint..."
    local key_fingerprint
    key_fingerprint=$(gpg -n -q --import --import-options import-show "$FIREFOX_KEYRING" 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

    if [[ "$key_fingerprint" == "$FIREFOX_GPG_FINGERPRINT" ]]; then
        log "SUCCESS" "  -> Fingerprint verified successfully."
    else
        # Log plus détaillé en cas d'échec
        log "ERROR" "Fingerprint verification FAILED. Aborting for security reasons."
        log "INFO" "    Expected: $FIREFOX_GPG_FINGERPRINT"
        log "WARNING" "  Received: ${key_fingerprint:-(empty string)}"
        return 1
    fi

    # ÉTAPE 3: Ajouter le dépôt APT de Mozilla
    log "INFO" "  -> Step 3/5: Adding Mozilla APT repository source..."
    echo "deb [signed-by=$FIREFOX_KEYRING] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    
    # ÉTAPE 4: Configurer la priorité du dépôt (APT Pinning)
    log "INFO" "  -> Step 4/5: Setting APT Pin-Priority for Mozilla repository..."
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    # ÉTAPE 5: Mettre à jour et installer
    log "INFO" "  -> Step 5/5: Updating package lists and installing Firefox..."
    if ! sudo apt-get update >> "$LOG_FILE" 2>&1; then
        log "ERROR" "apt-get update failed after adding Mozilla repo. Check '$LOG_FILE' for details."
        return 1
    fi

    if ! sudo apt-get install firefox firefox-l10n-fr -y >> "$LOG_FILE" 2>&1; then
        log "ERROR" "Failed to install Firefox packages from Mozilla repo. Check '$LOG_FILE' for details."
        return 1
    fi

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
