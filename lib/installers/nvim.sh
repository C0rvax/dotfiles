#!/bin/bash

function install_nvim {
    local dotfiles_dir
    dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin robuste
    
    local nvim_config_source="$dotfiles_dir/home/.config/nvim"
    local nvim_config_target="$HOME/.config/nvim"
    local appimage_dir="$HOME/AppImage"
    local nvim_path="$appimage_dir/nvim.appimage"
    local clang_path="$dotfiles_dir/home/clang-format"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would install NeoVim AppImage."
        log "INFO" "NeoVim configuration would be linked from '$nvim_config_source' to '$nvim_config_target'."
        log "INFO" "Clang format would be linked from '$clang_path' to '$HOME/.clang-format'."
        return 0
    elif [ -f "$nvim_path/nvim.appimage" ]; then
        log "INFO" "NeoVim AppImage already exists at '$nvim_path'. Skipping download."
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

    if [ -s "$clang_path" ]; then
        if ! ln -sfn "$clang_path" "$HOME/.clang-format"; then
            log "ERROR" "Failed to link clang-format."
            return 1
        fi
    fi

    if ! ln -sfn "$nvim_config_source" "$nvim_config_target"; then
        log "ERROR" "Failed to link Neovim configuration."
        return 1
    fi
    return 0
}