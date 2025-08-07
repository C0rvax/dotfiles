#!/bin/bash

pkg_install() {
    local package="$1"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[SIMULATION] Installation de $package"
        return 0
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get install -y "$package" &>/dev/null
            ;;
        arch)
            sudo pacman -S --noconfirm "$package" &>/dev/null
            ;;
        fedora)
            sudo dnf install -y "$package" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# === FONCTIONS DE PARSING ===

get_package_info() {
    local package_def="$1"
    local field="$2"
    
    IFS=':' read -ra parts <<< "$package_def"
    case "$field" in
        id) echo "${parts[0]}" ;;
        desc) echo "${parts[1]}" ;;
        level) echo "${parts[2]}" ;;
        category) echo "${parts[3]}" ;;
        check) echo "${parts[4]}" ;;
        install) echo "${parts[5]}" ;;
    esac
}

get_all_packages() {
    printf '%s\n' "${SYSTEM_PACKAGES[@]}" "${SPECIAL_INSTALLS[@]}" "${OPTIONAL_PACKAGES[@]}"
}

function get_packages_by_level() {
    local level_filter="$1"
    # On applique la correction du subshell ici aussi !
    while read -r pkg_def; do
        # On ignore les lignes vides qui pourraient se glisser
        [[ -n "$pkg_def" ]] || continue
        
        if [[ "$(get_package_info "$pkg_def" level)" == "$level_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}

function get_packages_by_category() {
    local category_filter="$1"
    # Et ici aussi !
    while read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        
        if [[ "$(get_package_info "$pkg_def" category)" == "$category_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}
