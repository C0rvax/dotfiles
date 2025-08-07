#!/bin/bash

function install_veracrypt {
	if [[ "$DRY_RUN" == "true" ]]; then
		log "INFO" "[DRY-RUN] Would install Veracrypt from PPA."
		log "INFO" "Veracrypt would be installed from the PPA '$PPA_VERACRYPT'."
		return 0
	else
		log "INFO" "Installing Veracrypt..."
		sudo add-apt-repository "$PPA_VERACRYPT" -y >> "$LOG_FILE" 2>&1
		sudo apt-get update -y >> "$LOG_FILE" 2>&1
		sudo apt-get install veracrypt -y >> "$LOG_FILE" 2>&1
	fi
}