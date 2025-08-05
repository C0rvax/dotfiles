# INSTALL NVIM + CONFIG
function install_nvim {
    local dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd) # Chemin robuste
    
    local nvim_config_source="$dotfiles_dir/home/.config/nvim"
    local nvim_config_target="$HOME/.config/nvim"

    local nvim_path="$home_dir/AppImage/nvim.appimage"
    if check_file "$nvim_path"; then
        log "INFO" "NeoVim is already installed!"
    else
        log "INFO" "Installing NeoVim..."

        local appimage_dir="$home_dir/AppImage"
        if ! check_directory "$appimage_dir"; then
            mkdir -p "$appimage_dir" || {
                log "ERROR" "Could not create directory $appimage_dir"
                return 1
            }
        fi

        cd "$appimage_dir" || {
            log "ERROR" "Could not access directory $appimage_dir"
            return 1
        }

        if ! safe_download \
            "$URL_NVIM_APPIMAGE" \
            "nvim.appimage" \
            "NeoVim AppImage"; then
            return 1
        fi

        chmod u+x nvim.appimage || {
            log "ERROR" "Could not make nvim.appimage executable"
            return 1
        }

        cd "$home_dir" || return 1
        echo -e "${RESET}"
    fi

    # Install Nvim configuration
    log "INFO" "Linking Neovim configuration..."
    if [ ! -d "$nvim_config_source" ]; then
        log "ERROR" "Neovim source configuration not found in dotfiles repo at '$nvim_config_source'"
        return 1
    fi

    mkdir -p "$(dirname "$nvim_config_target")"

    ln -sfn "$nvim_config_source" "$nvim_config_target"
    log "SUCCESS" "Neovim configuration linked."

    # local nvim_config_dir="$home_dir/.config/nvim"
    # if check_directory "$nvim_config_dir"; then
    #     log "INFO" "Nvim configuration already installed!"
    # else
    #     log "INFO" "Installing nvim configuration..."

    #     mkdir -p "$home_dir/.config" || {
    #         log "ERROR" "Could not create .config directory"
    #         return 1
    #     }

    #     if ! safe_git_clone \
    #         "$NVIM_CONFIG_REPO" \
    #         "$nvim_config_dir" \
    #         "NeoVim Configuration"; then
    #         return 1
    #     fi
    # fi

    # log "SUCCESS" "NeoVim installation completed successfully"
    return 0
}