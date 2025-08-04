#!/usr/bin/env bash

function install_node {
    local home_dir="$HOME"

    echo "📦 Installing Node.js via NVM..."

    # Downloading and installing NVM
    if ! curl -fsSL "$URL_NVM_INSTALL" | bash; then
        echo "❌ ERROR: Failed to install NVM" >&2
        return 1
    fi

    # Load NVM into the current session
    export NVM_DIR="$home_dir/.nvm"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
    else
        echo "❌ ERROR: NVM script not found after installation" >&2
        return 1
    fi

    # Install Node.js
    if ! nvm install node; then
        echo "❌ ERROR: Failed to install Node.js" >&2
        return 1
    fi

    if ! nvm use node; then
        echo "❌ ERROR: Could not use the installed Node.js version" >&2
        return 1
    fi

    echo "✅ Node.js installed successfully"
    return 0
}