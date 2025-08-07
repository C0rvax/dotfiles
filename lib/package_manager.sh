#!/bin/bash

function get_package {
	local package_name="$1"

	if [[ -z "$package_name" ]]; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FATAL] get_package called with no package name" >>"$LOG_FILE"
		return 1
	fi

	case "$DISTRO" in
	"arch")
		sudo pacman -S --noconfirm "$package_name" >>"$LOG_FILE" 2>&1
		;;
	"ubuntu" | "debian")
		sudo apt-get install -y "$package_name" >>"$LOG_FILE" 2>&1
		;;
	"fedora")
		sudo dnf install -y "$package_name" >>"$LOG_FILE" 2>&1
		;;
	"opensuse")
		sudo zypper install -y "$package_name" >>"$LOG_FILE" 2>&1
		;;
	*)
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FATAL] get_package called with no package name" >>"$LOG_FILE"
		return 1
		;;
	esac

	return $?
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
		return 0
	fi
	if [[ "$VERBOSE" == "true" ]]; then
		log "INFO" "📦 Installing package: $package"
	fi

	if get_package "$package"; then
		if [[ "$VERBOSE" == "true" ]]; then
			log "SUCCESS" "Package $package installed successfully"
		fi
	else
		log "ERROR" "Failed to install package $package"
		return 1
	fi
}

# Update
function p_update {
	log "INFO" "Updating package lists for $DISTRO..."
	case "$DISTRO" in
	"arch")
		sudo pacman -Sy --noconfirm >>"$LOG_FILE" 2>&1
		;;
	"ubuntu" | "debian")
		sudo apt-get update -y >>"$LOG_FILE" 2>&1
		;;
	"fedora")
		sudo dnf check-update -y >>"$LOG_FILE" 2>&1
		;;
	"opensuse")
		sudo zypper refresh >>"$LOG_FILE" 2>&1
		;;
	*)
		log "ERROR" "Unsupported distribution for update."
		return 1
		;;
	esac
}

# Clean
function p_clean {
	log "INFO" "Cleaning up unused packages for $DISTRO..."
	case "$DISTRO" in
	"arch")
		if [[ -n "$(pacman -Qdtq)" ]]; then
			sudo pacman -Rns $(pacman -Qdtq) --noconfirm >>"$LOG_FILE" 2>&1
		fi
		;;
	"ubuntu" | "debian")
		sudo apt-get autoclean -y >>"$LOG_FILE" 2>&1 && sudo apt-get autoremove -y >>"$LOG_FILE" 2>&1
		;;
	"fedora")
		sudo dnf autoremove -y >>"$LOG_FILE" 2>&1
		;;
	"opensuse")
		sudo zypper clean --all >>"$LOG_FILE" 2>&1
		;;
	esac
}