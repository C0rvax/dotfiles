#!/bin/bash

# Sourcing des fichiers
source config/settings.conf
source lib/system.sh
source lib/ui.sh
source config/package.conf
# 2. On source les librairies qui UTILISENT ces définitions
source lib/package_manageri.sh
source lib/auditi.sh
source lib/installers/select_install.sh
# 3. On source tous les installeurs spéciaux
for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

# --- DÉROULEMENT DU SCRIPT ---

echo "  - Variable \$SHELL : $SHELL"
echo "  - Interpréteur actuel (via ps) : $(ps -p $$ -o comm=)"
echo "  - Version de Bash :"
bash --version | head -n 1
echo

prompt_for_sudo
display_logo
detect_distro
detect_desktop

run_package_installation

p_update
p_clean
# setup_vlc etc...
log "SUCCESS" "Script terminé ! Un redémarrage est conseillé."
print_table_line
exit 0