#!/bin/bash

function install_fonts {
    local themes_dir="$HOME/Themes"
    local fonts_dir="$themes_dir/Fonts"
    local icons_dir="$themes_dir/Icons"
    local sys_fonts_dir="/usr/share/fonts/truetype/custom"

    log "INFO" "Installing custom fonts and icons..."
    mkdir -p "$fonts_dir"
    mkdir -p "$icons_dir"

    log "INFO" "**** Installing MesloLGS Fonts ****"
    if check_file "$fonts_dir/MesloLGS NF Regular.ttf"; then
        log "INFO" "Fonts seem to be already downloaded."
    else
        safe_download "$URL_FONT_MESLO_REGULAR" "$fonts_dir/MesloLGS NF Regular.ttf" "MesloLGS Regular Font"
        safe_download "$URL_FONT_MESLO_BOLD" "$fonts_dir/MesloLGS NF Bold.ttf" "MesloLGS Bold Font"
        safe_download "$URL_FONT_MESLO_ITALIC" "$fonts_dir/MesloLGS NF Italic.ttf" "MesloLGS Italic Font"
        safe_download "$URL_FONT_MESLO_BOLD_ITALIC" "$fonts_dir/MesloLGS NF Bold Italic.ttf" "MesloLGS Bold Italic Font"

        log "INFO" "Copying fonts to system directory..."
        sudo mkdir -p "$sys_fonts_dir"
        sudo cp "$fonts_dir"/*.ttf "$sys_fonts_dir/"
        sudo fc-cache -fv
    fi

    log "INFO" "**** Installing Buuf Nestort Icons ****"
    if check_directory "$icons_dir/$BUUF_ICONS_NAME"; then
        log "INFO" "Icon pack already exists."
    else
        safe_git_clone "$BUUF_ICONS_REPO" "$icons_dir/$BUUF_ICONS_NAME" "Buuf Nestort Icon Pack"
        sudo ln -sfn "$icons_dir/$BUUF_ICONS_NAME" "/usr/share/icons/$BUUF_ICONS_NAME"
    fi
}