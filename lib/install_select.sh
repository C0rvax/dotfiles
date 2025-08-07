#!/bin/bash

function select_base_packages() {
    local install_type

    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="1"
        log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
    else
        print_title_element "INSTALLATION TYPE" "$BLUEHI" >&2
        print_table_line >&2
        print_left_element "1) Base (Minimal: core utils, dev tools, shell, nvim config)" "$BLUEHI" >&2
        print_left_element "2) Full (Recommended: 'Base' + graphical apps, Docker, etc.)" "$BLUEHI" >&2
        ask_question "Enter your choice [1-2]" install_type >&2
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
    esac

    printf '%s\n' "${base_packages_to_install[@]}"
}

function select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()

    ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" embedded >&2
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    ask_question "Inclure LibreOffice? [y/N]: " office >&2
    if [[ "$office" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    printf '%s\n' "${optional_packages_to_add[@]}"
}