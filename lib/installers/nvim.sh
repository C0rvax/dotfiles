#!/bin/bash

# INSTALL NVIM + CONFIG
function install_nvim {
    local dotfiles_dir
    dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin robuste
    
    local nvim_config_source="$dotfiles_dir/home/.config/nvim"
    local nvim_config_target="$HOME/.config/nvim"
    local appimage_dir="$HOME/AppImage"
    local nvim_path="$appimage_dir/nvim.appimage"

    # --- Installation de l'AppImage ---
    if check_file "$nvim_path"; then
        log "INFO" "NeoVim AppImage is already installed."
    else
        log "INFO" "Installing NeoVim AppImage..."

        # 1. Créer le répertoire de destination s'il n'existe pas
        # On utilise le chemin absolu directement.
        if ! mkdir -p "$appimage_dir"; then
            log "ERROR" "Could not create directory '$appimage_dir'"
            return 1
        fi

        # 2. Télécharger le fichier directement à sa destination finale
        # On passe le chemin absolu ($nvim_path) à safe_download.
        if ! safe_download "$URL_NVIM_APPIMAGE" "$nvim_path" "NeoVim AppImage"; then
            return 1
        fi

        # 3. Rendre le fichier exécutable en utilisant son chemin absolu
        if ! chmod u+x "$nvim_path"; then
            log "ERROR" "Could not make '$nvim_path' executable"
            return 1
        fi
        
        log "SUCCESS" "NeoVim AppImage installed successfully."
    fi

    # --- Installation de la configuration de Nvim ---
    log "INFO" "Linking Neovim configuration..."
    if [ ! -d "$nvim_config_source" ]; then
        log "ERROR" "Neovim source configuration not found in dotfiles repo at '$nvim_config_source'"
        return 1
    fi

    # Assurer que le parent du répertoire cible existe
    mkdir -p "$(dirname "$nvim_config_target")"

    # Créer le lien symbolique
    if ln -sfn "$nvim_config_source" "$nvim_config_target"; then
        log "SUCCESS" "Neovim configuration linked."
    else
        log "ERROR" "Failed to link Neovim configuration."
        return 1
    fi

    return 0
}