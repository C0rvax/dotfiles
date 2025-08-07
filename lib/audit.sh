#!/bin/bash

function audit_packages() {
    local silent_mode=false
    if [[ "$1" == "silent" ]]; then
        silent_mode=true
    fi

    local installed=0
    local missing=0

    # On n'affiche le titre que si on n'est pas en mode silencieux
    if [[ "$silent_mode" == "false" ]]; then
        print_title_element "SYSTEM" "$BLUEHI"
        print_table_line
        print_system_info_row
    fi

    mapfile -t all_packages < <(get_all_packages)
    local total=${#all_packages[@]}

    for cat in "${CATEGORIES[@]}"; do
        local category_name="${cat%%:*}"
        local category_title="${cat#*:}"

        if [[ "$silent_mode" == "false" ]]; then
            print_center_element "$category_title" "$YELLOW"
        fi

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
            else
                ((missing++))
                AUDIT_STATUS[$id]="missing"
                packages_to_print+=("$desc" "$REDHI")
            fi
        done
        
        if [[ "$silent_mode" == "false" ]]; then
            print_grid 4 "${packages_to_print[@]}"
        fi
    done

    if [[ "$silent_mode" == "false" ]]; then
        print_table_line
        log "SUCCESS" "Audit finished : $installed installed, $missing missing."
        print_table_line
    fi
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
