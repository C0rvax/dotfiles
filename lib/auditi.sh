#!/bin/bash

function audit_packages() {
    local installed=0
    local missing=0

    # On utilise mapfile pour charger tous les paquets en une fois, c'est plus propre
    mapfile -t all_packages < <(get_all_packages)
    local total=${#all_packages[@]}

    log "INFO" "all: ${all_packages[@]}"
    log "INFO" "Lancement de l'audit de ${total} paquets..."
    print_table_line

    for pkg_def in "${all_packages[@]}"; do
        local id; id=$(get_package_info "$pkg_def" id)
        local desc; desc=$(get_package_info "$pkg_def" desc)
        local check_cmd; check_cmd=$(get_package_info "$pkg_def" check)

        # On exécute la vérification en masquant TOUTES les sorties
        if eval "$check_cmd" &>/dev/null; then
            ((installed++))
            AUDIT_STATUS[$id]="installed"
            print_left_element "✓ $desc" "$GREEN"
        else
            ((missing++))
            AUDIT_STATUS[$id]="missing"
            print_left_element "✗ $desc" "$RED"
        fi
    done

    print_table_line
    log "SUCCESS" "Audit terminé : $installed installés, $missing manquants."
    print_table_line
}

function select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()

    echo >&2
    echo "Paquets optionnels disponibles:" >&2

    # Développement embarqué
    read -p "Inclure les outils de développement embarqué? [y/N]: " embedded </dev/tty
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        # On utilise mapfile pour lire proprement la sortie dans un tableau temporaire
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        # On ajoute ce tableau au tableau principal
        optional_packages_to_add+=("${temp_packages[@]}")
    fi

    # Bureautique
    read -p "Inclure LibreOffice? [y/N]: " office </dev/tty
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
        echo "Choisissez votre type d'installation:"
        echo "1) Base (outils essentiels)"
        echo "2) Complète (base + applications)"
        echo "3) Personnalisée"
        
        read -p "Votre choix [1-3]: " install_type </dev/tty
    fi

    # 3. Collecte des paquets à installer (ne change pas)
    local packages_to_install=()
    echo "Paquets à installer pour le type: $install_type"
    case "$install_type" in
    1)
        mapfile -t packages_to_install < <(get_packages_by_level "base")
        ;;
    2)
        mapfile -t packages_to_install < <(get_packages_by_level "base")
        mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
        ;;
    3)
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
        echo "Liste des paquets: ${packages_to_install[@]}"

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