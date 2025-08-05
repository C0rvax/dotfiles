# #!/bin/bash

# declare -gA MISSING_PACKAGES_MAP

# function print_packages_content {
# 	declare -A categories
# 	declare -a ordered_categories
# 	declare -A seen_categories
# 	local all_packages_source=(
# 		"${PKGS_CORE_UTILS[@]}"
# 		"${PKGS_UTILS[@]}"
# 		"${PKGS_DEV[@]}"
# 		"${PKGS_SHELL[@]}"
# 		"${PKGS_NVIM[@]}"
# 		"${PKGS_APPS[@]}"
# 		"${PKGS_OFFICE[@]}"
# 		"${PKGS_EMBEDDED[@]}"
# 	)

# 	local current_category=""
# 	for item in "${all_packages_source[@]}"; do
# 		if [[ $item == '#'* ]]; then
# 			current_category="$item"
# 			if [[ -z "${seen_categories[$current_category]}" ]]; then
# 				ordered_categories+=("$current_category")
# 				seen_categories["$current_category"]=1
# 			fi
# 		elif [[ -n "$current_category" ]]; then
# 			categories["$current_category"]+="$item "
# 		fi
# 	done

# 	local master_list=()
# 	for category in "${ordered_categories[@]}"; do
# 		master_list+=("$category")
# 		local packages_str=${categories["$category"]}
# 		local packages_array=( $(printf "%s\n" $packages_str | sort -u) )
# 		master_list+=("${packages_array[@]}")
# 	done

# 	local current_packages_to_print=()
# 	local is_first_category=true
# 	for item in "${master_list[@]}"; do
# 		if [[ $item == '#'* ]]; then
# 			if [ ${#current_packages_to_print[@]} -gt 0 ]; then
# 				print_grid 4 "${current_packages_to_print[@]}"
# 				current_packages_to_print=()
# 			fi

# 			if [ "$is_first_category" = false ]; then
# 				print_table_line
# 			fi

# 			local category_title
# 			printf -v category_title ">> %s" "$(echo "$item" | sed -e 's/# --- //' -e 's/ ---//')"
# 			print_left_element "$category_title" "$YELLOW"

# 			is_first_category=false
# 		else
# 			check_package "$item"
# 			if [ $? -eq 0 ]; then
# 				current_packages_to_print+=("$item" "$GREENHI")
# 			else
# 				current_packages_to_print+=("$item" "$REDHI")
# 				MISSING_PACKAGES_MAP["$item"]=1
# 			fi
# 		fi
# 	done

# 	if [ ${#current_packages_to_print[@]} -gt 0 ]; then
# 		print_grid 4 "${current_packages_to_print[@]}"
# 	fi
# }

# function print_configurations_content {
# 	local checks=(
# 		"Oh My Zsh" "check_directory '$HOME/.oh-my-zsh'"
# 		"Zsh Custom Config" "check_directory '$HOME/.zsh'"
# 		"Nvim Config" "check_directory '$HOME/.config/nvim'"
# 		"Nvim AppImage" "check_file '$HOME/AppImage/nvim.appimage'"
# 		"MesloLGS Fonts" "check_file '$HOME/Themes/Fonts/MesloLGS NF Regular.ttf'"
# 		"Buuf Nestort Icons" "check_directory '$HOME/Themes/Icons/buuf-nestort'"
# 		"Docker" "check_package 'docker-ce'"
# 		"Git User Name" "git config --global user.name >/dev/null 2>&1"
# 		"Git User Email" "git config --global user.email >/dev/null 2>&1"
# 		"SSH Key (ed25519)" "check_file '$HOME/.ssh/id_ed25519'"
# 	)

# 	local items_to_print=()
# 	local all_dots="............................................................"
# 	for i in $(seq 0 2 $((${#checks[@]} - 1))); do
# 		local description=${checks[i]}
# 		local check_command=${checks[i + 1]}
# 		local text_to_print color

# 		local dot_padding_len=$((42 - ${#description} - 2))
# 		local dot_padding=${all_dots:0:$dot_padding_len}

