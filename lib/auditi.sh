#!/bin/bash

audit_packages() {
    local total=0
    local installed=0
    local missing=0
    
    echo "Vérification de votre système..."
    
    get_all_packages | while read -r pkg_def; do
        local id=$(get_package_info "$pkg_def" id)
        local desc=$(get_package_info "$pkg_def" desc)
        local check_cmd=$(get_package_info "$pkg_def" check)
        
        ((total++))
        
        if eval "$check_cmd" 2>/dev/null; then
            ((installed++))
            echo "✓ $desc"
        else
            ((missing++))
            echo "✗ $desc"
        fi
    done
    
    echo
    echo "Résumé: $installed installés, $missing manquants"
}

# === SÉLECTION INTERACTIVE ===

select_installation_type() {
    echo "Choisissez votre type d'installation:"
    echo "1) Base (outils essentiels)"
    echo "2) Complète (base + applications)"
    echo "3) Personnalisée"
    
    read -p "Votre choix [1-3]: " choice
    
    case "$choice" in
        1) echo "base" ;;
        2) echo "full" ;;
        3) echo "custom" ;;
        *) echo "base" ;;  # Par défaut
    esac
}

select_optional_packages() {
    local selected=()
    
    echo
    echo "Paquets optionnels disponibles:"
    
    # Développement embarqué
    read -p "Inclure les outils de développement embarqué? [y/N]: " embedded
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        selected+=($(get_packages_by_category "embedded"))
    fi
    
    # Bureautique
    read -p "Inclure LibreOffice? [y/N]: " office
    if [[ "$office" =~ ^[yY]$ ]]; then
        selected+=($(get_packages_by_category "office"))
    fi
    
    printf '%s\n' "${selected[@]}"
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

run_package_installation() {
    # 1. Audit initial
    audit_packages
    
    # 2. Sélection utilisateur
    local install_type
    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="base"
    else
        install_type=$(select_installation_type)
    fi
    
    # 3. Collecte des paquets à installer
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
            # Interface TUI ou sélection avancée à implémenter
            echo "Mode personnalisé pas encore implémenté, passage en mode complet"
            mapfile -t packages_to_install < <(get_packages_by_level "base")
            mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
            ;;
    esac
    
    # 4. Ajouter les paquets optionnels si demandés
    if [[ "$install_type" != "base" && "$ASSUME_YES" != "true" ]]; then
        local optional_packages
        mapfile -t optional_packages < <(select_optional_packages)
        packages_to_install+=("${optional_packages[@]}")
    fi
    
    # 5. Installation
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo
        echo "Paquets sélectionnés: ${#packages_to_install[@]}"
        
        if [[ "$ASSUME_YES" != "true" ]]; then
            read -p "Continuer? [Y/n]: " confirm
            [[ "$confirm" =~ ^[nN]$ ]] && return 1
        fi
        
        install_selected_packages "${packages_to_install[@]}"
    else
        echo "Aucun paquet à installer."
    fi
}