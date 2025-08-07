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
    local selected_ids=("$@")
    local items_to_install=()

    for item in "${selected_ids[@]}"; do
        local id; id=$(get_package_info "$item" id)
        if [[ "${AUDIT_STATUS[$id]}" == "missing" ]]; then
            items_to_install+=("$item")
        fi
    done

    if [ ${#items_to_install[@]} -eq 0 ]; then
        log "SUCCESS" "Everything is already installed. Nothing to do."
        return 1
    fi

    print_table_header "INSTALLATION SUMMARY"
    print_left_element "Total items to install: ${#items_to_install[@]}" "$BLUEHI"
    print_left_element "Internet connection:      Required" "$BLUEHI"

    # Affichage groupé par catégorie
    for category_info in "${CATEGORIES[@]}"; do
        local category_name="${cat%%:*}"
        local category_title="${cat#*:}"

        print_center_element "$category_title" "$YELLOW"

        mapfile -t packages_to_install < <(get_packages_by_category "$category_name")

        local packages_to_print=()
        for pkg_def in "${packages_to_install[@]}"; do
            local desc; desc=$(get_package_info "$pkg_def" desc)
            packages_to_print+=("$desc" "$GREENHI")
        done
        print_grid 4 "${packages_to_print[@]}"
    done
    print_table_line
    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Do you want to continue? [y/N]: " confirm
        [[ "$confirm" =~ ^[yY]$ ]]
    else
        return 0
    fi
}

function select_base_packages() {
    local install_type

    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="1"
        log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
    else
        # echo "Choisissez votre type d'installation:" >&2
        # echo "1) Base (outils essentiels)" >&2
        # echo "2) Complète (base + applications)" >&2
        # echo "3) Personnalisée" >&2

        # read -p "Votre choix [1-3]: " install_type </dev/tty
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

    echo >&2
    echo "Paquets optionnels disponibles:" >&2

    read -p "Inclure les outils de développement embarqué? [y/N]: " embedded </dev/tty
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    read -p "Inclure LibreOffice? [y/N]: " office </dev/tty
    if [[ "$office" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    printf '%s\n' "${optional_packages_to_add[@]}"
}

# === INSTALLATION PRINCIPALE ===

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
        
        # Vérifier si déjà installé
        if eval "$check_cmd" 2>/dev/null; then
            echo "déjà installé"
            continue
        fi
        
        # Installer
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

    if ! show_installation_summary "${packages_to_install[@]}"; then
        log "INFO" "No packages selected for installation. Exiting."
        print_table_line
        exit 0
    fi
    
    # 5. Installation (ne change pas)
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo
        echo "Paquets sélectionnés: ${#packages_to_install[@]}"

        if [[ "$ASSUME_YES" != "true" ]]; then
            read -p "Continuer? [Y/n]: " confirm
            # On considère "Entrée" (chaîne vide) comme une confirmation
            if [[ "$confirm" =~ ^[nN]$ ]]; then
                log "WARNING" "Installation annulée par l'utilisateur."
                exit 1
            fi
        fi

        install_selected_packages "${packages_to_install[@]}"
    else
        log "INFO" "Rien à faire, tout semble être à jour !"
    fi
}