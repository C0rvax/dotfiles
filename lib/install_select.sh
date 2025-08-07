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

function select_installables_tui {
    log "INFO" "Launching TUI package selector..."

    # Créer un tableau associatif pour mapper le titre affiché au nom de catégorie
    local category_titles=()
    declare -A TITLE_TO_CAT_NAME_MAP
    for cat in "${CATEGORIES[@]}"; do
        local category_name="${cat%%:*}"
        local category_title="${cat#*:}"
        
        category_titles+=("$category_title")
        TITLE_TO_CAT_NAME_MAP["$category_title"]="$category_name"
    done
    
    # Compilation du sélecteur (si nécessaire)
    if [ ! -x ./selector ]; then
        log "WARNING" "'selector' not compiled. Attempting compilation..."
        if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncurses; then
            log "ERROR" "Failed to compile 'selector'. Aborting."
            exit 1
        fi
    fi

    # Lancer le sélecteur C et capturer les titres sélectionnés
    local selected_output
    selected_output=$(./selector "${category_titles[@]}")
    
    # Si l'utilisateur annule (sortie vide), on ne renvoie rien.
    if [[ -z "$selected_output" ]]; then
        log "WARNING" "No categories selected or operation cancelled."
        return 0
    fi
    
    # Convertir la chaîne de sortie en tableau de titres
    local selected_titles=()
    mapfile -t selected_titles <<< "$selected_output"

    # Boucler sur les titres sélectionnés
    for title in "${selected_titles[@]}"; do
        # Retrouver le nom de la catégorie (ex: "dev") à partir du titre (ex: "Development")
        local cat_name=${TITLE_TO_CAT_NAME_MAP["$title"]}
        
        if [[ -n "$cat_name" ]]; then
            # Utiliser votre fonction existante pour récupérer toutes les définitions de paquets
            # de cette catégorie et les IMPRIMER sur la sortie standard.
            get_packages_by_category "$cat_name"
        fi
    done
}