#!/bin/bash

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
}

function setup_git {
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