 
function get_package {
    local package_name="$1"

    if [[ -z "$package_name" ]]; then
        echo "${REDHI}❌ ERROR: Package name not specified${RESET}" >&2
        return 1
    fi

    echo "${BLUEHI}📦 Installing package: $package_name${RESET}"

    case "$DISTRO" in
        "arch")
            if ! sudo pacman -S --noconfirm "$package_name"; then
                echo "${REDHI}❌ ERROR: Failed to install $package_name with pacman${RESET}" >&2
                return 1
            fi
            ;;
        "ubuntu"|"debian")
            if ! sudo apt-get install -y "$package_name"; then
                echo "${REDHI}❌ ERROR: Failed to install $package_name with apt${RESET}" >&2
                return 1
            fi
            ;;
        "fedora")
            if ! sudo dnf install -y "$package_name"; then
                echo "${REDHI}❌ ERROR: Failed to install $package_name with dnf${RESET}" >&2
                return 1
            fi
            ;;
        "opensuse")
            if ! sudo zypper install -y "$package_name"; then
                echo "${REDHI}❌ ERROR: Failed to install $package_name with zypper${RESET}" >&2
                return 1
            fi
            ;;
        *)
            echo "${REDHI}❌ ERROR: Unsupported distribution for package installation: $DISTRO${RESET}" >&2
            return 1
            ;;
    esac

    echo "${GREENHI}✅ Package $package_name installed successfully${RESET}"
    return 0
}

function check_package {
	case "$DISTRO" in
	arch)
		pacman -Q "$1" >/dev/null 2>&1
		;;
	ubuntu | debian)
		dpkg -s "$1" >/dev/null 2>&1
		;;
	fedora)
		rpm -q "$1" >/dev/null 2>&1
		;;
	opensuse)
		zypper se --installed-only "$1" >/dev/null 2>&1
		;;
	*)
		return 1
		;;
	esac
}

function install_package() {
    local package="$1"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would install package: $package"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "[DRY-RUN] Package: $package"
        fi
        return 0
    fi
    
    check_package "$package"
    if [ "$?" -eq "0" ]; then
        if [[ "$VERBOSE" == "true" ]]; then
            log "SUCCESS" "Package $package is already installed"
        fi
    else
        if [[ "$VERBOSE" == "true" ]]; then
            log "INFO" "Installing $package"
        fi
        get_package "$package" >> "$LOG_FILE" 2>&1
    fi
}

# Update
function p_update {
	echo -e "${BLUEHI}===> Looking for '$DISTRO' updates...${RESET}"
	case "$DISTRO" in
	"arch")
		sudo pacman -Sy --noconfirm
		;;
	"ubuntu" | "debian")
		sudo apt-get update -y
		;;
	"fedora")
		sudo dnf check-update -y
		;;
	"opensuse")
		sudo zypper refresh
		;;
	*)
		echo -e "${REDHI}Unsupported distribution for update.${RESET}"
		return 1
		;;
	esac
}

# Clean
function p_clean {
	echo -e "${BLUEHI}"
	case "$DISTRO" in
	"arch")
		if [[ -n "$(pacman -Qdtq)" ]]; then
			sudo pacman -Rns $(pacman -Qdtq) --noconfirm
		fi
		;;
	"ubuntu" | "debian")
		sudo apt-get autoclean -y && sudo apt-get autoremove -y
		;;
	"fedora")
		sudo dnf autoremove -y
		;;
	"opensuse")
		sudo zypper clean --all
		;;
	esac

	echo -e "${RESET}"
}