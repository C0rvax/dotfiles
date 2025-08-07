#!/bin/bash

function install_veracrypt {
	check_package "veracrypt"
	if [ "$?" -eq "0" ]; then
		log "INFO" "Veracrypt is already installed."
		return 1
	elif [[ "$DRY_RUN" == "true" ]]; then
		log "WARNING" "Simulation: Installation de Veracrypt"
		return 1
	else
		log "INFO" "Installing Veracrypt..."
		sudo add-apt-repository "$PPA_VERACRYPT" -y >> "$LOG_FILE" 2>&1
		sudo apt-get update -y >> "$LOG_FILE" 2>&1
		sudo apt-get install veracrypt -y >> "$LOG_FILE" 2>&1
	fi
}