#!/bin/bash

declare -gA MISSING_PACKAGES_MAP

function print_packages_content {
	declare -A categories
	declare -a ordered_categories
	declare -A seen_categories
	local all_packages_source=(
		"${PKGS_CORE_UTILS[@]}"
		"${PKGS_UTILS[@]}"
		"${PKGS_DEV[@]}"
		"${PKGS_SHELL[@]}"
		"${PKGS_NVIM[@]}"
		"${PKGS_APPS[@]}"
		"${PKGS_OFFICE[@]}"
		"${PKGS_EMBEDDED[@]}"
	)

	local current_category=""
	for item in "${all_packages_source[@]}"; do
		if [[ $item == '#'* ]]; then
			current_category="$item"
			if [[ -z "${seen_categories[$current_category]}" ]]; then
				ordered_categories+=("$current_category")
				seen_categories["$current_category"]=1
			fi
		elif [[ -n "$current_category" ]]; then
			categories["$current_category"]+="$item "
		fi
	done

	local master_list=()
	for category in "${ordered_categories[@]}"; do
		master_list+=("$category")
		local packages_str=${categories["$category"]}
		local packages_array=( $(printf "%s\n" $packages_str | sort -u) )
		master_list+=("${packages_array[@]}")
	done

	local current_packages_to_print=()
	local is_first_category=true
	for item in "${master_list[@]}"; do
		if [[ $item == '#'* ]]; then
			if [ ${#current_packages_to_print[@]} -gt 0 ]; then
				print_grid 4 "${current_packages_to_print[@]}"
				current_packages_to_print=()
			fi

			if [ "$is_first_category" = false ]; then
				print_table_line
			fi

			local category_title
			printf -v category_title ">> %s" "$(echo "$item" | sed -e 's/# --- //' -e 's/ ---//')"
			print_left_element "$category_title" "$YELLOW"

			is_first_category=false
		else
			check_package "$item"
			if [ $? -eq 0 ]; then
				current_packages_to_print+=("$item" "$GREENHI")
			else
				current_packages_to_print+=("$item" "$REDHI")
				MISSING_PACKAGES_MAP["$item"]=1
			fi
		fi
	done

	if [ ${#current_packages_to_print[@]} -gt 0 ]; then
		print_grid 4 "${current_packages_to_print[@]}"
	fi
}

function print_configurations_content {
	local checks=(
		"Oh My Zsh" "check_directory '$HOME/.oh-my-zsh'"
		"Zsh Custom Config" "check_directory '$HOME/.zsh'"
		"Nvim Config" "check_directory '$HOME/.config/nvim'"
		"Nvim AppImage" "check_file '$HOME/AppImage/nvim.appimage'"
		"MesloLGS Fonts" "check_file '$HOME/Themes/Fonts/MesloLGS NF Regular.ttf'"
		"Buuf Nestort Icons" "check_directory '$HOME/Themes/Icons/buuf-nestort'"
		"Docker" "check_package 'docker-ce'"
		"Git User Name" "git config --global user.name >/dev/null 2>&1"
		"Git User Email" "git config --global user.email >/dev/null 2>&1"
		"SSH Key (ed25519)" "check_file '$HOME/.ssh/id_ed25519'"
	)

	local items_to_print=()
	local all_dots="............................................................"
	for i in $(seq 0 2 $((${#checks[@]} - 1))); do
		local description=${checks[i]}
		local check_command=${checks[i + 1]}
		local text_to_print color

		local dot_padding_len=$((42 - ${#description} - 2))
		local dot_padding=${all_dots:0:$dot_padding_len}

		if eval "$check_command"; then
			text_to_print="${description} ${dot_padding} [✔]"
			color=$GREENHI
		else
			text_to_print="${description} ${dot_padding} [✘]"
			color=$REDHI
		fi
		items_to_print+=("$text_to_print" "$color")
	done

	print_grid 2 "${items_to_print[@]}"
}

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

function run_audit {
	detect_distro
	detect_desktop

	print_table_header "SYSTEM AUDIT"

	print_system_info_row

	print_table_line
	print_packages_content

	print_table_line
	print_configurations_content

	print_table_line
}

function print_summary_row {
	local label_text="$1"
	local value_text="$2"
	local label_color="${3:-$RESET}"
	local value_color="${4:-$RESET}"

	local formatted_label="${label_color}${label_text}${RESET}"
	local formatted_value="${value_color}${value_text}${RESET}"

	local total_visible_len=$((2 + ${#label_text} + 1 + ${#value_text} + 2))

	local padding_space=$((TABLE_WIDTH - total_visible_len))
	if ((padding_space < 0)); then padding_space=0; fi

	printf "| %b %b%*s |\n" \
		"$formatted_label" \
		"$formatted_value" \
		"$padding_space" \
		""
}

# function show_installation_summary() {
# 	local packages=("$@")

# 	print_table_header "INSTALLATION SUMMARY"
# 	print_summary_row "Total packages to install:" "${#packages[@]}" "$BLUEHI" "$GREENHI"
# 	print_summary_row "Internet connection:" "Required" "$BLUEHI" "$REDHI"
# 	if [ ${#packages[@]} -gt 0 ]; then
# 		print_left_element "The following packages will be installed:" "$BLUEHI"
# 		local packages_for_grid=()
# 		for pkg in "${packages[@]}"; do
# 			packages_for_grid+=("$pkg" "$GREEN")
# 		done

# 		print_grid 4 "${packages_for_grid[@]}"
# 		print_table_line
# 	fi
# 	if [[ "$ASSUME_YES" != "true" ]]; then
# 		ask_question "Do you want to continue? [y/N]: " confirm
# 		[[ "$confirm" =~ ^[yY]$ ]]
# 	fi
# }

function show_installation_summary() {
    local items_with_structure=("$@")
    local packages_to_install=()
    local categories_in_summary=()

    # On ne compte que les vrais paquets, pas les en-têtes de catégorie
    for item in "${items_with_structure[@]}"; do
        if [[ ! $item == '#'* ]]; then
            packages_to_install+=("$item")
        fi
    done

    print_table_header "INSTALLATION SUMMARY"
    print_left_element "Total packages to install: ${#packages_to_install[@]}" "$BLUEHI"
    print_left_element "Internet connection:       Required" "$REDHI"

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        print_left_element "The following packages will be installed:" "$BLUEHI"

        local current_packages_for_grid=()
        for item in "${items_with_structure[@]}"; do
            if [[ $item == '#'* ]]; then
                # Si on a des paquets en attente, on les affiche avant le nouveau titre
                if [ ${#current_packages_for_grid[@]} -gt 0 ]; then
                    print_grid 4 "${current_packages_for_grid[@]}"
                    current_packages_for_grid=()
                fi
                # Affiche le titre de la catégorie
                local category_title
                printf -v category_title ">> %s" "$(echo "$item" | sed -e 's/# --- //' -e 's/ ---//')"
                print_left_element "$category_title" "$YELLOW"
            else
                current_packages_for_grid+=("$item" "$GREEN")
            fi
        done
        # Afficher les paquets restants de la dernière catégorie
        if [ ${#current_packages_for_grid[@]} -gt 0 ]; then
            print_grid 4 "${current_packages_for_grid[@]}"
        fi
        print_table_line
    fi

    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Do you want to continue? [y/N]: " confirm
        [[ "$confirm" =~ ^[yY]$ ]]
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

	printf "\r\033[K" # Efface la ligne
	printf "["
	# printf "%*s" "$filled" '' | tr ' ' '█'
	# printf "%*s" "$empty" '' | tr ' ' '░'
	printf "%*s" "$filled" '' | tr ' ' '#'
	printf "%*s" "$empty" '' | tr ' ' '-'
	printf "] %3d%% (%d/%d) - %s: %s" "$percent" "$current" "$total" "$operation" "$package"
}
