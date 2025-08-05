#!/bin/bash

function display_logo {
	local max_width=0
	local temp_logo_lines=()

	while IFS= read -r line; do
		temp_logo_lines+=("$line")
		if [[ ${#line} -gt max_width ]]; then
			max_width=${#line}
		fi
	done <<< "${LOGO[0]}"

	local left_padding=$(((TABLE_WIDTH - max_width - 2) / 2))
	[[ $left_padding -lt 1 ]] && left_padding=1

	print_table_line

	for line in "${temp_logo_lines[@]}"; do
		if [[ -z "$line" ]]; then # Si la ligne est vide, on affiche une ligne vide
			printf "|%*s|\n" $((TABLE_WIDTH - 2)) ""
			continue
		fi

		local right_padding=$((TABLE_WIDTH - left_padding - ${#line} - 2))
		[[ $right_padding -lt 0 ]] && right_padding=0

		printf "|"
		printf "%*s" $left_padding ""
		echo -e -n "$line"
		printf "%*s" $right_padding ""
		printf "|\n"
	done

	print_table_line
}

function print_table_line {
	printf "+%.0s" $(seq 1 $((TABLE_WIDTH)))
	printf "\n"
}

get_display_width() {
    local str="$1"
    local clean_str=$(printf '%s' "$str" | sed 's/\x1b\[[0-9;]*m//g')
    local base_length=$(printf '%s' "$clean_str" | wc -m)
    local info_count=$(printf '%s' "$clean_str" | grep -o -E '[⏭️ℹ️⚠️]' | wc -l 2>/dev/null || echo 0)
    local error_count=$(printf '%s' "$clean_str" | grep -o -E '[✅📦📥❌❓]' | wc -l 2>/dev/null || echo 0)	
	if (( info_count > 0 )); then
		echo $((base_length - info_count - 1))
	elif (( error_count > 0 )); then
		echo $((base_length - error_count + 2))
	else
		echo $((base_length))
	fi
}

function print_center_element {
	local text="$1"
	local color="$2"
	local visible_len=$(get_display_width "$text")
	local padding=$(((TABLE_WIDTH - visible_len - 2) / 2))
	local remainder=$(((TABLE_WIDTH - visible_len - 2) % 2))

	printf "|"
	printf " %.0s" $(seq 1 $padding)
	echo -e -n "${color}${text}${RESET}"
	printf " %.0s" $(seq 1 $((padding + remainder)))
	printf "|\n"
}

function print_left_element {
	local text="$1"
	local color="$2"
	local visible_len=$(get_display_width "$text")
	local padding=$((TABLE_WIDTH - visible_len - 3))

	printf "|"
	echo -e -n " ${color}${text}${RESET}"
	printf " %.0s" $(seq 1 $padding)
	printf "|\n"
}

# function ask_question {
#     local question="$1"
#     local -n result_var="$2" # -n (nameref) pour passer le nom de la variable de retour
    
#     local formatted_prompt="| ${YELLOWHI}❓ ${question}${RESET} "
    
#     # On utilise read sans -p, après avoir affiché notre propre prompt formaté.
#     printf "%b" "$formatted_prompt"
#     read -r result_var
# }

function ask_question {
    local question="$1"
    local -n result_var="$2"
    
    local response=""
    
    # Boucle de lecture caractère par caractère
    while true; do
        local prompt_text="❓ ${question}: "
        
        local prompt_len
        prompt_len=$(get_display_width "$prompt_text")

        local response_len=${#response}

        printf "\r\033[K| %b" "${YELLOWHI}${prompt_text}${RESET}"
        printf "%s" "$response"
        
        # On calcule et affiche le padding
        local padding=$((TABLE_WIDTH - prompt_len - response_len - 3))
        if (( padding < 0 )); then padding=0; fi
        printf "%*s|" "$padding" ""

        printf "\r\033[%dC" $((2 + prompt_len + response_len))

        # Lire un seul caractère
        read -s -r -n 1 key

        if [[ $key == "" ]]; then # Si la touche est vide (entrée)
            break
        elif [[ $key == $'\x7f' ]]; then # Touche Retour arrière (Backspace)
            if [ -n "$response" ]; then
                response="${response%?}"
            fi
        else
            response+="$key"
        fi
    done
    
    # Un saut de ligne final pour que le prompt suivant soit propre
    echo ""
    result_var="$response"
}

function print_table_header {
	local title=$1

	print_table_line
	print_center_element "$title" "$BLUEHI"
	print_table_line
}

function print_grid {
	local num_cols=$1
	shift
	local items_with_colors=("$@")

	local col_content_width=$(((TABLE_WIDTH) / num_cols - 3))

	for i in $(seq 0 $((num_cols * 2)) $((${#items_with_colors[@]} - 1))); do
		local line_to_print="|"
		for j in $(seq 0 $((num_cols - 1))); do
			local text_idx=$((i + j * 2))
			local color_idx=$((text_idx + 1))

			local text=${items_with_colors[text_idx]:-""}
			local color=${items_with_colors[color_idx]:-$RESET}

			local padded_text
			printf -v padded_text " %-*s " "$col_content_width" "$text"

			line_to_print+="${color}${padded_text}${RESET}|"
		done
		echo -e "$line_to_print"
	done
}

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

function show_installation_summary() {
	local packages=("$@")

	print_table_header "INSTALLATION SUMMARY"
	print_summary_row "Total packages to install:" "${#packages[@]}" "$BLUEHI" "$GREENHI"
	print_summary_row "Internet connection:" "Required" "$BLUEHI" "$REDHI"
	if [ ${#packages[@]} -gt 0 ]; then
		print_left_element "The following packages will be installed:" "$BLUEHI"
		# Préparer la liste des paquets pour la fonction print_grid.
		# Chaque paquet est un élément, et on leur donne une couleur neutre (RESET).
		local packages_for_grid=()
		for pkg in "${packages[@]}"; do
			packages_for_grid+=("$pkg" "$GREEN")
		done

		# Afficher la grille de paquets
		print_grid 4 "${packages_for_grid[@]}"
		print_table_line
	fi
	ask_question "Do you want to continue? [y/N]: " confirm

	[[ "$confirm" =~ ^[yY]$ ]]
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
