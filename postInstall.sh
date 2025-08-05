# #!/bin/bash

# VERBOSE=false
# DRY_RUN=false
# ASSUME_YES=false
# SELECT_MODE="interactive"

# while [[ "$#" -gt 0 ]]; do
#     case "$1" in
#         -v|--verbose) VERBOSE=true; shift ;;
#         -d|--dry-run) DRY_RUN=true; shift ;;
#         -y|--yes) ASSUME_YES=true; shift ;;
#         -h|--help)
#             echo "Usage: $0 [-v|--verbose] [-d|--dry-run] [-y|--yes] [-h|--help]"
#             echo "  -v, --verbose    Enable verbose output."
#             echo "  -d, --dry-run    Simulate installation without making changes."
#             echo "  -y, --yes        Assume 'yes' to all prompts."
#             echo "  -h, --help       Show this help message."
#             exit 0
#             ;;
#         -s|--select) SELECT_MODE="$2"; shift 2 ;;
#         *) echo "Unknown parameter passed: $1"; exit 1 ;;
#     esac
# done

# source config/settings.conf
# source config/packages.conf
# source lib/system.sh
# source lib/package_manager.sh
# source lib/audit.sh
# source lib/ui.sh
# for f in lib/installers/*.sh; do source "$f"; done
# for f in lib/desktop_configs/*.sh; do source "$f"; done

# display_logo
# prompt_for_sudo
# declare -A MISSING_PACKAGES_MAP=()
# run_audit </dev/null

# INSTALL_LIST=()

# case "$SELECT_MODE" in
#     tui)
#         select_pak_tui
#         ;;
#     interactive)
#         select_pak_interactive
#         ;;
#     *)
#         log "ERROR" "Invalid selection mode: '$SELECT_MODE'. Use 'tui' or 'interactive'."
#         exit 1
#         ;;
# esac

# # If, after selection, the list is empty, we can stop
# if [ ${#INSTALL_LIST[@]} -eq 0 ]; then
#     log "WARNING" "No packages to install. Exiting."
#     exit 0
# fi


# # Remove potential duplicates (important!)
# # INSTALL_LIST=($(printf "%s\n" "${INSTALL_LIST[@]}" | sort -u))

# # # --- SECTION DE FILTRAGE DES PAQUETS À INSTALLER ---
# # PACKAGES_TO_INSTALL=()
# # total_check=${#INSTALL_LIST[@]}
# # current_check=0

# # for PKG in "${INSTALL_LIST[@]}"; do
# #     ((current_check++))
    
# #     if ! check_package "$PKG"; then
# #         PACKAGES_TO_INSTALL+=("$PKG")
# #     fi
# # done

# # INSTALL_LIST=("${PACKAGES_TO_INSTALL[@]}")
# FINAL_INSTALL_LIST=()
# PACKAGES_TO_INSTALL_COUNT=0
# for PKG in "${INSTALL_LIST[@]}"; do
#     if [[ $PKG == '#'* ]]; then
#         FINAL_INSTALL_LIST+=("$PKG")
#     elif [[ -v MISSING_PACKAGES_MAP[$PKG] ]]; then
#         FINAL_INSTALL_LIST+=("$PKG")
#         ((PACKAGES_TO_INSTALL_COUNT++))
#     fi
# done
# # --- FIN DE LA SECTION DE FILTRAGE ---

# # Si la liste est maintenant vide, cela signifie que tout est déjà installé.
# if [ ${#INSTALL_LIST[@]} -eq 0 ]; then
#     log "SUCCESS" "All selected packages are already installed. Nothing to do."
#     print_table_line
# fi

# if ! show_installation_summary "${INSTALL_LIST[@]}"; then
#     log "WARNING" "Installation aborted by user at summary."
#     print_table_line
#     exit 0
# fi

# print_table_header "PACKAGE INSTALLATION"
# start_sudo_keep_alive
# log "INFO" "Starting package installation..."
# p_update

# total=${#INSTALL_LIST[@]}
# current=0

# for PKG in "${INSTALL_LIST[@]}"; do
#     ((current++))
#     if [[ "$VERBOSE" != "true" ]]; then
#         show_progress "$current" "$total" "$PKG" "Installing"
#     fi
#     install_package "${PKG}"
# done

