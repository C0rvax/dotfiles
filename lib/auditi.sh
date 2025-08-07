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

function select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()

    echo
    echo "Paquets optionnels disponibles:"

    # Développement embarqué
    read -p "Inclure les outils de développement embarqué? [y/N]: " embedded
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        # On utilise mapfile pour lire proprement la sortie dans un tableau temporaire
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        # On ajoute ce tableau au tableau principal
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    # Bureautique
    read -p "Inclure LibreOffice? [y/N]: " office
    if [[ "$office" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    # On affiche le résultat final pour que le script appelant puisse le capturer
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
    # 1. Audit initial (ne change pas)
    audit_packages

    # 2. Sélection utilisateur (ne change pas)
    local install_type
    if [[ "$ASSUME_YES" == "true" ]]; then
        install_type="base"
    else
        install_type=$(select_installation_type)
    fi

    # 3. Collecte des paquets à installer (ne change pas)
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
        echo "Mode personnalisé pas encore implémenté, passage en mode complet"
        mapfile -t packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
        ;;
    esac

    # 4. Ajouter les paquets optionnels (LÉGÈRE MODIFICATION ICI)
    if [[ "$install_type" != "base" && "$ASSUME_YES" != "true" ]]; then
        local optional_packages
        # On utilise mapfile pour capturer la sortie de notre fonction sécurisée
        mapfile -t optional_packages < <(select_optional_packages)
        
        # On ajoute les paquets optionnels s'il y en a
        if [[ ${#optional_packages[@]} -gt 0 ]]; then
            packages_to_install+=("${optional_packages[@]}")
        fi
    fi

    # 5. Installation (ne change pas)
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo
        echo "Paquets sélectionnés: ${#packages_to_install[@]}"

        # On affiche la liste pour déboguer si besoin
        # printf " - %s\n" "${packages_to_install[@]}"

        if [[ "$ASSUME_YES" != "true" ]]; then
            read -p "Continuer? [Y/n]: " confirm
            # On considère "Entrée" (chaîne vide) comme une confirmation
            if [[ "$confirm" =~ ^[nN]$ ]]; then
                log "WARNING" "Installation annulée par l'utilisateur."
                return 1
            fi
        fi

        install_selected_packages "${packages_to_install[@]}"
    else
        log "INFO" "Rien à faire, tout semble être à jour !"
    fi
}