#!/usr/bin/env bash

function install_git {
	echo -e "${BLUEHI} ---- GIT global config ----"
	read -p "Do You want to set git user and email ? [y/n]" rep
	if [[ "$rep" =~ ^[yYoO]$ ]]; then
		read -p "Enter your name: " git_name
		read -p "Enter your email: " git_email
		git config --global user.name "$git_name"
		git config --global user.email "$git_email"
		echo -e "${GREENHI}Git global config set!${RESET}"
	else
		echo -e "${REDHI}Git global config skipped!${RESET}"
	fi
}
