#!/bin/bash

# ==============================================================================
# FONCTIONS DE MANIPULATION DES PAQUETS
# ==============================================================================

# === FONCTIONS DE PARSING ===
get_package_info() {
	local package_def="$1"
	local field="$2"
	IFS=':' read -ra parts <<<"$package_def"
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

get_packages_by_level() {
    local level_filter="$1"
    while IFS= read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        if [[ "$(get_package_info "$pkg_def" level)" == "$level_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}

get_packages_by_category() {
    local category_filter="$1"
    while IFS= read -r pkg_def; do
        [[ -n "$pkg_def" ]] || continue
        if [[ "$(get_package_info "$pkg_def" category)" == "$category_filter" ]]; then
            echo "$pkg_def"
        fi
    done < <(get_all_packages)
}

# === WORKFLOW D'INSTALLATION ===
# Il est logique de le mettre ici car il dépend de toutes les fonctions ci-dessus.
function run_package_installation() {
    audit_packages
    local install_type
    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="base"
    else
        install_type=$(select_installation_type)
    fi
    local packages_to_install=()
    case "$install_type" in
    base)
        mapfile -t packages_to_install < <(get_packages_by_level "base")
        ;;
    full)
        mapfile -t packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
        ;;
    custom)
        echo "Mode personnalisé pas encore implémenté."
        # Ici on pourrait appeler le TUI `selector`
        return
        ;;
    esac
    if [[ "$install_type" != "base" && "$ASSUME_YES" != "true" ]]; then
        local optional_packages
        mapfile -t optional_packages < <(select_optional_packages)
        if [[ ${#optional_packages[@]} -gt 0 ]]; then
            packages_to_install+=("${optional_packages[@]}")
        fi
    fi
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        print_table_line
        log "INFO" "Paquets sélectionnés pour l'installation: ${#packages_to_install[@]}"
        print_table_line
        if [[ "$ASSUME_YES" != "true" ]]; then
            read -p "Continuer? [Y/n]: " confirm
            if [[ "$confirm" =~ ^[nN]$ ]]; then
                log "WARNING" "Installation annulée."
                return 1
            fi
        fi
        install_selected_packages "${packages_to_install[@]}"
    else
        log "INFO" "Rien à installer."
    fi
}