#!/bin/bash

function create_ssh_key {
    log "INFO" "Creating SSH key..."
	if [ -f ~/.ssh/id_ed25519 ]; then
		log "INFO" "SSH key ~/.ssh/id_ed25519 already exists. Skipping."
		return
	fi

	read -p "Enter your email for the SSH key comment: " ssh_email
	if [ -z "$ssh_email" ]; then
		log "ERROR" "Email cannot be empty. Aborting key generation."
		return
	fi

	ssh-keygen -t ed25519 -C "$ssh_email" -N "" -f ~/.ssh/id_ed25519

	chmod 600 ~/.ssh/id_ed25519
	chmod 700 ~/.ssh
	chmod 644 ~/.ssh/id_ed25519.pub
	log "SUCCESS" "SSH key created successfully."
	log "INFO" "Your public key is:"
	cat ~/.ssh/id_ed25519.pub
}