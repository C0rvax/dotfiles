#!/bin/bash

function select_installables_interactive {
    local selected_level
    
    if [[ "$ASSUME_YES" == "true" ]]; then
        selected_level="base" # Par défaut en non-interactif
        log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
    else
        print_table_header "INSTALLATION TYPE"
        print_left_element "1) Base (Minimal: core utils, dev tools, shell, nvim config)" "$BLUEHI"
        print_left_element "2) Full (Recommended: 'Base' + graphical apps, Docker, etc.)" "$BLUEHI"
        ask_question "Enter your choice [1-2]" choice

        case "$choice" in
            1) selected_level="base";;
            2) selected_level="full";;
            *) log "ERROR" "Invalid choice. Exiting."; print_table_line; exit 1;;
        esac
    fi

    # Construire la liste des IDs à installer
    local ids_to_consider=()
    for id in "${!INSTALLABLES_LEVEL[@]}"; do
        local level=${INSTALLABLES_LEVEL[$id]}
        if [[ "$level" == "base" ]]; then
            ids_to_consider+=("$id")
        elif [[ "$level" == "full" && "$selected_level" == "full" ]]; then
            ids_to_consider+=("$id")
        fi
    done

    # Gérer les paquets optionnels
    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" include_embedded
        if [[ "$include_embedded" =~ ^[yY]$ ]]; then
            for id in "${!INSTALLABLES_LEVEL[@]}"; do
                if [[ "${INSTALLABLES_LEVEL[$id]}" == "optional" && "${INSTALLABLES_CATEGORY[$id]}" == "C_EMBEDDED" ]]; then
                    ids_to_consider+=("$id")
                fi
            done
        fi

        ask_question "Include LibreOffice suite? [y/N]" include_office
        if [[ "$include_office" =~ ^[yY]$ ]]; then
            for id in "${!INSTALLABLES_LEVEL[@]}"; do
                if [[ "${INSTALLABLES_LEVEL[$id]}" == "optional" && "${INSTALLABLES_CATEGORY[$id]}" == "C_OFFICE" ]]; then
                    ids_to_consider+=("$id")
                fi
            done
        fi
    fi

    SELECTED_IDS=("${ids_to_consider[@]}")
}

function select_installables_tui {
    log "INFO" "Launching TUI package selector..."

    # Le TUI sélectionne par catégorie. On lui passe les titres.
    local category_titles=()
    declare -gA TITLE_TO_CAT_NAME_MAP # Pour retrouver le nom de la variable après sélection
    for category_info in "${CATEGORIES_ORDER[@]}"; do
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