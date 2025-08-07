#!/bin/bash

function install_docker {
    case "$DISTRO" in
    "ubuntu"|"debian")
		if [[ "$DRY_RUN" == "true" ]]; then
			log "INFO" "[DRY-RUN] Would install Docker and docker-compose on $DISTRO."
			return 0
		fi
        log "INFO" "Installing Docker on $DISTRO..."
		for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg > ${LOG_FILE} 2>&1; done

		sudo apt-get update >> ${LOG_FILE} 2>&1
		sudo apt-get install -y ca-certificates curl >> ${LOG_FILE} 2>&1
		sudo install -m 0755 -d /etc/apt/keyrings >> ${LOG_FILE} 2>&1
		local temp_key=$(mktemp)
		trap 'rm -f "$temp_key"' RETURN
		if ! safe_download "$URL_DOCKER_GPG" "$temp_key" "Docker GPG key"; then
			log "ERROR" "Failed to download Docker GPG key."
			return 1
		fi
		sudo install -o root -g root -m 644 "$temp_key" /etc/apt/keyrings/docker.asc >> "$LOG_FILE" 2>&1

		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
			sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

        sudo apt-get update >> ${LOG_FILE} 2>&1
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> ${LOG_FILE} 2>&1
		sudo usermod -aG docker "$USER"
        ;;
    *)
		log "ERROR" "Docker installation for $DISTRO is not implemented in this script."
        ;;
    esac
}
