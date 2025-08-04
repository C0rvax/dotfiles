#!/usr/bin/env bash

function install_git {
	log "INFO" "Configuring Git global settings..."
	read -p "Do You want to set git user and email ? [y/n]" rep
	if [[ "$rep" =~ ^[yYoO]$ ]]; then
		read -p "Enter your name: " git_name
		read -p "Enter your email: " git_email
		git config --global user.name "$git_name"
		git config --global user.email "$git_email"
		log "SUCCESS" "Git global config set!"
	else
		log "WARNING" "Git global config skipped!"
	fi
}
