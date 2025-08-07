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

pkg_install() {
	local package="$1"

	if [[ "$DRY_RUN" == "true" ]]; then
		echo "[SIMULATION] Installation de $package"
		return 0
	fi

	case "$DISTRO" in
	ubuntu | debian)
		sudo apt-get install -y "$package" &>/dev/null
		;;
	arch)
		sudo pacman -S --noconfirm "$package" &>/dev/null
		;;
	fedora)
		sudo dnf install -y "$package" &>/dev/null
		;;
	*)
		return 1
		;;
	esac
}

# === FONCTIONS DE PARSING ===

get_package_info() {
	local package_def="$1"
	local field="$2"

	IFS=':' read -ra parts <<<"$package_def"
	case "$field" in
	id) echo "${parts[0]}" ;;
	desc) echo "${parts[1]}" ;;
	level) echo "${parts[2]}" ;;
	category) echo "${parts[3]}" ;;
	check) echo "${parts[4]}" ;;
	install) echo "${parts[5]}" ;;
	status) echo "${parts[6]}" ;;
	esac
}

get_all_packages() {
	printf '%s\n' "${SYSTEM_PACKAGES[@]}" "${SPECIAL_INSTALLS[@]}" "${OPTIONAL_PACKAGES[@]}"
}

get_packages_by_level() {
	local level="$1"
	get_all_packages | while read -r pkg; do
		if [[ "$(get_package_info "$pkg" level)" == "$level" ]]; then
			echo "$pkg"
		fi
	done
}

get_packages_by_category() {
	local category="$1"
	get_all_packages | while read -r pkg; do
		if [[ "$(get_package_info "$pkg" category)" == "$category" ]]; then
			echo "$pkg"
		fi
	done
}

# audit_packages() {
# 	local total=0
# 	local installed=0
# 	local missing=0

# 	echo "Vérification de votre système..."

# 	get_all_packages | while read -r pkg_def; do
# 		local id=$(get_package_info "$pkg_def" id)
# 		local desc=$(get_package_info "$pkg_def" desc)
# 		local check_cmd=$(get_package_info "$pkg_def" check)

# 		((total++))

# 		if eval "$check_cmd" &>/dev/null; then
# 			((installed++))
# 			echo "✓ $desc"
# 		else
# 			((missing++))
# 			echo "✗ $desc"
# 			echo "$missing"
# 		fi
# 	done

# 	echo
# 	echo "Résumé: $installed installés, $missing manquants"
# }

function audit_packages() {
    local installed=0
    local missing=0

    # On utilise mapfile pour charger tous les paquets en une fois, c'est plus propre
    mapfile -t all_packages < <(get_all_packages)
    local total=${#all_packages[@]}

    log "INFO" "Lancement de l'audit de ${total} paquets..."
    print_table_line

    for pkg_def in "${all_packages[@]}"; do
        local id; id=$(get_package_info "$pkg_def" id)
        local desc; desc=$(get_package_info "$pkg_def" desc)
        local check_cmd; check_cmd=$(get_package_info "$pkg_def" check)

        # On exécute la vérification en masquant TOUTES les sorties
        if eval "$check_cmd" &>/dev/null; then
            ((installed++))
            AUDIT_STATUS[$id]="installed"
            print_left_element "✓ $desc" "$GREEN"
        else
            ((missing++))
            AUDIT_STATUS[$id]="missing"
            print_left_element "✗ $desc" "$RED"
        fi
    done

    print_table_line
    log "SUCCESS" "Audit terminé : $installed installés, $missing manquants."
    print_table_line
}

# === SÉLECTION INTERACTIVE ===

select_installation_type() {
	echo "Choisissez votre type d'installation:"
	echo "1) Base (outils essentiels)"
	echo "2) Complète (base + applications)"
	echo "3) Personnalisée"

	read -p "Votre choix [1-3]: " choice

	case "$choice" in
	1) echo "base" ;;
	2) echo "full" ;;
	3) echo "custom" ;;
	*) echo "base" ;; # Par défaut
	esac
}

