#!/bin/bash

pkg_install() {
    local package="$1"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "WARNING" "Simulation: Installation de $package"
        return 0
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get install -y "$package" &>/dev/null
            ;;
        arch)
            sudo pacman -S --noconfirm "$package" &>/dev/null
            ;;
        fedora)
            sudo dnf install -y "$package" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

get_package_info() {
    local package_def="$1"
    local field="$2"
    
    IFS=':' read -ra parts <<< "$package_def"
    case "$field" in
        id) echo "${parts[0]}" ;;
        desc) echo "${parts[1]}" ;;
        level) echo "${parts[2]}" ;;
        category) echo "${parts[3]}" ;;
        check) echo "${parts[4]}" ;;
        install) echo "${parts[5]}" ;;
    esac
}

get_all_packages() {
    printf '%s\n' "${SYSTEM_PACKAGES[@]}" "${SPECIAL_INSTALLS[@]}" "${OPTIONAL_PACKAGES[@]}"
}

function get_packages_by_level() {
    local level_filter="$1"
    while read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        
        if [[ "$(get_package_info "$pkg_def" level)" == "$level_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}

function get_packages_by_category() {
    local category_filter="$1"
    while read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        
        if [[ "$(get_package_info "$pkg_def" category)" == "$category_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}

function p_update {
	log "INFO" "Updating package lists for $DISTRO..."
	case "$DISTRO" in
	"arch")
		sudo pacman -Sy --noconfirm >>"$LOG_FILE" 2>&1
		;;
	"ubuntu" | "debian")
		sudo apt-get update -y >>"$LOG_FILE" 2>&1
		;;
	"fedora")
		sudo dnf check-update -y >>"$LOG_FILE" 2>&1
		;;
	"opensuse")
		sudo zypper refresh >>"$LOG_FILE" 2>&1
		;;
	*)
		log "ERROR" "Unsupported distribution for update."
		return 1
		;;
	esac
}

function p_clean {
	log "INFO" "Cleaning up unused packages for $DISTRO..."
	case "$DISTRO" in
	"arch")
		if [[ -n "$(pacman -Qdtq)" ]]; then
			sudo pacman -Rns $(pacman -Qdtq) --noconfirm >>"$LOG_FILE" 2>&1
		fi
		;;
	"ubuntu" | "debian")
		sudo apt-get autoclean -y >>"$LOG_FILE" 2>&1 && sudo apt-get autoremove -y >>"$LOG_FILE" 2>&1
		;;
	"fedora")
		sudo dnf autoremove -y >>"$LOG_FILE" 2>&1
		;;
	"opensuse")
		sudo zypper clean --all >>"$LOG_FILE" 2>&1
		;;
	esac
}

install_selected_packages() {
    local packages=("$@")
    local current=0
    local total=${#packages[@]}
    
    sudo -v || { log "ERROR" "Sudo authentication failed. Exiting."; exit 1; }
    clear
    print_table_header "INSTALLATION IN PROGRESS"
    
    for pkg_def in "${packages[@]}"; do
        ((current++))
        local desc=$(get_package_info "$pkg_def" desc)
        local install_cmd=$(get_package_info "$pkg_def" install)
        
        log "INFO" "Processing ($current/$total): ${desc}"
        
        if eval "$install_cmd" 2>/dev/null; then
            log "SUCCESS" "'${desc}' installed successfully."
        else
            log "ERROR" "Failed to install '${desc}'. Check log for details."
        fi
        print_table_line
    done
}

function run_package_installation() {
    audit_packages

    local packages_to_install=()
    case "$SELECT_MODE" in
        tui)
            mapfile -t packages_to_install < <(select_installables_tui)
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

    local uninstalled_packages=()
    for item in "${packages_to_install[@]}"; do
        if [[ -z "$item" ]]; then continue; fi
        local id; id=$(get_package_info "$item" id)
        if [[ "${AUDIT_STATUS[$id]}" == "missing" ]]; then
            uninstalled_packages+=("$item")
        fi
    done

    if ! show_installation_summary "${uninstalled_packages[@]}"; then
        log "INFO" "No packages selected for installation. Exiting."
        print_table_line
        exit 0
    fi

    install_selected_packages "${uninstalled_packages[@]}"
    log "SUCCESS" "Installation completed successfully."
}