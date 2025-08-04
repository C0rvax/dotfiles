TABLE_WIDTH=96

# Display logo
function display_logo {
	echo -e "${GREENHI}"
	echo "   ██████╗ ██████╗ ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗"
	echo "  ██╔════╝██╔═████╗██╔══██╗██║   ██║██╔══██╗╚██╗██╔╝"
	echo "  ██║     ██║██╔██║██████╔╝██║   ██║███████║ ╚███╔╝"
	echo "  ██║     ████╔╝██║██╔══██╗╚██╗ ██╔╝██╔══██║ ██╔██╗"
	echo "  ╚██████╗╚██████╔╝██║  ██║ ╚████╔╝ ██║  ██║██╔╝ ██╗"
	echo "   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝"
	echo -e "${BLUEHI}"

	echo "         ██████╗  ██████╗ ███████╗████████╗"
	echo "         ██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝"
	echo "         ██████╔╝██║   ██║███████╗   ██║   "
	echo "         ██╔═══╝ ██║   ██║╚════██║   ██║   "
	echo "         ██║     ╚██████╔╝███████║   ██║   "
	echo "         ╚═╝      ╚═════╝ ╚══════╝   ╚═╝   "
	echo ""
	echo "██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     "
	echo "██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     "
	echo "██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     "
	echo "██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     "
	echo "██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗"
	echo "╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝"
	echo -e "${RESET}"
}

function print_table_line {
	printf "+%.0s" $(seq 1 $TABLE_WIDTH)
	printf "+\n"
}

function print_table_header {
	local title=$1
	local padding=$(((TABLE_WIDTH - ${#title} - 2) / 2))
	local remainder=$(((TABLE_WIDTH - ${#title} - 2) % 2 - 1))
	print_table_line
	printf "|"
	printf " %.0s" $(seq 1 $padding)
	echo -e -n " ${BLUEHI}${title}${RESET} "
	printf " %.0s" $(seq 1 $((padding + remainder)))
	printf "|\n"
	print_table_line
}

function print_grid {
	local num_cols=$1
	shift
	local items_with_colors=("$@")

	local col_content_width=$(((TABLE_WIDTH - 1) / num_cols - 2)) # -2 for spaces

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
	declare -A seen_items
	local master_list=()
	for item in \
		"${PKGS_CORE_UTILS[@]}" \
		"${PKGS_UTILS[@]}" \
		"${PKGS_DEV[@]}" \
		"${PKGS_SHELL[@]}" \
		"${PKGS_NVIM[@]}" \
		"${PKGS_APPS[@]}" \
		"${PKGS_OFFICE[@]}" \
		"${PKGS_EMBEDDED[@]}"; do
		if [[ -z "${seen_items[$item]}" ]]; then
			master_list+=("$item")
			seen_items["$item"]=1
		fi
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
			local padded_title
			printf -v padded_title " %-*s" $(($TABLE_WIDTH - 2)) "$category_title"
			echo -e "|${YELLOW}${padded_title}${RESET}|"

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

function show_installation_summary() {
    local packages=("$@")
    local estimated_time=$((${#packages[@]} * 2))  # 2 minutes par package en moyenne
    
    echo -e "${BLUEHI}"
    print_table_line
    printf "|"
    printf " %.0s" $(seq 1 30)
    echo -e " 📋 INSTALLATION SUMMARY "
    printf " %.0s" $(seq 1 29)
    printf "|\n"
    print_table_line
    
    echo -e "|${RESET} Total packages to install: ${GREENHI}${#packages[@]}${RESET}"
    printf " %.0s" $(seq 1 $((TABLE_WIDTH - 35 - ${#packages[@]})))
    echo "|"
    
    echo -e "|${RESET} Estimated time: ${YELLOWHI}~${estimated_time} minutes${RESET}"
    printf " %.0s" $(seq 1 $((TABLE_WIDTH - 25 - ${#estimated_time})))
    echo "|"
    
    echo -e "|${RESET} Internet connection: ${REDHI}Required${RESET}"
    printf " %.0s" $(seq 1 $((TABLE_WIDTH - 30)))
    echo "|"
    
    echo -e "|${RESET} Backup will be created: ${GREENHI}Yes${RESET}"
    printf " %.0s" $(seq 1 $((TABLE_WIDTH - 32)))
    echo "|"
    
    print_table_line
    echo -e "${RESET}"
    
    read -p "Continue with installation? [y/N]: " confirm
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
    
    printf "\r\033[K"  # Efface la ligne
    printf "["
    printf "%*s" "$filled" '' | tr ' ' '█'
    printf "%*s" "$empty" '' | tr ' ' '░'
    printf "] %3d%% (%d/%d) - %s: %s" "$percent" "$current" "$total" "$operation" "$package"
}