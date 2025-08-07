#!/bin/bash

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

get_display_width() {
    local str="$1"
    local clean_str=$(printf '%s' "$str" | sed 's/\x1b\[[0-9;]*m//g')
    local base_length=$(printf '%s' "$clean_str" | wc -m)
    local info_count=$(printf '%s' "$clean_str" | grep -o -E '[⏭️ℹ️⚠️🔧💻🐚✏️]' | wc -l 2>/dev/null || echo 0)
    local error_count=$(printf '%s' "$clean_str" | grep -o -E '[✅📦📥❌❓🔒]' | wc -l 2>/dev/null || echo 0)	
	if (( info_count > 0 )); then
		echo $((base_length - info_count + 2))
	elif (( error_count > 0 )); then
		echo $((base_length - error_count + 2))
	else
		echo $((base_length))
	fi
}

function print_title_element {
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

function print_center_element {
	local text="$1"
	local color="$2"
    local dashes_template="----------------------------------------------------------------------------------------------------"
	local visible_len=$(get_display_width "$text")
	local padding=$(((TABLE_WIDTH - visible_len - 2) / 2))
	local remainder=$(((TABLE_WIDTH - visible_len - 2) % 2))

	printf "|"
    printf "%.*s" "$padding" "$dashes_template"
    echo -e -n "${color}${text}${RESET}"
    printf "%.*s" "$((padding + remainder))" "$dashes_template"
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

function print_table_line {
	printf "+%.0s" $(seq 1 $((TABLE_WIDTH)))
	printf "\n"
}

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
    
    echo ""
    result_var="$response"
}

function print_table_header {
	local title=$1

	print_table_line
	print_title_element "$title" "$BLUEHI"
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