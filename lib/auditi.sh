#!/bin/bash

function audit_packages() {
    local installed=0
    local missing=0

    print_title_element "SYSTEM" "$BLUEHI"
	print_table_line
    print_system_info_row

    mapfile -t all_packages < <(get_all_packages)
    local total=${#all_packages[@]}

    for cat in "${CATEGORIES[@]}"; do
        local category_name="${cat%%:*}"
        local category_title="${cat#*:}"

        print_center_element "$category_title" "$YELLOW"

        mapfile -t packages_to_install < <(get_packages_by_category "$category_name")

        local packages_to_print=()
        for pkg_def in "${packages_to_install[@]}"; do
            local id; id=$(get_package_info "$pkg_def" id)
            local desc; desc=$(get_package_info "$pkg_def" desc)
            local check_cmd; check_cmd=$(get_package_info "$pkg_def" check)

            if eval "$check_cmd" &>/dev/null; then
                ((installed++))
                AUDIT_STATUS[$id]="installed"
                packages_to_print+=("$desc" "$GREENHI")
                #print_left_element "✓ $desc" "$GREEN"
            else
                ((missing++))
                AUDIT_STATUS[$id]="missing"
                # packages_to_print+=("✗ $desc" "$REDHI")
                packages_to_print+=("$desc" "$REDHI")

            fi
        done
        print_grid 4 "${packages_to_print[@]}"
    done
    print_table_line
    log "SUCCESS" "Audit finished : $installed installed, $missing missing."
    print_table_line
}

function show_installation_summary() {
    local items_to_install=("$@")

    if [ ${#items_to_install[@]} -eq 0 ]; then
        log "SUCCESS" "Everything is already installed. Nothing to do."
        return 1
    fi

    print_table_header "INSTALLATION SUMMARY"
    print_left_element "Total items to install: ${#items_to_install[@]}" "$BLUEHI"
    print_left_element "Internet connection:      Required" "$BLUEHI"

    for cat in "${CATEGORIES[@]}"; do
        local category_id="${cat%%:*}"
        local category_title="${cat#*:}"

        local items_in_this_category_for_grid=()
        
        for pkg_def in "${items_to_install[@]}"; do
            # ...on vérifie s'il appartient à la catégorie actuelle.
            if [[ "$(get_package_info "$pkg_def" category)" == "$category_id" ]]; then
                items_in_this_category_for_grid+=("$(get_package_info "$pkg_def" desc)" "$GREEN")
            fi
        done

        if [ ${#items_in_this_category_for_grid[@]} -gt 0 ]; then
            print_center_element " $(echo "$category_title") " "$YELLOW"
            print_grid 4 "${items_in_this_category_for_grid[@]}"
        fi
    done
    print_table_line
    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Do you want to continue? [y/N]: " confirm
        [[ "$confirm" =~ ^[yY]$ ]]
    else
        return 0
    fi
}

install_selected_packages() {
    local packages=("$@")
    local current=0
    local total=${#packages[@]}
    
    echo "Installation en cours..."
    
    for pkg_def in "${packages[@]}"; do
        ((current++))
        local id=$(get_package_info "$pkg_def" id)
        local desc=$(get_package_info "$pkg_def" desc)
        local check_cmd=$(get_package_info "$pkg_def" check)
        local install_cmd=$(get_package_info "$pkg_def" install)
        
        printf "[%d/%d] %s... " "$current" "$total" "$desc"
        
        if eval "$install_cmd" 2>/dev/null; then
            echo "✓"
        else
            echo "✗ échec"
        fi
    done
}

# === WORKFLOW PRINCIPAL ===

function run_package_installation() {
    audit_packages

    local packages_to_install=()
    case "$SELECT_MODE" in
        tui)
            mapfile -t packages_to_install < <(select_base_packages_tui)
            ;;
        interactive)
            mapfile -t packages_to_install < <(select_base_packages)
            local optional_packages
            if [[ "$ASSUME_YES" != "true" ]]; then
                mapfile -t optional_packages < <(select_optional_packages)
                if [[ ${#optional_packages[@]} -gt 0 ]]; then
                    packages_to_install+=("${optional_packages[@]}")
                fi
            fi
            ;;
        *)
            log "ERROR" "Invalid selection mode: '$SELECT_MODE'. Use 'tui' or 'interactive'."
            exit 1
            ;;
    esac

    #echo "Packages sélectionnés pour l'installation : ${packages_to_install[@]}"
    local uninstalled_packages=()
    for item in "${packages_to_install[@]}"; do
        if [[ -z "$item" ]]; then continue; fi # Sécurité pour ignorer les lignes vides
        local id; id=$(get_package_info "$item" id)
        if [[ "${AUDIT_STATUS[$id]}" == "missing" ]]; then
            uninstalled_packages+=("$item")
        fi
    done

    if ! show_installation_summary "${uninstalled_packages[@]}"; then
        log "INFO" "No packages selected for installation. Exiting."
        print_table_line
        exit 0
    fi

    install_selected_packages "${uninstalled_packages[@]}"
}