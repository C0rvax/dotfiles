
# Detect Linux distribution
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
        ERROR)   echo -e "${REDHI}❌ $message${RESET}" ;;
        SUCCESS) echo -e "${GREENHI}✅ $message${RESET}" ;;
        INFO)    echo -e "${BLUEHI}ℹ️  $message${RESET}" ;;
        WARNING) echo -e "${YELLOW}⚠️  $message${RESET}" ;;
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

# Check if launched with sudo
function check_sudo {
	if [ "$UID" -eq "0" ]; then
		echo -e "${REDHI}Do not execute with sudo, Your password will be asked in the console.${RESET}"
		exit
	else
		echo -e "${BLUEHI}Please enter your password to continue...${RESET}"
		sudo -v
		while true; do
			sudo -n true
			sleep 60
			kill -0 "$$" || exit
		done 2>/dev/null &
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

# Function to download with error handling
function safe_download {
    local url="$1"
    local output="$2"
    local description="$3"

    echo "📥 Downloading $description..."

    if ! wget -O "$output" "$url"; then
        echo "❌ ERROR: Failed to download $description" >&2
        echo "   URL: $url" >&2
        return 1
    fi

    # Check that the file exists and is not empty
    if [[ ! -s "$output" ]]; then
        echo "❌ ERROR: The downloaded file is empty or does not exist" >&2
        rm -f "$output"  # Clean up the empty file
        return 1
    fi

    echo "✅ $description downloaded successfully"
    return 0
}

# Function to clone with error handling
function safe_git_clone {
    local repo_url="$1"
    local destination="$2"
    local description="$3"

    echo "📦 Cloning $description..."

    # Check if the directory already exists
    if [[ -d "$destination" ]]; then
        echo "⚠️  The directory $destination already exists"
        read -p "Do you want to replace it? [y/N]: " replace
        if [[ "$replace" =~ ^[yY]$ ]]; then
            rm -rf "$destination"
        else
            echo "⏭️  Cloning skipped"
            return 0
        fi
    fi

    if ! git clone "$repo_url" "$destination"; then
        echo "❌ ERROR: Failed to clone $description" >&2
        echo "   Repo: $repo_url" >&2
        return 1
    fi

    echo "✅ $description cloned successfully"
    return 0
}