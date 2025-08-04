#!/bin/bash

# INSTALL OH MY ZSH
function install_zsh {
    if check_directory "$HOME/.oh-my-zsh"; then
        echo -e "${GREENHI}Oh My Zsh is already installed!${RESET}"
    else
        echo -e "${BLUEHI}**** Installing Oh My Zsh ****${YELLOW}"
        sh -c "$(curl -fsSL ${URL_OH_MY_ZSH})"
    fi
}

# INSTALL ZSH CONFIG
function install_zconfig {
    if check_directory "$HOME/.zsh"; then
        echo -e "${GREENHI}Zsh custom config is already installed!${RESET}"
    else
        echo -e "${BLUEHI}**** Installing Zsh custom config ****${YELLOW}"
        # Utilise la variable depuis settings.conf
        safe_git_clone "$ZSH_CONFIG_REPO" "$HOME/.zsh" "Zsh Custom Config"
        bash "$HOME/.zsh/install_zshrc.sh"
    fi

    echo -e "${BLUEHI}**** Installing Powerlevel10k theme ****${YELLOW}"
    local p10k_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    safe_git_clone "$URL_POWERLEVEL10K_REPO" "$p10k_path" "Powerlevel10k Theme"
}