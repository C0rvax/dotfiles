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

    # Le TUI sélectionne par catégorie. On lui passe les titres.
    local category_titles=()
    declare -gA TITLE_TO_CAT_NAME_MAP # Pour retrouver le nom de la variable après sélection
    for category_info in "${CATEGORIES[@]}"; do
        local cat_name="${category_info%%:*}"
        local cat_title="${category_info#*:}"
        local clean_title=$(echo "$cat_title" | sed -e 's/--- //' -e 's/ ---//' -e 's/ (Optionnel)//')
        category_titles+=("$clean_title")
        TITLE_TO_CAT_NAME_MAP["$clean_title"]="$cat_name"
    done
    
    # Compilation du sélecteur (inchangé)
    if [ ! -x ./selector ]; then
        log "WARNING" "'selector' not compiled. Attempting compilation..."
        if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncurses; then
            log "ERROR" "Failed to compile 'selector'. Aborting."
            exit 1
        else
            log "SUCCESS" "'selector' compiled."
        fi
    fi

    local selected_output
    selected_output=$(./selector "${category_titles[@]}")
    
    if [ -z "$selected_output" ]; then
        log "WARNING" "No categories selected or operation cancelled. Exiting."
        return
    fi
    
    local selected_titles=()
    mapfile -t selected_titles <<< "$selected_output"

    local ids_to_consider=()
    for title in "${selected_titles[@]}"; do
        local cat_name=${TITLE_TO_CAT_NAME_MAP["$title"]}
        if [ -n "$cat_name" ]; then
            # Utiliser l'indirection pour obtenir les IDs de la catégorie
            local ids_in_category_ref="${cat_name}[@]"
            ids_to_consider+=("${!ids_in_category_ref}")
        fi
    done
    
    SELECTED_IDS=("${ids_to_consider[@]}")
}