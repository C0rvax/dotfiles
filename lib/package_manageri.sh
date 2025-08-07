#!/bin/bash

# ==============================================================================
# FONCTIONS DE MANIPULATION DES PAQUETS (Version Robuste)
# ==============================================================================

# === FONCTIONS DE PARSING (ne changent pas) ===
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

# === FONCTIONS DE COLLECTE (changent radicalement) ===

# Fonction interne pour lire les paquets, évite la répétition
_collect_packages_into_global_array() {
    local -n target_array=$1 # On passe le NOM du tableau à remplir
    local condition_type=$2   # "level" ou "category"
    local condition_value=$3  # "base", "full", "office", etc.

    # On vide le tableau cible avant de le remplir
    target_array=()

    # On parcourt TOUS les paquets définis
    for pkg_def in "${SYSTEM_PACKAGES[@]}" "${SPECIAL_INSTALLS[@]}" "${OPTIONAL_PACKAGES[@]}"; do
        local current_value
        current_value=$(get_package_info "$pkg_def" "$condition_type")
        
        if [[ "$current_value" == "$condition_value" ]]; then
            # On ajoute la définition de paquet au tableau cible
            target_array+=("$pkg_def")
        fi
    done
}

# NOTE: Ces fonctions ne retournent plus rien (pas de 'echo').
# Elles modifient des variables globales.
function get_packages_by_level() {
    # Le résultat sera dans le tableau global PACKAGES_BY_LEVEL_RESULT
    _collect_packages_into_global_array PACKAGES_BY_LEVEL_RESULT "level" "$1"
}

function get_packages_by_category() {
    # Le résultat sera dans le tableau global PACKAGES_BY_CATEGORY_RESULT
    _collect_packages_into_global_array PACKAGES_BY_CATEGORY_RESULT "category" "$1"
}