#!/bin/bash

declare -gA INSTALL_STATUS

function print_system_info_row {
	local all_dots="............................................................"
	local items_to_print=()

	local distro_desc="Distribution"
	local distro_pad_len=$((42 - ${#distro_desc} - ${#DISTRO}))
	local distro_pad=${all_dots:0:$distro_pad_len}
	items_to_print+=("${distro_desc} ${distro_pad} ${DISTRO}" "$BLUE")

	local desktop_desc="Desktop Env"
	local desktop_pad_len=$((42 - ${#desktop_desc} - ${#DESKTOP}))
	local desktop_pad=${all_dots:0:$desktop_pad_len}
	items_to_print+=("${desktop_desc} ${desktop_pad} ${DESKTOP}" "$BLUE")

	print_grid 2 "${items_to_print[@]}"
}

function run_pre_install_audit {
	if [[ "$VERBOSE" == "true" ]]; then
    	log "INFO" "Running pre-installation audit..."
	fi
    local total_checks=${#INSTALLABLES_DESC[@]}
    # local current_check=0

    # Itérer sur tous les IDs d'installables définis
    for id in "${!INSTALLABLES_DESC[@]}"; do
        # ((current_check++))
        # show_progress "$current_check" "$total_checks" "$id" "Checking"

        if eval "${INSTALLABLES_CHECK[$id]}"; then
            INSTALL_STATUS[$id]="installed"
        else
            INSTALL_STATUS[$id]="missing"
        fi
    done
	if [[ "$VERBOSE" == "true" ]]; then
		log "SUCCESS" "Audit complete."
	fi   
}

function print_audit_content {
    for category_info in "${CATEGORIES_ORDER[@]}"; do
        local category_name="${category_info%%:*}"
        local category_title="${category_info#*:}"
        
        # Récupérer la liste des IDs de cette catégorie (en utilisant l'indirection de variable)
        local ids_in_category_ref="${category_name}[@]"
        local ids_in_category=("${!ids_in_category_ref}")

        # Ne pas afficher les catégories vides
        if [ ${#ids_in_category[@]} -eq 0 ]; then continue; fi

        # print_table_line
        print_center_element " $(echo "$category_title") " "$YELLOW"

        local packages_to_print=()
        for id in "${ids_in_category[@]}"; do
            local desc=${INSTALLABLES_DESC[$id]}
            if [[ "${INSTALL_STATUS[$id]}" == "installed" ]]; then
                packages_to_print+=("$desc" "$GREENHI")
            else
                packages_to_print+=("$desc" "$REDHI")
            fi
        done
        print_grid 4 "${packages_to_print[@]}"
    done
}


function run_audit_display {
	print_title_element "SYSTEM" "$BLUEHI"
	print_table_line
    print_system_info_row
    print_audit_content
    print_table_line
}

function show_installation_summary() {
    local selected_ids=("$@")
    local items_to_install=()

    # Filtrer pour ne garder que les items manquants
    for id in "${selected_ids[@]}"; do
        if [[ "${INSTALL_STATUS[$id]}" == "missing" ]]; then
            items_to_install+=("$id")
        fi
    done

    if [ ${#items_to_install[@]} -eq 0 ]; then
        log "SUCCESS" "Everything is already installed. Nothing to do."
        return 1 # Code spécial pour dire "rien à faire"
    fi

    print_table_header "INSTALLATION SUMMARY"
    print_left_element "Total items to install: ${#items_to_install[@]}" "$BLUEHI"
    print_left_element "Internet connection:      Required" "$BLUEHI"

    # Affichage groupé par catégorie
    for category_info in "${CATEGORIES_ORDER[@]}"; do
        local category_name="${category_info%%:*}"
        local category_title="${category_info#*:}"
        
        local items_in_this_category_for_grid=()
        for id in "${items_to_install[@]}"; do
            if [[ "${INSTALLABLES_CATEGORY[$id]}" == "$category_name" ]]; then
                items_in_this_category_for_grid+=("${INSTALLABLES_DESC[$id]}" "$GREEN")
            fi
        done

        if [ ${#items_in_this_category_for_grid[@]} -gt 0 ]; then
            print_center_element " $(echo "$category_title") " "$YELLOW"
            # print_grid 3 "${items_in_this_category_for_grid[@]}" # 3 colonnes pour la grille
			print_grid 4 "${items_in_this_category_for_grid[@]}" # 4 colonnes pour la grille
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

function show_progress() {
	local current="$1"
	local total="$2"
	local package="$3"
	local operation="${4:-Installing}"

	local percent=$((current * 100 / total))
	local filled=$((percent / 2))
	local empty=$((50 - filled))

	printf "\r\033[K"
	printf "["
	printf "%*s" "$filled" '' | tr ' ' '#'
	printf "%*s" "$empty" '' | tr ' ' '-'
	printf "] %3d%% (%d/%d) - %s: %s" "$percent" "$current" "$total" "$operation" "$package"
}