#!/bin/bash

function install_docker {
    case "$DISTRO" in
    "ubuntu"|"debian")
        log "INFO" "Installing Docker on $DISTRO..."
		for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg > ${LOG_FILE} 2>&1; done

		sudo apt-get update >> ${LOG_FILE} 2>&1
		sudo apt-get install -y ca-certificates curl >> ${LOG_FILE} 2>&1
		sudo install -m 0755 -d /etc/apt/keyrings >> ${LOG_FILE} 2>&1
		# Utilise la variable
		sudo curl -fsSL "$URL_DOCKER_GPG" -o /etc/apt/keyrings/docker.asc >> ${LOG_FILE} 2>&1
		sudo chmod a+r /etc/apt/keyrings/docker.asc >> ${LOG_FILE} 2>&1

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
