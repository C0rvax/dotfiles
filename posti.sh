#!/bin/bash
# Définition des options du script (ton code existant est parfait)
# ...

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

# Lancement du workflow principal
run_package_installation

# Finalisation
log "INFO" "Lancement des tâches de post-installation..."
p_update
p_clean
# setup_vlc etc...
log "SUCCESS" "Script terminé ! Un redémarrage est conseillé."
print_table_line
exit 0