# 		if eval "$check_command"; then
# 			text_to_print="${description} ${dot_padding} [✔]"
# 			color=$GREENHI
# 		else
# 			text_to_print="${description} ${dot_padding} [✘]"
# 			color=$REDHI
# 		fi
# 		items_to_print+=("$text_to_print" "$color")
# 	done

# 	print_grid 2 "${items_to_print[@]}"
# }

# function print_system_info_row {
# 	local all_dots="............................................................"
# 	local items_to_print=()

# 	local distro_desc="Distribution"
# 	local distro_pad_len=$((42 - ${#distro_desc} - ${#DISTRO}))
# 	local distro_pad=${all_dots:0:$distro_pad_len}
# 	items_to_print+=("${distro_desc} ${distro_pad} ${DISTRO}" "$BLUE")

# 	local desktop_desc="Desktop Env"
# 	local desktop_pad_len=$((42 - ${#desktop_desc} - ${#DESKTOP}))
# 	local desktop_pad=${all_dots:0:$desktop_pad_len}
# 	items_to_print+=("${desktop_desc} ${desktop_pad} ${DESKTOP}" "$BLUE")

# 	print_grid 2 "${items_to_print[@]}"
# }

# function run_audit {
# 	detect_distro
# 	detect_desktop

# 	print_table_header "SYSTEM AUDIT"

# 	print_system_info_row

# 	print_table_line
# 	print_packages_content

# 	print_table_line
# 	print_configurations_content

# 	print_table_line
# }

# function print_summary_row {
# 	local label_text="$1"
# 	local value_text="$2"
# 	local label_color="${3:-$RESET}"
# 	local value_color="${4:-$RESET}"

# 	local formatted_label="${label_color}${label_text}${RESET}"
# 	local formatted_value="${value_color}${value_text}${RESET}"

# 	local total_visible_len=$((2 + ${#label_text} + 1 + ${#value_text} + 2))

# 	local padding_space=$((TABLE_WIDTH - total_visible_len))
# 	if ((padding_space < 0)); then padding_space=0; fi

# 	printf "| %b %b%*s |\n" \
# 		"$formatted_label" \
# 		"$formatted_value" \
# 		"$padding_space" \
# 		""
# }

# # function show_installation_summary() {
# # 	local packages=("$@")

# # 	print_table_header "INSTALLATION SUMMARY"
# # 	print_summary_row "Total packages to install:" "${#packages[@]}" "$BLUEHI" "$GREENHI"
# # 	print_summary_row "Internet connection:" "Required" "$BLUEHI" "$REDHI"
# # 	if [ ${#packages[@]} -gt 0 ]; then
# # 		print_left_element "The following packages will be installed:" "$BLUEHI"
# # 		local packages_for_grid=()
# # 		for pkg in "${packages[@]}"; do
# # 			packages_for_grid+=("$pkg" "$GREEN")
# # 		done

# # 		print_grid 4 "${packages_for_grid[@]}"
# # 		print_table_line
# # 	fi
# # 	if [[ "$ASSUME_YES" != "true" ]]; then
# # 		ask_question "Do you want to continue? [y/N]: " confirm
# # 		[[ "$confirm" =~ ^[yY]$ ]]
# # 	fi
# # }

# function show_installation_summary() {
#     local items_with_structure=("$@")
#     local packages_to_install=()
#     local categories_in_summary=()

#     # On ne compte que les vrais paquets, pas les en-têtes de catégorie
#     for item in "${items_with_structure[@]}"; do
#         if [[ ! $item == '#'* ]]; then
#             packages_to_install+=("$item")
#         fi
#     done

#     print_table_header "INSTALLATION SUMMARY"
#     print_left_element "Total packages to install: ${#packages_to_install[@]}" "$BLUEHI"
#     print_left_element "Internet connection:       Required" "$REDHI"

#     if [ ${#packages_to_install[@]} -gt 0 ]; then
#         print_left_element "The following packages will be installed:" "$BLUEHI"

