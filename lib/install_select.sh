#!/bin/bash

function select_base_packages() {
    local install_type

    print_title_element "INSTALLATION TYPE" "$BLUEHI" >&2
    print_table_line >&2

    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="1"
        log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
    else
        print_left_element "1) Base (Minimal: core utils, dev tools, shell, nvim config)" "$BLUEHI" >&2
        print_left_element "2) Full (Recommended: 'Base' + graphical apps, Docker, etc.)" "$BLUEHI" >&2
        print_left_element "3) Custom (Not implemented yet, defaults to 'Full')" "$BLUEHI" >&2
        ask_question "Enter your choice [1-3]" install_type >&2
    fi

    local base_packages_to_install=()
    case "$install_type" in
    1)
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        ;;
    2)
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#base_packages_to_install[@]}" base_packages_to_install < <(get_packages_by_level "full")
        ;;
    3)
        echo "Mode personnalisé pas encore implémenté, passage en mode complet"
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#base_packages_to_install[@]}" base_packages_to_install < <(get_packages_by_level "full")
        ;;
    *)
        log "ERROR" "Invalid selection: '$install_type'. Please choose 1, 2 or 3."
        print_table_line
        exit 1
        ;;
    esac

    printf '%s\n' "${base_packages_to_install[@]}"
}

function select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()

    ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" embedded >&2
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    ask_question "Inclure LibreOffice? [y/N]: " office >&2
    if [[ "$office" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    printf '%s\n' "${optional_packages_to_add[@]}"
}

# function get_all_packages_for_tui() {
#     # Créer une map pour une recherche facile du titre de la catégorie
#     declare -A CAT_TITLE_MAP
#     for cat_def in "${CATEGORIES[@]}"; do
#         local name="${cat_def%%:*}"
#         local title="${cat_def#*:}"
#         CAT_TITLE_MAP["$name"]="$title"
#     done

#     while read -r pkg_def; do
#         [[ -n "$pkg_def" ]] || continue
        
#         local category_name=$(get_package_info "$pkg_def" category)
#         local level=$(get_package_info "$pkg_def" level)
#         local desc=$(get_package_info "$pkg_def" desc)
#         local category_title=${CAT_TITLE_MAP[$category_name]:-$category_name} # Utilise le nom si pas de titre
        
#         echo "$category_name:$category_title:$level:$desc"
#     done < <(get_all_packages)
# }

function get_all_packages_for_tui() {
    declare -A CAT_TITLE_MAP
    for cat_def in "${CATEGORIES[@]}"; do
        local name="${cat_def%%:*}"
        local title="${cat_def#*:}"
        CAT_TITLE_MAP["$name"]="$title"
    done

    while read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        
        local id=$(get_package_info "$pkg_def" id)
        local category_name=$(get_package_info "$pkg_def" category)
        local level=$(get_package_info "$pkg_def" level)
        local desc=$(get_package_info "$pkg_def" desc)
        local category_title=${CAT_TITLE_MAP[$category_name]:-$category_name}
        # On récupère le statut depuis la map globale remplie par l'audit silencieux
        local status=${AUDIT_STATUS[$id]:-missing} 
        
        # NOUVEAU FORMAT : name:title:level:desc:status
        echo "$category_name:$category_title:$level:$desc:$status"
    done < <(get_all_packages)
}

# MODIFIÉ : Envoie le logo, un délimiteur, puis les données
function select_installables_tui {
    log "INFO" "Launching advanced TUI package selector..."

    if [ ! -x ./selector ]; then
        log "WARNING" "'selector' not compiled. Attempting compilation..."
        if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncursesw; then
            log "ERROR" "Failed to compile 'selector'. Aborting."
            exit 1
        fi
    fi

    # L'appel au sélecteur est maintenant un bloc de commandes
    local selected_output
    selected_output=$( {
        # 1. Envoyer le logo
        echo "${DOT_LOGO[0]}"
        # 2. Envoyer le délimiteur
        echo "---DATA---"
        # 3. Envoyer les données des paquets
        get_all_packages_for_tui
    } | ./selector )
    
    # Le reste de la fonction est inchangé, elle récupère les descriptions
    if [[ -z "$selected_output" ]]; then
        log "WARNING" "No packages selected or operation cancelled."
        return 0
    fi
    
    local all_packages_defs
    mapfile -t all_packages_defs < <(get_all_packages)
    
    local selected_descriptions
    mapfile -t selected_descriptions <<< "$selected_output"
    
    for desc in "${selected_descriptions[@]}"; do
        for pkg_def in "${all_packages_defs[@]}"; do
            if [[ "$(get_package_info "$pkg_def" desc)" == "$desc" ]]; then
                echo "$pkg_def"
                break
            fi
        done
    done
}