select_optional_packages() {
	local selected=()

	echo
	echo "Paquets optionnels disponibles:"

	# Développement embarqué
	read -p "Inclure les outils de développement embarqué? [y/N]: " embedded
	if [[ "$embedded" =~ ^[yY]$ ]]; then
		selected+=($(get_packages_by_category "embedded"))
	fi

	# Bureautique
	read -p "Inclure LibreOffice? [y/N]: " office
	if [[ "$office" =~ ^[yY]$ ]]; then
		selected+=($(get_packages_by_category "office"))
	fi

	printf '%s\n' "${selected[@]}"
}

# === INSTALLATION PRINCIPALE ===

# install_selected_packages() {
# 	local packages=("$@")
# 	local current=0
# 	local total=${#packages[@]}

# 	echo "Installation en cours..."

# 	for pkg_def in "${packages[@]}"; do
# 		((current++))
# 		local id=$(get_package_info "$pkg_def" id)
# 		local desc=$(get_package_info "$pkg_def" desc)
# 		local check_cmd=$(get_package_info "$pkg_def" check)
# 		local install_cmd=$(get_package_info "$pkg_def" install)

# 		printf "[%d/%d] %s... " "$current" "$total" "$desc"

# 		# Vérifier si déjà installé
# 		if eval "$check_cmd" 2>/dev/null; then
# 			echo "déjà installé"
# 			continue
# 		fi

# 		# Installer
# 		if eval "$install_cmd" 2>/dev/null; then
# 			echo "✓"
# 		else
# 			echo "✗ échec"
# 		fi
# 	done
# }

function install_selected_packages() {
    local packages_to_process=("$@")
    local current=0
    local total=${#packages_to_process[@]}

    log "INFO" "Début de l'installation de $total paquets..."
    print_table_line

    for pkg_def in "${packages_to_process[@]}"; do
        ((current++))
        local id; id=$(get_package_info "$pkg_def" id)
        local desc; desc=$(get_package_info "$pkg_def" desc)
        local install_cmd; install_cmd=$(get_package_info "$pkg_def" install)

        # On ne VÉRIFIE PLUS, on CONSULTE le résultat de l'audit !
        if [[ "${AUDIT_STATUS[$id]}" == "installed" ]]; then
            log "SUCCESS" "($current/$total) Déjà installé : $desc"
            continue
        fi

        log "INFO" "($current/$total) Installation : $desc"
        
        if eval "$install_cmd"; then
            log "SUCCESS" "($current/$total) OK : $desc installé avec succès."
            # On met à jour le statut au cas où une étape ultérieure en aurait besoin
            AUDIT_STATUS[$id]="installed"
        else
            log "ERROR" "($current/$total) ÉCHEC : L'installation de $desc a échoué."
        fi
        print_table_line
    done
}

# === WORKFLOW PRINCIPAL ===

run_package_installation() {
	# 1. Audit initial
	audit_packages

	# 2. Sélection utilisateur
	local install_type
	if [[ "$ASSUME_YES" == "true" ]]; then
		install_type="base"
	else
		install_type=$(select_installation_type)
	fi

	# 3. Collecte des paquets à installer
	local packages_to_install=()

	case "$install_type" in
	base)
		mapfile -t packages_to_install < <(get_packages_by_level "base")
		;;
	full)
		mapfile -t packages_to_install < <(get_packages_by_level "base")
		mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
		;;
	custom)
		# Interface TUI ou sélection avancée à implémenter
		echo "Mode personnalisé pas encore implémenté, passage en mode complet"
		mapfile -t packages_to_install < <(get_packages_by_level "base")
		mapfile -t -O "${#packages_to_install[@]}" packages_to_install < <(get_packages_by_level "full")
		;;
	esac

	# 4. Ajouter les paquets optionnels si demandés
	if [[ "$install_type" != "base" && "$ASSUME_YES" != "true" ]]; then
		local optional_packages
		mapfile -t optional_packages < <(select_optional_packages)
		packages_to_install+=("${optional_packages[@]}")
	fi

	# 5. Installation
	if [[ ${#packages_to_install[@]} -gt 0 ]]; then
		echo
		echo "Paquets sélectionnés: ${#packages_to_install[@]}"

		if [[ "$ASSUME_YES" != "true" ]]; then
			read -p "Continuer? [Y/n]: " confirm
			[[ "$confirm" =~ ^[nN]$ ]] && return 1
		fi

		install_selected_packages "${packages_to_install[@]}"
	else
		echo "Aucun paquet à installer."
	fi
}

