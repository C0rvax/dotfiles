#!/bin/bash

function select_pak_interactive {
    print_center_element "INSTALLATION TYPE" "$BLUEHI"
    print_table_line
    local packages_to_process=()
    local install_type_choice
    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type_choice="1"
        log "INFO" "Non-interactive mode: Defaulting to a 'Full' installation."
    else
        log "INFO" "Select installation type:"
        print_left_element "1) Full (Recommended: everything for a complete dev environment)" "$BLUEHI"
        print_left_element "2) Light (Minimal: core utils, dev tools, shell, nvim)" "$BLUEHI"
        ask_question "Enter your choice [1-2]" install_type_choice
    fi

    case $install_type_choice in
        1) packages_to_process=("${FULL_PKGS[@]}");;
        2) packages_to_process=("${LIGHT_PKGS[@]}");;
        *) log "ERROR" "Invalid choice. Exiting."; print_table_line; exit 1;;
    esac

    # read -p "Do you want to include EMBEDDED packages? [y/n]: " include_embedded
    ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" include_embedded
    if [[ "$include_embedded" == "y" || "$include_embedded" == "Y" || "$include_embedded" == "o" || "$include_embedded" == "O" ]]; then
        packages_to_process+=("${PKGS_EMBEDDED[@]}")
    fi

    if [[ "$install_type_choice" == "1" ]]; then
        read -p "Do you want to include LibreOffice? [y/n]: " include_libreoffice
        if [[ "$include_libreoffice" == "y" || "$include_libreoffice" == "Y" ]]; then
            packages_to_process+=("${PKGS_OFFICE[@]}")
        fi
    fi

    for pkg in "${packages_to_process[@]}"; do
        if [[ ! $pkg == "#"* ]]; then
            INSTALL_LIST+=("$pkg")
        fi
    done
}

function select_pak_tui {
    log "INFO" "Launching TUI package selector..."

    # Prepare the list of descriptions for the C program
    local category_descriptions=()
    for category_info in "${PACKAGE_CATEGORIES[@]}"; do
        category_descriptions+=("${category_info#*:}")
    done

    # Check if the selector is compiled, if not, try to compile it
    if [ ! -x ./selector ]; then
        log "WARNING" "The 'selector' program is not compiled. Attempting compilation..."
        # Add checks for dependencies
        if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncurses; then
            log "ERROR" "Failed to compile 'selector'. Aborting."
            log "INFO" "Check that 'gcc' and 'libncurses-dev' are installed."
            print_table_line
            exit 1
        else
            log "SUCCESS" "Compilation of 'selector' succeeded."
        fi
    fi

    local selected_output
    selected_output=$(./selector "${category_descriptions[@]}")
    
    local selected_descriptions=()
    mapfile -t selected_descriptions <<< "$selected_output"

    # If the array is empty, it means the user didn't select anything or exited.
    if [ ${#selected_descriptions[@]} -eq 0 ]; then
        log "WARNING" "No package selected or operation cancelled. Exiting."
        return 0
    fi

    # Build the final list of packages to install
    for selected_desc in "${selected_descriptions[@]}"; do
        for category_info in "${PACKAGE_CATEGORIES[@]}"; do
            if [[ "$category_info" == *:"$selected_desc" ]]; then
                local category_array_name="${category_info%%:*}"
                local packages_to_add=("${!category_array_name}")
                for pkg in "${packages_to_add[@]}"; do
                    if [[ ! $pkg == "#"* ]]; then
                        INSTALL_LIST+=("$pkg")
                    fi
                done
                break 
            fi
        done
    done
}