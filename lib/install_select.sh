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
    if [[ "$embedded" =~ ^[yYoO]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    ask_question "Inclure LibreOffice? [y/N]: " office >&2
    if [[ "$office" =~ ^[yYoO]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    printf '%s\n' "${optional_packages_to_add[@]}"
}

# function get_all_packages_for_tui() {
#     declare -A CAT_TITLE_MAP
#     for cat_def in "${CATEGORIES[@]}"; do
#         local name="${cat_def%%:*}"
#         local title="${cat_def#*:}"
#         CAT_TITLE_MAP["$name"]="$title"
#     done

#     while read -r pkg_def; do
#         [[ -n "$pkg_def" ]] || continue
        
#         local id=$(get_package_info "$pkg_def" id)
#         local category_name=$(get_package_info "$pkg_def" category)
#         local level=$(get_package_info "$pkg_def" level)
#         local desc=$(get_package_info "$pkg_def" desc)
#         local category_title=${CAT_TITLE_MAP[$category_name]:-$category_name}
#         # Ajout de status pour l'audit
#         local status=${AUDIT_STATUS[$id]:-missing} 
        
#         # Ajout de status pour l'audit
#         echo "$category_name:$category_title:$level:$desc:$status"
#     done < <(get_all_packages)
# }

# function select_installables_tui {
#     log "INFO" "Launching advanced TUI package selector..."

#     if [ ! -x ./selector ]; then
#         log "WARNING" "'selector' not compiled. Attempting compilation..."
#         if ! command -v gcc &> /dev/null || ! gcc selec.c -o selector -lncursesw; then
#             log "ERROR" "Failed to compile 'selector'. Aborting."
#             exit 1
#         fi
#     fi

#     local selected_output
#     selected_output=$( {
#         echo "${DOT_LOGO[0]}"
#         echo "---DATA---"
#         get_all_packages_for_tui
#     } | ./selector )
    
#     if [[ -z "$selected_output" ]]; then
#         log "WARNING" "No packages selected or operation cancelled."
#         return 0
#     fi
    
#     local all_packages_defs
#     mapfile -t all_packages_defs < <(get_all_packages)
    
#     local selected_descriptions
#     mapfile -t selected_descriptions <<< "$selected_output"
    
#     for desc in "${selected_descriptions[@]}"; do
#         for pkg_def in "${all_packages_defs[@]}"; do
#             if [[ "$(get_package_info "$pkg_def" desc)" == "$desc" ]]; then
#                 echo "$pkg_def"
#                 break
#             fi
#         done
#     done
# }

function select_installables_tui() {
    log "INFO" "Launching profile selection TUI..."

    # S'assurer que le sélecteur est compilé
    if [ ! -x ./selector ]; then
        log "WARNING" "'selector' not found. Attempting to compile via 'make'..."
        if ! make; then
             log "ERROR" "Failed to compile 'selector' with make. Aborting."
             exit 1
        fi
    fi

    # Préparer les données à envoyer au programme C
    local tui_input
    # 1. Envoyer les profils
    printf "%s\n" "${PROFILES[@]}"
    # 2. Séparateur
    echo "---PACKAGES---"
    # 3. Envoyer tous les paquets avec leur statut d'installation
    get_all_packages_for_tui

    # Lancer le TUI et récupérer le nom du profil sélectionné
    local selected_profile_name
    selected_profile_name=$({
        printf "%s\n" "${PROFILES[@]}"
        echo "---PACKAGES---"
        get_all_packages_for_tui
    } | ./selector)
    
    if [[ -z "$selected_profile_name" ]]; then
        log "WARNING" "No profile selected or operation cancelled. Exiting."
        exit 0
    fi

    log "SUCCESS" "Profile selected: $selected_profile_name"

    # Trouver les tags correspondants au profil sélectionné
    local selected_tags=""
    for profile_def in "${PROFILES[@]}"; do
        local name="${profile_def%%:*}"
        if [[ "$name" == "$selected_profile_name" ]]; then
            selected_tags="${profile_def##*:}"
            break
        fi
    done
    
    if [[ -z "$selected_tags" ]]; then
        log "ERROR" "Could not find tags for profile '$selected_profile_name'. Aborting."
        exit 1
    fi
    
    # Récupérer la liste unique de paquets pour ce profil
    get_packages_by_tags "$selected_tags" | sort -u
}

# La fonction get_all_packages_for_tui doit être mise à jour pour utiliser les tags
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
        local tags=$(get_package_info "$pkg_def" tags)
        local desc=$(get_package_info "$pkg_def" desc)
        local status=${AUDIT_STATUS[$id]:-missing} 
        
        # Format pour le programme C: "description:tags:status"
        echo "$desc:$tags:$status"
    done < <(get_all_packages)
}