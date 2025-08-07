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
    local key=$(cat "$HOME/.ssh/id_ed25519.pub")
    log "WARNING" "$key"
    log "INFO" "Add this public key to your Git provider (GitHub, GitLab, etc.)"

    setup_github_known_hosts
    setup_git
}

function create_ssh_key {
    log "INFO" "Creating a new SSH key..."
    ssh-keygen -q -t ed25519 -C "$SSH_EMAIL" -N "" -f "$HOME/.ssh/$SSH_KEY_FILENAME"
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/$SSH_KEY_FILENAME"
    chmod 644 "$HOME/.ssh/$SSH_KEY_FILENAME.pub"
    log "SUCCESS" "SSH key created successfully."
}