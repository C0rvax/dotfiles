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

declare -gA AUDIT_STATUS

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