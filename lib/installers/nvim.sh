# INSTALL NVIM + CONFIG
function install_nvim {
    local home_dir="$HOME"

    local nvim_path="$home_dir/AppImage/nvim.appimage"
    if check_file "$nvim_path"; then
        echo -e "${GREENHI} #### NeoVim is already installed! ####${RESET}"
    else
        echo -e "${BLUEHI} **** Installing NeoVim ****${YELLOW}"

        local appimage_dir="$home_dir/AppImage"
        if ! check_directory "$appimage_dir"; then
            mkdir -p "$appimage_dir" || {
                echo "❌ Could not create directory $appimage_dir" >&2
                return 1
            }
        fi

        cd "$appimage_dir" || {
            echo "❌ Could not access directory $appimage_dir" >&2
            return 1
        }

        if ! safe_download \
            "$URL_NVIM_APPIMAGE" \
            "nvim.appimage" \
            "NeoVim AppImage"; then
            return 1
        fi

        chmod u+x nvim.appimage || {
            echo "❌ Could not make nvim.appimage executable" >&2
            return 1
        }

        cd "$home_dir" || return 1
        echo -e "${RESET}"
    fi

    # Install Nvim configuration
    local nvim_config_dir="$home_dir/.config/nvim"
    if check_directory "$nvim_config_dir"; then
        echo -e "${GREENHI} #### Nvim configuration already installed! ####${RESET}"
    else
        echo -e "${BLUEHI} **** Installing nvim configuration ****${YELLOW}"

        mkdir -p "$home_dir/.config" || {
            echo "❌ Could not create .config directory" >&2
            return 1
        }

        if ! safe_git_clone \
            "$NVIM_CONFIG_REPO" \
            "$nvim_config_dir" \
            "NeoVim Configuration"; then
            return 1
        fi
    fi

    echo "✅ NeoVim installation completed successfully"
    return 0
}