#!/bin/bash

function install_nvim {
    local dotfiles_dir
    dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin robuste
    
    local nvim_config_source="$dotfiles_dir/home/.config/nvim"
    local nvim_config_target="$HOME/.config/nvim"
    local appimage_dir="$HOME/AppImage"
    local nvim_path="$appimage_dir/nvim.appimage"

    if check_file "$nvim_path"; then
        log "INFO" "NeoVim AppImage is already installed."
    else
        log "INFO" "Installing NeoVim AppImage..."

        if ! mkdir -p "$appimage_dir"; then
            log "ERROR" "Could not create directory '$appimage_dir'"
            return 1
        fi

        if ! safe_download "$URL_NVIM_APPIMAGE" "$nvim_path" "NeoVim AppImage"; then
            return 1
        fi

        if ! chmod u+x "$nvim_path"; then
            log "ERROR" "Could not make '$nvim_path' executable"
            return 1
        fi
        
        log "SUCCESS" "NeoVim AppImage installed successfully."
    fi

    log "INFO" "Linking Neovim configuration..."
    if [ ! -d "$nvim_config_source" ]; then
        log "ERROR" "Neovim source configuration not found in dotfiles repo at '$nvim_config_source'"
        return 1
    fi

    mkdir -p "$(dirname "$nvim_config_target")"

    if ln -sfn "$nvim_config_source" "$nvim_config_target"; then
        log "SUCCESS" "Neovim configuration linked."
    else
        log "ERROR" "Failed to link Neovim configuration."
        return 1
    fi

    return 0
}