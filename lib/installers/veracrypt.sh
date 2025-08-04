#!/usr/bin/env bash

function install_veracrypt {
	echo ""
	check_package "veracrypt"
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Package veracrypt is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing veracrypt ****${YELLOW}"
		sudo add-apt-repository "$PPA_VERACRYPT" -y
		sudo apt-get update -y
		sudo apt-get install veracrypt -y
	fi
}