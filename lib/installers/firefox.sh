#!/bin/bash

function install_firefox {
    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
        log "WARNING" "Firefox installation from Mozilla repo is only for Debian/Ubuntu. Skipping."
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would perform all steps to install Firefox from Mozilla's APT repository."
        return 0
    fi

    if ! (wget -q "$URL_SIGN_KEY_FIREFOX" -O- | sudo tee "$FIREFOX_KEYRING" > /dev/null); then
        log "ERROR" "Failed to download or write the GPG key. Check network connection or sudo permissions."
        return 1
    fi
    if [ ! -s "$FIREFOX_KEYRING" ]; then
        log "ERROR" "The GPG key file '$FIREFOX_KEYRING' was not created or is empty."
        return 1
    fi

    local key_fingerprint
    key_fingerprint=$(gpg -n -q --import --import-options import-show "$FIREFOX_KEYRING" 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

    if [[ "$key_fingerprint" != "$FIREFOX_GPG_FINGERPRINT" ]]; then
        log "ERROR" "Fingerprint verification FAILED. Aborting for security reasons."
        log "INFO" "    Expected: $FIREFOX_GPG_FINGERPRINT"
        log "WARNING" "  Received: ${key_fingerprint:-(empty string)}"
        print_table_line
        return 1
    fi

    echo "deb [signed-by=$FIREFOX_KEYRING] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    # if ! sudo apt-get update >> "$LOG_FILE" 2>&1; then
    #     log "ERROR" "apt-get update failed after adding Mozilla repo. Check '$LOG_FILE' for details."
    #     return 1
    # fi

    if ! sudo apt-get install firefox firefox-l10n-fr -y >> "$LOG_FILE" 2>&1; then
        log "ERROR" "Failed to install Firefox packages from Mozilla repo. Check '$LOG_FILE' for details."
        return 1
    fi
}
