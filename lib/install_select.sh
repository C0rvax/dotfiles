#!/bin/bash

function select_base_packages() {
    local install_type

    print_title_element "INSTALLATION TYPE" "$BLUEHI" >&2
    print_table_line >&2

    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="1"
        log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
    else
        print_left_element "1) Base (Minimal: core utils, dev tools, shell, nvim config)" "$BLUEHI" >&2
        print_left_element "2) Full (Recommended: 'Base' + graphical apps, Docker, etc.)" "$BLUEHI" >&2
        print_left_element "3) Custom (Not implemented yet, defaults to 'Full')" "$BLUEHI" >&2
        ask_question "Enter your choice [1-3]" install_type >&2
    fi

    local base_packages_to_install=()
    case "$install_type" in
    1)
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        ;;
    2)
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#base_packages_to_install[@]}" base_packages_to_install < <(get_packages_by_level "full")
        ;;
    3)
        echo "Mode personnalisé pas encore implémenté, passage en mode complet"
        mapfile -t base_packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#base_packages_to_install[@]}" base_packages_to_install < <(get_packages_by_level "full")
        ;;
    *)
        log "ERROR" "Invalid selection: '$install_type'. Please choose 1, 2 or 3."
        print_table_line
        exit 1
        ;;
    esac

    printf '%s\n' "${base_packages_to_install[@]}"
}

function select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()

    ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" embedded >&2
    if [[ "$embedded" =~ ^[yYoO]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    ask_question "Inclure LibreOffice? [y/N]: " office >&2
    if [[ "$office" =~ ^[yYoO]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    printf '%s\n' "${optional_packages_to_add[@]}"
}

function select_installables_tui() {
    log "INFO" "Launching profile selection TUI..."

    if [ ! -x ./selector ]; then
        log "WARNING" "'selector' not found. Trying to 'make'..."
        if ! make; then
             log "ERROR" "Failed to compile 'selector'. Aborting."
             exit 1
        fi
    fi

    local output_file
    output_file=$(mktemp)
    trap 'rm -f "$output_file"' RETURN

    {
        printf "%s\n" "${PROFILES[@]}"
        echo "---PACKAGES---"
        get_all_packages_for_tui
    } | ./selector > "$output_file"

    # 3. Lire le nom du profil choisi depuis le fichier temporaire
    local selected_profile_name
    selected_profile_name=$(cat "$output_file")
    
    if [[ -z "$selected_profile_name" ]]; then
        log "WARNING" "No profile selected or operation cancelled."
        return 0
    fi

    log "SUCCESS" "Profile selected: $selected_profile_name"

    local selected_tags=""
    for profile_def in "${PROFILES[@]}"; do
        if [[ "$profile_def" == "$selected_profile_name:"* ]]; then
            selected_tags="${profile_def##*:}"
            break
        fi
    done
    
    if [[ -z "$selected_tags" ]]; then
        log "ERROR" "Could not find tags for profile '$selected_profile_name'."
        return 1
    fi
    
    get_packages_by_tags "$selected_tags"
}

function get_all_packages_for_tui() {
    while read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        
        local id=$(get_package_info "$pkg_def" id)
        local desc=$(get_package_info "$pkg_def" desc)
        local tags=$(get_package_info "$pkg_def" tags)
        local status=${AUDIT_STATUS[$id]:-missing} 
        
        echo "$desc:$tags:$status"
    done < <(get_all_packages)
}