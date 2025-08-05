#!/usr/bin/env bash

function install_veracrypt {
	check_package "veracrypt"
	if [ "$?" -eq "0" ]; then
		log "INFO" "Veracrypt is already installed."
		print_table_line
	else
		log "INFO" "Installing Veracrypt..."
		sudo add-apt-repository "$PPA_VERACRYPT" -y >> "$LOG_FILE" 2>&1
		sudo apt-get update -y >> "$LOG_FILE" 2>&1
		sudo apt-get install veracrypt -y >> "$LOG_FILE" 2>&1
		log "SUCCESS" "Veracrypt installed successfully."
		print_table_line
	fi
}