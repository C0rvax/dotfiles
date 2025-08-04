#!/bin/bash

function setup_ssh_and_git {
    log "INFO" "Setting up SSH and Git configurations..."
    
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
		log "SUCCESS" "SSH key already exists. Skipping creation."
    else
        log "INFO" "Creating a new SSH key..."
        local ssh_email
        read -p "Enter your email for the SSH key comment: " ssh_email
        if [ -z "$ssh_email" ]; then
            log "ERROR" "Email cannot be empty. Aborting key generation."
            return 1
        fi
        
        # Le -N "" crée une clé sans passphrase pour l'automatisation.
        ssh-keygen -t ed25519 -C "$ssh_email" -N "" -f "$HOME/.ssh/id_ed25519"
        chmod 700 "$HOME/.ssh"
        chmod 600 "$HOME/.ssh/id_ed25519"
        chmod 644 "$HOME/.ssh/id_ed25519.pub"
        log "SUCCESS" "SSH key created successfully."
    fi

    log "INFO" "Your public SSH key is:"
    cat "$HOME/.ssh/id_ed25519.pub"
    
    log "WARNING" "ACTION REQUIRED: You must add this public key to your Git provider (GitHub, GitLab, etc.)"
    log "INFO" "1. Go to your SSH keys settings on the website."
    log "INFO" "2. Click 'Add SSH key'."
    log "INFO" "3. Paste the key above."

    if [[ "$ASSUME_YES" != "true" ]]; then
        read -p "Press [Enter] when you have added the key to your Git provider..."
    fi

    log "INFO" "Testing SSH connection to GitHub..."
    ssh -T git@github.com
    # La sortie de ssh -T est sur stderr, donc on redirige pour la capturer.
    # Un test plus robuste vérifierait le code de retour.

    install_git
}

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
