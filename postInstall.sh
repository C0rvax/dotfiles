#!/bin/bash

VERBOSE=false
DRY_RUN=false
ASSUME_YES=false
SELECT_MODE="interactive" # 'interactive' ou 'tui'

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -v|--verbose) VERBOSE=true; shift ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -y|--yes) ASSUME_YES=true; shift ;;
        -h|--help)
            echo "Usage: postInstall.sh [options]"
            echo "Options:"
            echo "  -v, --verbose       Enable verbose output"
            echo "  -d, --dry-run       Simulate installation without making changes"
            echo "  -y, --yes           Assume 'yes' answer to prompts"
            echo "  -h, --help          Show this help message"
            echo "  -s, --select        Select installation mode (interactive or tui)"
            exit 0
            ;;
        -s|--select) SELECT_MODE="$2"; shift 2 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

source config/settings.conf
source config/packages.conf
source lib/system.sh
source lib/package_manager.sh
source lib/audit.sh
source lib/ui.sh
for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

# --- Étape 1: Affichage initial et Audit ---
trap "cleanup_sudo_config" EXIT SIGINT SIGTERM
declare -gA AUDIT_STATUS
#ensure_sudo_global_timestamp
prompt_for_sudo
#start_sudo_keep_alive
clear

display_logo
detect_distro
detect_desktop

run_pre_install_audit
run_audit_display

# --- Étape 2: Sélection par l'utilisateur ---
declare -a SELECTED_IDS=()

case "$SELECT_MODE" in
    tui)
        select_installables_tui
        ;;
    interactive)
        select_installables_interactive
        ;;
    *)
        log "ERROR" "Invalid selection mode: '$SELECT_MODE'. Use 'tui' or 'interactive'."
        exit 1
        ;;
esac

if [ ${#SELECTED_IDS[@]} -eq 0 ]; then
    log "INFO" "No items selected for installation. Exiting."
    exit 0
fi

# --- Étape 3: Résumé et Confirmation ---
if ! show_installation_summary "${SELECTED_IDS[@]}"; then
    log "WARNING" "Installation aborted by user at summary."
    print_table_line
    exit 0
fi

# --- Étape 4: Installation ---
print_table_header "INSTALLATION IN PROGRESS"

# Filtrer une dernière fois pour ne garder que les items manquants
INSTALL_QUEUE=()
for id in "${SELECTED_IDS[@]}"; do
    if [[ "${INSTALL_STATUS[$id]}" == "missing" ]]; then
        INSTALL_QUEUE+=("$id")
    fi
done

total=${#INSTALL_QUEUE[@]}
current=0

for category_info in "${CATEGORIES_ORDER[@]}"; do
    category_name="${category_info%%:*}"
    
    # Pour chaque catégorie, on parcourt la file d'attente pour trouver les items correspondants
    for id in "${INSTALL_QUEUE[@]}"; do
        if [[ "${INSTALLABLES_CATEGORY[$id]}" == "$category_name" ]]; then
            ((current++))
            log "INFO" "Processing ($current/$total): ${INSTALLABLES_DESC[$id]}"
            
            # Récupérer et exécuter la commande d'installation
            install_cmd="${INSTALLABLES_INSTALL[$id]}"
            if [[ "$DRY_RUN" == "true" ]]; then
                log "INFO" "[DRY-RUN] Would execute: $install_cmd"
            else
                if ! eval "$install_cmd"; then
                    log "ERROR" "Failed to install '${INSTALLABLES_DESC[$id]}'. Check log for details."
                else
                    log "SUCCESS" "'${INSTALLABLES_DESC[$id]}' installed successfully."
                fi
            fi
            print_table_line
        fi
    done
done

log "SUCCESS" "Main installation phase complete."


# --- Étape 5: Post-Installation ---
print_table_header "FINAL CONFIGURATIONS"
log "INFO" "Applying final desktop and system configurations..."

# --- Étape 6: Configuration du bureau ---
case "$DESKTOP" in
    kde)      setup_kde ;;
    gnome)    setup_gnome ;;
    xfce)     setup_xfce ;;
    lxde)     setup_lxde ;;
    lxqt)     setup_lxqt ;;
    mate)     setup_mate ;;
    cinnamon) setup_cinnamon ;;
    *) log "WARNING" "No specific desktop configuration for '$DESKTOP'." ;;
esac

# Autres configurations finales
setup_vlc
# set-bin

p_update
p_clean

stop_sudo_keep_alive
cleanup_sudo_config
log "SUCCESS" "Post-install script finished! Please reboot your system for all changes to take effect."
print_table_line
exit 0

# # À AJOUTER

