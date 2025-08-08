#!/bin/bash

VERBOSE=false
DRY_RUN=false
ASSUME_YES=false
SELECT_MODE="interactive" # 'interactive' or 'tui'

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -v|--verbose) VERBOSE=true; shift ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -y|--yes) ASSUME_YES=true; shift ;;
        -t|--tui) SELECT_MODE="tui"; shift ;;
        -h|--help)
            echo "Usage: postInstall.sh [options]"
            echo "Options:"
            echo "  -v, --verbose       Enable verbose output"
            echo "  -d, --dry-run       Simulate installation without making changes"
            echo "  -y, --yes           Assume 'yes' answer to prompts"
            echo "  -h, --help          Show this help message"
            echo "  -t, --tui           Switch to TUI mode for package selection"
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

source config/settings.conf
source config/packages.conf
source lib/system.sh
source lib/ui.sh
source lib/package_manager.sh
source lib/audit.sh
source lib/install_select.sh
for f in lib/installers/*.sh; do source "$f"; done
for f in lib/desktop_configs/*.sh; do source "$f"; done

declare -gA AUDIT_STATUS

setup_time_and_network
#sync_clock

if [[ "$SELECT_MODE" != "tui" ]]; then
    display_logo
fi

detect_distro
detect_desktop

run_package_installation

print_table_header "FINAL CONFIGURATIONS"
log "INFO" "Applying final desktop and system configurations..."

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

setup_vlc
# set-bin

package_update
package_clean

log "SUCCESS" "Post-install script finished! Please reboot your system for all changes to take effect."
print_table_line
exit 0

function setup_time_and_network {
    log "INFO" "Waiting for network connectivity (critical for VMs)..."
    # Boucle jusqu'à ce que le ping vers un serveur fiable réussisse.
    while ! ping -c 1 -W 1 8.8.8.8 &> /dev/null; do
        echo -n "."
        sleep 1
    done
    echo
    log "SUCCESS" "Network connection is active."

    log "INFO" "Synchronizing system time..."
    if command -v timedatectl &>/dev/null; then
        # On redémarre le service de temps au cas où il serait confus par le snapshot.
        sudo systemctl restart systemd-timesyncd.service
        # On active la synchronisation NTP
        sudo timedatectl set-ntp true
        sleep 2 # On laisse le temps à la synchro de se faire.
        log "SUCCESS" "System time has been synchronized."
    else
        log "WARNING" "timedatectl command not found. Cannot guarantee time is correct."
    fi
}