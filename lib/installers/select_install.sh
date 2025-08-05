# #!/bin/bash

# function select_pak_interactive {
#     print_center_element "INSTALLATION TYPE" "$BLUEHI"
#     print_table_line
#     local packages_to_process=()
#     local install_type_choice
#     if [[ "$ASSUME_YES" == "true" ]]; then
#         install_type_choice="2"  # Default to 'Light' installation in non-interactive mode
#         log "INFO" "Non-interactive mode: Defaulting to a 'Light' installation."
#     else
#         log "INFO" "Select installation type:"
#         print_left_element "1) Full (Recommended: everything for a complete dev environment)" "$BLUEHI"
#         print_left_element "2) Light (Minimal: core utils, dev tools, shell, nvim)" "$BLUEHI"
#         ask_question "Enter your choice [1-2]" install_type_choice
#     fi

#     case $install_type_choice in
#         1) packages_to_process=("${FULL_PKGS[@]}");;
#         2) packages_to_process=("${LIGHT_PKGS[@]}");;
#         *) log "ERROR" "Invalid choice. Exiting."; print_table_line; exit 1;;
#     esac

#     if [[ "$ASSUME_YES" != "true" ]]; then
#         ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" include_embedded
#         if [[ "$include_embedded" == "y" || "$include_embedded" == "Y" || "$include_embedded" == "o" || "$include_embedded" == "O" ]]; then
#             packages_to_process+=("${PKGS_EMBEDDED[@]}")
#         fi
#     fi
#     if [[ "$install_type_choice" == "1" ]]; then
#         read -p "Do you want to include LibreOffice? [y/n]: " include_libreoffice
#         if [[ "$include_libreoffice" == "y" || "$include_libreoffice" == "Y" ]]; then
#             packages_to_process+=("${PKGS_OFFICE[@]}")
#         fi
#     fi

#     for pkg in "${packages_to_process[@]}"; do
#         if [[ ! $pkg == "#"* ]]; then
#             INSTALL_LIST+=("$pkg")
#         fi
#     done
# }

# function select_pak_tui {
#     log "INFO" "Launching TUI package selector..."

#     # Prepare the list of descriptions for the C program
#     local category_descriptions=()
#     for category_info in "${PACKAGE_CATEGORIES[@]}"; do
#         category_descriptions+=("${category_info#*:}")
#     done

#     # Check if the selector is compiled, if not, try to compile it
#     if [ ! -x ./selector ]; then
#         log "WARNING" "The 'selector' program is not compiled. Attempting compilation..."
#         # Add checks for dependencies
#         if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncurses; then
#             log "ERROR" "Failed to compile 'selector'. Aborting."
#             log "INFO" "Check that 'gcc' and 'libncurses-dev' are installed."
#             print_table_line
#             exit 1
#         else
#             log "SUCCESS" "Compilation of 'selector' succeeded."
#         fi
#     fi

#     local selected_output
#     selected_output=$(./selector "${category_descriptions[@]}")
    
#     local selected_descriptions=()
#     mapfile -t selected_descriptions <<< "$selected_output"

#     # If the array is empty, it means the user didn't select anything or exited.
#     if [ ${#selected_descriptions[@]} -eq 0 ]; then
#         log "WARNING" "No package selected or operation cancelled. Exiting."
#         return 0
#     fi

#     # Build the final list of packages to install
#     for selected_desc in "${selected_descriptions[@]}"; do
#         for category_info in "${PACKAGE_CATEGORIES[@]}"; do
#             if [[ "$category_info" == *:"$selected_desc" ]]; then
#                 local category_array_name="${category_info%%:*}"
#                 local packages_to_add=("${!category_array_name}")
#                 for pkg in "${packages_to_add[@]}"; do
#                     if [[ ! $pkg == "#"* ]]; then
#                         INSTALL_LIST+=("$pkg")
#                     fi
#                 done
#                 break 
#             fi
#         done
#     done
# }

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

    # La fonction "retourne" la liste des IDs en l'affichant sur stdout.
    # Le script principal la capturera.
    printf "%s\n" "${ids_to_consider[@]}"
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
    
    printf "%s\n" "${ids_to_consider[@]}"
}