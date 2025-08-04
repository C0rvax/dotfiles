#!/usr/bin/env bash

function create_ssh_key {
	echo -e "${BLUEHI} ---- Creating SSH Key ----${RESET}"
	if [ -f ~/.ssh/id_ed25519 ]; then
		echo -e "${GREENHI}SSH key ~/.ssh/id_ed25519 already exists. Skipping.${RESET}"
		return
	fi

	read -p "Enter your email for the SSH key comment: " ssh_email
	if [ -z "$ssh_email" ]; then
		echo "${REDHI}Email cannot be empty. Aborting key generation.${RESET}"
		return
	fi

	ssh-keygen -t ed25519 -C "$ssh_email" -N "" -f ~/.ssh/id_ed25519

	chmod 600 ~/.ssh/id_ed25519
	chmod 700 ~/.ssh
	chmod 644 ~/.ssh/id_ed25519.pub
	echo -e "${GREENHI}SSH key created successfully.${RESET}"
	echo "Your public key is:"
	cat ~/.ssh/id_ed25519.pub
}