# if [[ "$VERBOSE" != "true" && "$total" -gt 0 ]]; then
#     echo
# fi
# log "SUCCESS" "Package installation phase complete."

# # INSTALL SPECIFIC PACKAGES
# print_table_header "SPECIFIC PACKAGE INSTALLATIONS"
# install_firefox
# setup_ssh_and_git
# install_fonts
# install_nvim
# install_veracrypt
# install_docker
# install_node
# install_zsh
# install_zconfig
# log "SUCCESS" "All configurations applied."

# case "$DESKTOP" in
#     kde)      setup_kde ;;
#     gnome)    setup_gnome ;;
#     xfce)     setup_xfce ;;
#     lxde)     setup_lxde ;;
#     lxqt)     setup_lxqt ;;
#     mate)     setup_mate ;;
#     cinnamon) setup_cinnamon ;;
#     *) log "WARNING" "No specific desktop configuration for '$DESKTOP'." ;;
# esac

# setup_vlc
# # set-bin

# p_update
# p_clean

# stop_sudo_keep_alive
# log "SUCCESS" "Post-install script finished! Please reboot your system for all changes to take effect."
# exit 0
# # À AJOUTER
# # driver nvidia sudo apt install nvidia-driver-550
# # raccourcis
# # tableau de bord
# # pipx install compiledb
# # ledger live

#!/bin/bash

# --- Parsing des arguments (inchangé) ---
VERBOSE=false
DRY_RUN=false
ASSUME_YES=false
SELECT_MODE="interactive" # 'interactive' ou 'tui'

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -v|--verbose) VERBOSE=true; shift ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -y|--yes) ASSUME_YES=true; shift ;;
        -h|--help) # ... aide inchangée ...
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


# ==============================================================================
# NOUVEAU FLUX D'INSTALLATION
# ==============================================================================

# --- Étape 1: Affichage initial et Audit ---
display_logo
prompt_for_sudo
run_pre_install_audit # Vérifie TOUT et remplit la map INSTALL_STATUS
run_audit_display     # Affiche l'état du système (rouge/vert)

log "INFO" "Starting the installation process with the following settings:"

# --- Étape 2: Sélection par l'utilisateur ---
declare -a SELECTED_IDS
case "$SELECT_MODE" in
    tui)
        mapfile -t SELECTED_IDS < <(select_installables_tui)
        ;;
    interactive)
        mapfile -t SELECTED_IDS < <(select_installables_interactive)
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
    # La fonction retourne 1 si tout est déjà installé, 0 pour continuer,
    # ou un autre code d'erreur si l'utilisateur annule.
    if [ $? -eq 1 ]; then # Cas "Rien à faire"
      exit 0
    else # Cas "Annulé par l'utilisateur"
      log "WARNING" "Installation aborted by user at summary."
      exit 0
    fi
fi


# --- Étape 4: Installation ---
print_table_header "INSTALLATION IN PROGRESS"
start_sudo_keep_alive

# Filtrer une dernière fois pour ne garder que les items manquants
INSTALL_QUEUE=()
for id in "${SELECTED_IDS[@]}"; do
    if [[ "${INSTALL_STATUS[$id]}" == "missing" ]]; then
        INSTALL_QUEUE+=("$id")
    fi
done

total=${#INSTALL_QUEUE[@]}
current=0

for id in "${INSTALL_QUEUE[@]}"; do
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
done

log "SUCCESS" "Main installation phase complete."


# --- Étape 5: Post-Installation ---
print_table_header "FINAL CONFIGURATIONS"
log "INFO" "Applying final desktop and system configurations..."

# La configuration du bureau reste séparée car elle dépend de la détection et non d'un choix.
case "$DESKTOP" in
    kde)      setup_kde ;;
    gnome)    setup_gnome ;;
    xfce)     setup_xfce ;;
    # ... autres DE ...
    *) log "WARNING" "No specific desktop configuration for '$DESKTOP'." ;;
esac

# Autres configurations finales
setup_vlc
# set-bin

p_update
p_clean

stop_sudo_keep_alive
log "SUCCESS" "Post-install script finished! Please reboot your system for all changes to take effect."
exit 0