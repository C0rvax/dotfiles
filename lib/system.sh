#!/bin/bash

function detect_distro {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		DISTRO=$ID
	else
		exit 1
	fi
}

function log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        ERROR)   print_left_element "❌ $message" "$REDHI" ;;
        SUCCESS) print_left_element "✅ $message" "$GREENHI" ;;
        INFO)    print_left_element "ℹ️ $message" "$BLUEHI" ;;
        WARNING) print_left_element "⚠️ $message" "$YELLOWHI" ;;
        DL)      print_left_element "📥 $message" "$CYAN" ;;
        CLONE)   print_left_element "📦 $message" "$CYAN" ;;
    esac
}

# Detect desktop environment
function detect_desktop {
	if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]] || [[ "$DESKTOP_SESSION" == "plasma" ]]; then
		DESKTOP="kde"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] || [[ "$DESKTOP_SESSION" == "gnome" ]]; then
		DESKTOP="gnome"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]] || [[ "$DESKTOP_SESSION" == "xfce" ]]; then
		DESKTOP="xfce"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"LXDE"* ]] || [[ "$DESKTOP_SESSION" == "lxde" ]]; then
		DESKTOP="lxde"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"LXQt"* ]] || [[ "$DESKTOP_SESSION" == "lxqt" ]]; then
		DESKTOP="lxqt"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"MATE"* ]] || [[ "$DESKTOP_SESSION" == "mate" ]]; then
		DESKTOP="mate"
	elif [[ "$XDG_CURRENT_DESKTOP" == *"Cinnamon"* ]] || [[ "$DESKTOP_SESSION" == "cinnamon" ]]; then
		DESKTOP="cinnamon"
	else
		DESKTOP="unknown"
	fi
}

function prompt_for_sudo {
    if [ "$UID" -eq "0" ]; then
        log "ERROR" "Do not execute with sudo. Your password will be asked in the console."
        exit 1
    fi
    log "INFO" "Sudo privileges will be required. Please enter your password if prompted."
    sudo -v 
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to obtain sudo privileges. Aborting."
        exit 1
    fi
}

# Lance une boucle en arrière-plan pour maintenir la session sudo active.
# Variable globale pour stocker le PID de la boucle sudo
SUDO_PID=

# Lance une boucle en arrière-plan pour maintenir la session sudo active.
function start_sudo_keep_alive {
    # Si la boucle est déjà lancée, ne rien faire
    if [ -n "$SUDO_PID" ]; then
        return
    fi

    log "INFO" "Starting sudo keep-alive loop."
    
    sudo -v
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to obtain initial sudo credentials."
        exit 1
    fi

    ( while true; do
        # -n (non-interactive) -v (validate/update ticket)
        # Met à jour le ticket sans demander de mot de passe.
        # S'il a expiré, la commande échoue silencieusement.
        sudo -n -v
        sleep 45
    done ) &

    SUDO_PID=$!

    trap "stop_sudo_keep_alive" EXIT SIGINT SIGTERM
}

function stop_sudo_keep_alive {
    if [ -n "$SUDO_PID" ] && ps -p "$SUDO_PID" > /dev/null; then
        log "INFO" "Stopping sudo keep-alive loop (PID: $SUDO_PID)..."
        kill "$SUDO_PID"
        SUDO_PID=
    fi
}

function check_file {
	if [ -f "${1}" ]; then
		return 0
	else
		return 1
	fi
}

function check_directory {
	if [ -d "${1}" ]; then
		return 0
	else
		return 1
	fi
}

function safe_download {
    local url="$1"
    local output="$2"
    local description="$3"

    log "DL" "Downloading $description..."

    if ! wget -O "$output" "$url" > ${LOG_FILE} 2>&1; then
        log "ERROR" "Failed to download $description"
        log "INFO" "   URL: $url"
        return 1
    fi

    if [[ ! -s "$output" ]]; then
        log "ERROR" "The downloaded file is empty or does not exist"
        rm -f "$output"  # Clean up the empty file
        return 1
    fi

    log "SUCCESS" "$description downloaded successfully"
    return 0
}

function safe_git_clone {
    local repo_url="$1"
    local destination="$2"
    local description="$3"

    log "CLONE" "Cloning $description..."

    if [[ -d "$destination" ]]; then
        log "WARNING" "The directory $destination already exists"
        read -p "Do you want to replace it? [y/N]: " replace
        if [[ "$replace" =~ ^[yY]$ ]]; then
            rm -rf "$destination"
        else
            log "INFO" "Cloning skipped"
            return 0
        fi
    fi

    if ! git clone "$repo_url" "$destination" > ${LOG_FILE} 2>&1; then
        log "ERROR" "Failed to clone $description"
        log "INFO" "   Repo: $repo_url"
        return 1
    fi

    log "SUCCESS" "$description cloned successfully"
    return 0
}

function ensure_sudo_global_timestamp {
    local config_file="$PATH_SUDOERS"
    local config_content="Defaults timestamp_type=global\nDefaults !authenticate\nDefaults timestamp_timeout=30"

    if [ -f "$config_file" ]; then
        if grep -q "timestamp_type=global" "$config_file" && \
           grep -q "!authenticate" "$config_file" && \
           grep -q "timestamp_timeout=30" "$config_file"; then
            return 0
        fi
        log "INFO" "Updating sudo configuration for the script..."
    else
        log "INFO" "Configuring sudo for a seamless script experience."
        log "WARNING" "This will prevent sudo from asking for your password repeatedly."
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would create '$config_file' with content: '$config_content'"
        return 0
    fi

    if ! (printf "$config_content" | sudo tee "$config_file" > /dev/null); then
        log "ERROR" "Failed to create sudo configuration file at '$config_file'."
        return 1
    fi
    
    if ! sudo chmod 0440 "$config_file"; then
        log "ERROR" "Failed to set correct permissions on '$config_file'."
        sudo rm -f "$config_file"
        return 1
    fi

    log "SUCCESS" "Sudo timestamp is now set to 'global'."
    print_table_line
}

function cleanup_sudo_config {
    local config_file="$PATH_SUDOERS"

    if [ ! -f "$config_file" ]; then
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        log "INFO" "Restoring default sudo behavior by removing custom rules..."
        if ! sudo rm -f "$config_file"; then
            log "ERROR" "Could not remove the sudo configuration file: $config_file"
            log "WARNING" "Please remove it manually to restore default sudo behavior."
        else
            log "SUCCESS" "Sudo configuration restored to default."
        fi
    fi
}