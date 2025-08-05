#!/bin/bash

# INSTALL OH MY ZSH
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

# INSTALL ZSH CONFIG
function install_zconfig {
    if check_directory "$HOME/.zsh"; then
        log "INFO" "Zsh custom config is already installed."
    else
        log "INFO" "Installing Zsh custom config"
        safe_git_clone "$ZSH_CONFIG_REPO" "$HOME/.zsh" "Zsh Custom Config"
        bash "$HOME/.zsh/install_zshrc.sh"
    fi

    log "INFO" "Installing Powerlevel10k theme"
    local p10k_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    safe_git_clone "$URL_POWERLEVEL10K_REPO" "$p10k_path" "Powerlevel10k Theme"
}