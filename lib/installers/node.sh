#!/usr/bin/env bash

function install_node {
    local home_dir="$HOME"

    log "CLONE" "Installing Node.js via NVM..."

    local nvm_install_script
    nvm_install_script=$(mktemp)
    trap 'rm -f "$nvm_install_script"' RETURN

    # Downloading NVM install script
    if ! safe_download "$URL_NVM_INSTALL" "$nvm_install_script" "NVM install script"; then
        return 1 # safe_download gère le log d'erreur
    fi

    # Executing the downloaded script
    log "INFO" "Executing NVM installer..."
    if ! bash "$nvm_install_script" >> "$LOG_FILE" 2>&1; then
        log "ERROR" "NVM installation script failed."
        return 1
    fi

    # Load NVM into the current session
    export NVM_DIR="$home_dir/.nvm"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
    else
        log "ERROR" "NVM script not found after installation"
        return 1
    fi

    # Install Node.js
    if ! nvm install node > ${LOG_FILE} 2>&1; then
        log "ERROR" "Failed to install Node.js"
        return 1
    fi

    if ! nvm use node > ${LOG_FILE} 2>&1; then
        log "ERROR" "Could not use the installed Node.js version"
        return 1
    fi

    log "SUCCESS" "Node.js installed successfully"
    return 0
}