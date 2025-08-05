#!/bin/bash

function install_zsh {
    if check_directory "$HOME/.oh-my-zsh"; then
        log "INFO" "Oh My Zsh is already installed."
    else
        log "INFO" "Installing Oh My Zsh"
        sh -c "$(curl -fsSL ${URL_OH_MY_ZSH})" "" --unattended --keep-zshrc
		if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which zsh)" ]]; then
            log "INFO" "Setting Zsh as the default shell..."
            chsh -s "$(which zsh)"
            if [[ $? -ne 0 ]]; then
                log "ERROR" "Failed to set Zsh as default shell. Please do it manually with 'chsh -s \$(which zsh)'"
            fi
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
    
    log "SUCCESS" "Zsh custom configuration linked successfully."
}