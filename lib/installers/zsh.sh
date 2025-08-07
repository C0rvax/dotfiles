#!/bin/bash

function install_zsh {
    local dotfiles_dir
    dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin vers la racine du dépôt

    local omz_source_path="$dotfiles_dir/vendor/oh-my-zsh"
    local omz_target_path="$HOME/.oh-my-zsh"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would install Zsh and Oh My Zsh from local submodule."
        log "INFO" "Zsh configuration files would be linked from '$dotfiles_dir/home/'"
        log "INFO" "to '$HOME/.zsh' and '$HOME/.zshrc'."
        return 0
    fi
    if [ ! -d "$omz_source_path" ] || [ -z "$(ls -A "$omz_source_path")" ]; then
        log "ERROR" "Oh My Zsh submodule is missing or empty at '$omz_source_path'."
        log "INFO" "Please run 'git submodule update --init --recursive' in your dotfiles directory."
        return 1
    fi
    
    log "INFO" "Linking Oh My Zsh from local submodule..."
    ln -sfn "$omz_source_path" "$omz_target_path"

local zsh_path
    zsh_path=$(which zsh)

    if [ -z "$zsh_path" ]; then
        log "ERROR" "zsh executable not found. Please make sure the 'zsh' package is installed."
        return 1
    fi


    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
        log "INFO" "Setting Zsh as the default shell..."
        if ! sudo chsh -s "$zsh_path" "$USER"; then
            log "ERROR" "Failed to set Zsh as default shell. Please do it manually."
        else
            log "SUCCESS" "Zsh is now the default shell."
        fi
    fi
}

function install_zconfig {
    local dotfiles_dir
    dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin vers la racine du dépôt

    log "INFO" "Linking Zsh configurations and plugins..."

    ln -sfn "$dotfiles_dir/home/.zsh" "$HOME/.zsh"
    ln -sfn "$dotfiles_dir/home/.zshrc" "$HOME/.zshrc"
    if [ -f "$dotfiles_dir/home/.p10k.zsh" ]; then
        ln -sfn "$dotfiles_dir/home/.p10k.zsh" "$HOME/.p10k.zsh"
    fi
    
    local omz_custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    mkdir -p "$omz_custom_dir/themes"
    mkdir -p "$omz_custom_dir/plugins"

    ln -sfn "$HOME/.zsh/powerlevel10k" "$omz_custom_dir/themes/powerlevel10k"
    ln -sfn "$HOME/.zsh/plugins/zsh-autosuggestions" "$omz_custom_dir/plugins/zsh-autosuggestions"
    ln -sfn "$HOME/.zsh/plugins/zsh-syntax-highlighting" "$omz_custom_dir/plugins/zsh-syntax-highlighting"
    
    return 0
}