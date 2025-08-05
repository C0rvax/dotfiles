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

    print_table_line
    log "INFO" "Your public SSH key is:"
    local key=$(cat "$HOME/.ssh/id_ed25519.pub")
    print_left_element "$key" "$CYAN"
    log "WARNING" "ACTION REQUIRED: You must add this public key to your Git provider (GitHub, GitLab, etc.)"
    log "INFO" "1. Go to your SSH keys settings on the website."
    log "INFO" "2. Click 'Add SSH key'."
    log "INFO" "3. Paste the key above."

    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Press [Enter] when you have added the key to your Git provider..." ""
    fi

    setup_github_known_hosts
}

function create_ssh_key {
    log "INFO" "Creating a new SSH key..."
    
    if [[ "$ASSUME_YES" == "true" ]]; then
        log "ERROR" "Cannot create SSH key in non-interactive mode without an email. Please create it manually."
        return 1
    fi

    ssh-keygen -q -t ed25519 -C "$SSH_EMAIL" -N "" -f "$HOME/.ssh/$SSH_KEY_FILENAME"

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
    ssh-keyscan -t rsa,ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
    sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
    log "SUCCESS" "GitHub known hosts set up successfully."
    install_git
}

function install_git {
	log "INFO" "Configuring Git global settings..."
    if [[ "$ASSUME_YES" != "true" ]]; then
        ask_question "Do You want to set git user and email ? [y/n]" rep
        if [[ "$rep" =~ ^[yYoO]$ ]]; then
            ask_question "Enter your name: " git_name
            ask_question "Enter your email: " git_email
            git config --global user.name "$git_name"
            git config --global user.email "$git_email"
            log "SUCCESS" "Git global config set!"
        else
            log "WARNING" "Git global config skipped!"
        fi
    fi
	
}
