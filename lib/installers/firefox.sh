#!/bin/bash

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

    if [[ "$VERBOSE" == "true" ]]; then
        log "INFO" "  -> Step 1/5: Downloading Mozilla GPG key..."
    fi
    if ! (wget -q "$URL_SIGN_KEY_FIREFOX" -O- | sudo tee "$FIREFOX_KEYRING" > /dev/null); then
        log "ERROR" "Failed to download or write the GPG key. Check network connection or sudo permissions."
        return 1
    fi
    if [ ! -s "$FIREFOX_KEYRING" ]; then
        log "ERROR" "The GPG key file '$FIREFOX_KEYRING' was not created or is empty."
        return 1
    fi
    if [[ "$VERBOSE" == "true" ]]; then
        log "SUCCESS" "  -> Key downloaded successfully to '$FIREFOX_KEYRING'."
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        log "INFO" "  -> Step 2/5: Verifying GPG key fingerprint..."
    fi
    local key_fingerprint
    key_fingerprint=$(gpg -n -q --import --import-options import-show "$FIREFOX_KEYRING" 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

    if [[ "$key_fingerprint" == "$FIREFOX_GPG_FINGERPRINT" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            log "SUCCESS" "  -> Fingerprint verified successfully."
        fi
    else
        log "ERROR" "Fingerprint verification FAILED. Aborting for security reasons."
        log "INFO" "    Expected: $FIREFOX_GPG_FINGERPRINT"
        log "WARNING" "  Received: ${key_fingerprint:-(empty string)}"
        print_table_line
        return 1
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        log "INFO" "  -> Step 3/5: Adding Mozilla APT repository source..."
    fi
    echo "deb [signed-by=$FIREFOX_KEYRING] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

    if [[ "$VERBOSE" == "true" ]]; then
        log "INFO" "  -> Step 4/5: Setting APT Pin-Priority for Mozilla repository..."
    fi
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    if [[ "$VERBOSE" == "true" ]]; then
        log "INFO" "  -> Step 5/5: Updating package lists and installing Firefox..."
    fi
    if ! sudo apt-get update >> "$LOG_FILE" 2>&1; then
        log "ERROR" "apt-get update failed after adding Mozilla repo. Check '$LOG_FILE' for details."
        print_table_line
        return 1
    fi

    if ! sudo apt-get install firefox firefox-l10n-fr -y >> "$LOG_FILE" 2>&1; then
        log "ERROR" "Failed to install Firefox packages from Mozilla repo. Check '$LOG_FILE' for details."
        print_table_line
        return 1
    fi

    log "SUCCESS" "Firefox installed successfully from the official Mozilla repository."
    print_table_line
}
