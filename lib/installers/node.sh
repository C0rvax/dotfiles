#!/usr/bin/env bash

function install_node {
    local home_dir="$HOME"

    log "INFO" "📦 Installing Node.js via NVM..."

    # Downloading and installing NVM
    if ! curl -fsSL "$URL_NVM_INSTALL" | bash; then
        log "ERROR" "Failed to install NVM"
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
    if ! nvm install node; then
        log "ERROR" "Failed to install Node.js"
        return 1
    fi

    if ! nvm use node; then
        log "ERROR" "Could not use the installed Node.js version"
        return 1
    fi

    log "SUCCESS" "Node.js installed successfully"
    return 0
}