#         local current_packages_for_grid=()
#         for item in "${items_with_structure[@]}"; do
#             if [[ $item == '#'* ]]; then
#                 # Si on a des paquets en attente, on les affiche avant le nouveau titre
#                 if [ ${#current_packages_for_grid[@]} -gt 0 ]; then
#                     print_grid 4 "${current_packages_for_grid[@]}"
#                     current_packages_for_grid=()
#                 fi
#                 # Affiche le titre de la catégorie
#                 local category_title
#                 printf -v category_title ">> %s" "$(echo "$item" | sed -e 's/# --- //' -e 's/ ---//')"
#                 print_left_element "$category_title" "$YELLOW"
#             else
#                 current_packages_for_grid+=("$item" "$GREEN")
#             fi
#         done
#         # Afficher les paquets restants de la dernière catégorie
#         if [ ${#current_packages_for_grid[@]} -gt 0 ]; then
#             print_grid 4 "${current_packages_for_grid[@]}"
#         fi
#         print_table_line
#     fi

#     if [[ "$ASSUME_YES" != "true" ]]; then
#         ask_question "Do you want to continue? [y/N]: " confirm
#         [[ "$confirm" =~ ^[yY]$ ]]
#     fi
# }

# function show_progress() {
# 	local current="$1"
# 	local total="$2"
# 	local package="$3"
# 	local operation="${4:-Installing}"

# 	local percent=$((current * 100 / total))
# 	local filled=$((percent / 2))
# 	local empty=$((50 - filled))

# 	printf "\r\033[K" # Efface la ligne
# 	printf "["
# 	# printf "%*s" "$filled" '' | tr ' ' '█'
# 	# printf "%*s" "$empty" '' | tr ' ' '░'
# 	printf "%*s" "$filled" '' | tr ' ' '#'
# 	printf "%*s" "$empty" '' | tr ' ' '-'
# 	printf "] %3d%% (%d/%d) - %s: %s" "$percent" "$current" "$total" "$operation" "$package"
# }
#!/bin/bash


declare -gA INSTALL_STATUS

function run_pre_install_audit {
    log "INFO" "Running pre-installation audit..."
    local total_checks=${#INSTALLABLES_DESC[@]}
    local current_check=0

    # Itérer sur tous les IDs d'installables définis
    for id in "${!INSTALLABLES_DESC[@]}"; do
        ((current_check++))
        show_progress "$current_check" "$total_checks" "$id" "Checking"

        if eval "${INSTALLABLES_CHECK[$id]}"; then
            INSTALL_STATUS[$id]="installed"
        else
            INSTALL_STATUS[$id]="missing"
        fi
    done
    echo # Saut de ligne après la barre de progression
    log "SUCCESS" "Audit complete."
}

# La fonction d'affichage de l'audit est maintenant plus générique
function print_audit_content {
    for category_info in "${CATEGORIES_ORDER[@]}"; do
        local category_name="${category_info%%:*}"
        local category_title="${category_info#*:}"
        
        # Récupérer la liste des IDs de cette catégorie (en utilisant l'indirection de variable)
        local ids_in_category_ref="${category_name}[@]"
        local ids_in_category=("${!ids_in_category_ref}")

        # Ne pas afficher les catégories vides
        if [ ${#ids_in_category[@]} -eq 0 ]; then continue; fi

        print_table_line
        print_left_element ">> $(echo "$category_title" | sed 's/--- //g')" "$YELLOW"

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
    detect_distro
    detect_desktop

    print_table_header "SYSTEM AUDIT"
    print_system_info_row
    print_audit_content # Appel de la nouvelle fonction d'affichage
    print_table_line
    # La partie "Configurations" est maintenant intégrée dans l'audit principal
    # print_configurations_content
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
    print_left_element "Internet connection:      Required" "$REDHI"
    print_table_line

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
            print_left_element ">> $(echo "$category_title" | sed 's/--- //g')" "$YELLOW"
            print_grid 3 "${items_in_this_category_for_grid[@]}" # 3 colonnes pour plus de lisibilité
        fi
    done
    print_table_line

    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Do you want to continue? [y/N]: " confirm
        [[ "$confirm" =~ ^[yY]$ ]]
    else
        # En mode -y, on continue automatiquement
        return 0
    fi
}

# show_progress est inchangé
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