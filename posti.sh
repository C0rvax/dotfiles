#!/bin/bash
# Définition des options du script (ton code existant est parfait)
# ...

declare -gA AUDIT_STATUS
declare -gA PACKAGES_BY_LEVEL_RESULT=()
declare -gA PACKAGES_BY_CATEGORY_RESULT=()

# Sourcing des fichiers
source config/settings.conf
source lib/system.sh
source lib/ui.sh
# --- ATTENTION : L'ORDRE EST IMPORTANT ---
# 1. On source les DÉFINITIONS des paquets
source config/package.conf
# 2. On source les librairies qui UTILISENT ces définitions
source lib/package_manageri.sh
source lib/auditi.sh
source lib/installers/select_install.sh
# 3. On source tous les installeurs spéciaux
for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

# --- DÉROULEMENT DU SCRIPT ---
# Déclaration de la variable globale qui stockera le résultat de l'audit
declare -gA AUDIT_STATUS

# Initialisation
# trap "cleanup_sudo_config" EXIT SIGINT SIGTERM # Tu peux décommenter si tu remets la gestion sudo
prompt_for_sudo
clear
display_logo
detect_distro
detect_desktop

audit_packages

# 2. Sélection utilisateur
local install_type
if [[ "$ASSUME_YES" == "true" ]]; then
    install_type="base"
else
    install_type=$(select_installation_type)
fi

# 3. Collecte des paquets
local packages_to_install=()
case "$install_type" in
base)
    # On appelle la fonction qui remplit le tableau global
    get_packages_by_level "base"
    # On copie le résultat dans notre tableau local
    packages_to_install+=("${PACKAGES_BY_LEVEL_RESULT[@]}")
    ;;
full)
    get_packages_by_level "base"
    packages_to_install+=("${PACKAGES_BY_LEVEL_RESULT[@]}")
    
    get_packages_by_level "full"
    packages_to_install+=("${PACKAGES_BY_LEVEL_RESULT[@]}")
    ;;
custom)
    # ...
    ;;
esac

# 4. Ajouter les paquets optionnels
if [[ "$install_type" != "base" && "$ASSUME_YES" != "true" ]]; then
    # On passe le NOM de notre tableau local à la fonction
    select_optional_packages_into packages_to_install
fi

# 5. Installation (le reste ne change pas)
if [[ ${#packages_to_install[@]} -gt 0 ]]; then
    print_table_line
    log "INFO" "Paquets sélectionnés pour l'installation: ${#packages_to_install[@]}"
    
    # DEBUG : Affiche le contenu final du tableau avant installation
    log "DEBUG" "Contenu final du tableau à installer :"
    declare -p packages_to_install >&2

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

p_update
p_clean
# setup_vlc etc...
log "SUCCESS" "Script terminé ! Un redémarrage est conseillé."
print_table_line
exit 0