 
function get_package {
    local package_name="$1"

    if [[ -z "$package_name" ]]; then
        echo "❌ ERROR: Package name not specified" >&2
        return 1
    fi

    echo "📦 Installing package: $package_name"

    case "$DISTRO" in
        "arch")
            if ! sudo pacman -S --noconfirm "$package_name"; then
                echo "❌ ERROR: Failed to install $package_name with pacman" >&2
                return 1
            fi
            ;;
        "ubuntu"|"debian")
            if ! sudo apt-get install -y "$package_name"; then
                echo "❌ ERROR: Failed to install $package_name with apt" >&2
                return 1
            fi
            ;;
        "fedora")
            if ! sudo dnf install -y "$package_name"; then
                echo "❌ ERROR: Failed to install $package_name with dnf" >&2
                return 1
            fi
            ;;
        "opensuse")
            if ! sudo zypper install -y "$package_name"; then
                echo "❌ ERROR: Failed to install $package_name with zypper" >&2
                return 1
            fi
            ;;
        *)
            echo "❌ ERROR: Unsupported distribution for package installation: $DISTRO" >&2
            return 1
            ;;
    esac

    echo "✅ Package $package_name installed successfully"
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

function install_package {
	check_package ${1}
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Package ${1} is installed! ####"
	else
		echo -e "${BLUEHI} **** Installing ${1} ****${YELLOW}"
		get_package ${1}
	fi
}

# Update
function p_update {
	echo -e "${BLUEHI}===> Looking for '$DISTRO'updates...${RESET}"
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