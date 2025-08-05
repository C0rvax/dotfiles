#!/bin/bash

function setup_ssh_and_git {
    log "INFO" "Setting up SSH and Git configurations..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would check for SSH key, create if missing, prompt to add to Git provider, and configure Git user."
        return
    fi

    if [ -f "$HOME/.ssh/id_ed25519" ]; then
		log "SUCCESS" "SSH key already exists. Skipping creation."
    else
        create_ssh_key
        if [[ $? -ne 0 ]]; then return 1; fi
    fi

    log "INFO" "Your public SSH key is:"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    log "WARNING" "ACTION REQUIRED: You must add this public key to your Git provider (GitHub, GitLab, etc.)"
    log "INFO" "1. Go to your SSH keys settings on the website."
    log "INFO" "2. Click 'Add SSH key'."
    log "INFO" "3. Paste the key above."

    if [[ "$ASSUME_YES" != "true" ]]; then
        read -p "Press [Enter] when you have added the key to your Git provider..."
    fi

    setup_github_known_hosts
}

function create_ssh_key {
    log "INFO" "Creating a new SSH key..."
    local ssh_email
    
    if [[ "$ASSUME_YES" == "true" ]]; then
        log "ERROR" "Cannot create SSH key in non-interactive mode without an email. Please create it manually."
        return 1
    fi

    read -p "Enter your email for the SSH key comment: " ssh_email
    if [ -z "$ssh_email" ]; then
        log "ERROR" "Email cannot be empty. Aborting key generation."
        return 1
    fi
    
    ssh-keygen -q -t ed25519 -C "$ssh_email" -N "" -f "$HOME/.ssh/$SSH_KEY_FILENAME"
    
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/$SSH_KEY_FILENAME"
    chmod 644 "$HOME/.ssh/$SSH_KEY_FILENAME.pub"
    log "SUCCESS" "SSH key created successfully."
}

function setup_github_known_hosts {
    log "INFO" "Setting up GitHub known hosts..."
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/known_hosts"
    chmod 644 "$HOME/.ssh/known_hosts"
    if ssh-keygen -F github.com > /dev/null 2>&1; then
        log "INFO" "GitHub known hosts already set up."
        return 0
    fi
    ssh-keyscan -t rsa,ed25519 github.com >> "$HOME/.ssh/known_hosts"
    sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
    log "INFO" "Testing SSH connection to GitHub..."
    timeout 10 ssh -T git@github.com
    log "SUCCESS" "GitHub known hosts set up successfully."
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
