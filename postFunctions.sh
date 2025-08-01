#function get_home_dir {
#	if [[ -z "$SUDO_USER" ]]; then
#		# Le script n'est pas exécuté avec sudo.
#		HOME_DIR_DIR="$HOME_DIR" # Utilise $HOME_DIR si sudo n'est pas utilisé (rare)
#	else
#		# Le script est exécuté avec sudo.
#		SUDO_USER="$SUDO_USER"
#		HOME_DIR_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
#		if [[ -z "$HOME_DIR_DIR" ]]; then
#			echo "Erreur : impossible de déterminer le répertoire personnel de $SUDO_USER"
#			exit 1
#		fi
#	fi
#}

# Detect Linux distribution
function detect_distro {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		DISTRO=$ID
		# echo "Distro detected: $DISTRO"
	else
		# echo "Unsupported distribution."
		exit 1
	fi
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
	# echo "Desktop detected: $DESKTOP"
}

# INSTALL FIREFOX WITH FLATPAK
function install_firefox {
	sudo apt install flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.mozilla.firefox
}

# SET GIT GLOBAL CONFIG
function install_git {
	echo -e "${BLUEHI} ---- GIT global config ----"
	read -p "Do You want to set git user and email ? [y/n]" rep
	case $rep in
	Y)
		read -p 'Git username: ' gituser
		read -p 'Git email: ' gitemail
		git config --global user.name "$gituser"
		git config --global user.email $gitemail
		echo -e "${RESET}"
		;;
	y)
		read -p 'Git username: ' gituser
		read -p 'Git email: ' gitemail
		git config --global user.name "$gituser"
		git config --global user.email $gitemail
		echo -e "${RESET}"
		;;
	N)
		echo " ---- Skipping ----"
		echo -e "${RESET}"
		;;
	n)
		echo " ---- Skipping ----"
		echo -e "${RESET}"
		;;
	esac
}

# INSTALL NVIM + CONFIG
function install_nvim {
	cd $HOME
	check_file $HOME/AppImage/nvim.appimage
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### NeoVim is installed! ####${RESET}"
	else
		check_directory $HOME/AppImage
		if [ "$?" -eq "0" ]; then
			echo -e "${BLUEHI} **** Installing NeoVim ****${YELLOW}"
		else
			mkdir AppImage
		fi
		cd $HOME/AppImage
		wget -O nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
		chmod u+x nvim.appimage
		cd $HOME
		echo -e "${RESET}"
	fi

	check_directory $HOME/.config/nvim
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### nvim config is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing nvim config ****${YELLOW}"
		git clone https://github.com/C0rvax/nvim.git $HOME/.config/nvim
	fi
}

# SET BINARIES
function set_bin {
	ln -s ~/scripts/synchroToNas.sh ~/.local/bin/babel
	ln -s ~/scripts/syncToGit.sh ~/.local/bin/syncgit
}

# INSTALL VERACRYPT
function install_veracrypt {
	echo ""
	check_package "veracrypt"
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Package veracrypt is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing veracrypt ****${YELLOW}"
		sudo add-apt-repository ppa:unit193/encryption -y
		sudo apt-get update -y
		sudo apt-get install veracrypt -y
	fi
}

# INSTALL NODEJS
function install_node {
	cd
	curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
	source ~/.zshrc
	nvm install node # Installe la dernière version stable
	nvm use node

	#nvm install 20
	#nvm use 20
}

# INSTALL DOCKER
function install_docker_ubuntu {
	if [[ "$DISTRO" == "ubuntu" ]]; then
		#remove wrong pkgs
		for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

		#set up apt repo
		# Add Docker's official GPG key:
		sudo apt-get update
		sudo apt-get install ca-certificates curl
		sudo install -m 0755 -d /etc/apt/keyrings
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
		sudo chmod a+r /etc/apt/keyrings/docker.asc

		# Add the repository to Apt sources:
		echo \
			"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
			sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
		sudo apt-get update

		sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

		sudo usermod -aG docker $USER
	fi
}

# INSTALL OH MY ZSH
function install_zsh {
	cd $HOME
	check_directory $HOME/.oh-my-zsh
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Oh My Zsh is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing Oh My Zsh ****${YELLOW}"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
	echo ""
}

# INSTALL FONTS
function install_fonts {
	check_directory $HOME/Themes
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Folder Themes already exist! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Creating folder ****${YELLOW}"
		mkdir $HOME/Themes
	fi
	check_directory $HOME/Themes/Fonts
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Folder Fonts already exist! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Creating folder ****${YELLOW}"
		mkdir -p $HOME/Themes/Fonts
	fi
	check_file $HOME/Themes/Fonts/'MesloLGS NF Regular.ttf'
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Fonts is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing fonts ****${YELLOW}"
		curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output $HOME/Themes/Fonts/'MesloLGS NF Regular.ttf'
		curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output $HOME/Themes/Fonts/'MesloLGS NF Bold.ttf'
		curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output $HOME/Themes/Fonts/'MesloLGS NF Italic.ttf'
		curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output $HOME/Themes/Fonts/'MesloLGS NF Bold Italic.ttf'
		sudo mkdir -p /usr/share/fonts/truetype/custom
		sudo cp MesloLGS\ NF\ *.ttf /usr/share/fonts/truetype/custom
		sudo fc-cache -fv
	fi
	check_directory $HOME/Themes/Icons
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Folder Icons already exist! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Creating folder ****${YELLOW}"
		mkdir $HOME/Themes/Icons
	fi
	check_directory $HOME/Themes/Icons/buuf-nestort
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### buuf-nestort already exist! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Downloading Pack ****${YELLOW}"
		git clone https://git.disroot.org/eudaimon/buuf-nestort.git $HOME/Themes/Icons/buuf-nestort
		sudo ln -s $HOME/Themes/Icons/buuf-nestort /usr/share/icons/buuf-nestort
	fi
}

# CREATE SSH KEY
function create_ssh_key {
	echo -e "${BLUEHI} ---- Creating SSH Key ----${RESET}"
	if [ -f ~/.ssh/id_ed25519 ]; then
		echo -e "${GREENHI}SSH key ~/.ssh/id_ed25519 already exists. Skipping.${RESET}"
		return
	fi

	# Prompt user for the comment (usually email)
	read -p "Enter your email for the SSH key comment: " ssh_email
	if [ -z "$ssh_email" ]; then
		echo "${REDHI}Email cannot be empty. Aborting key generation.${RESET}"
		return
	fi

	ssh-keygen -t ed25519 -C "$ssh_email" -N "" -f ~/.ssh/id_ed25519

	# S'assurer des bonnes permissions pour la clé privée
	chmod 600 ~/.ssh/id_ed25519
	chmod 700 ~/.ssh
	chmod 644 ~/.ssh/id_ed25519.pub
	echo -e "${GREENHI}SSH key created successfully.${RESET}"
	echo "Your public key is:"
	cat ~/.ssh/id_ed25519.pub
}

# INSTALL ZSH CONFIG
function install_zconfig {
	cd $HOME
	check_directory $HOME/.zsh
	if [ "$?" -eq "0" ]; then
		echo -e "${GREENHI} #### Zsh config is installed! ####${RESET}"
	else
		echo -e "${BLUEHI} **** Installing Zsh config ****${YELLOW}"
		git clone https://github.com/C0rvax/.zsh.git $HOME/.zsh
		bash .zsh/install_zshrc.sh
	fi
	sudo git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
	echo -e "${RESET}"
}

# SET VLC DEFAULT VIDEO PLAYER
function setup_vlc {
	for type in video/mp4 video/x-matroska video/x-msvideo video/quicktime video/webm video/x-flv video/mpeg; do
		xdg-mime default vlc.desktop $type
	done
}

# SET KDE CONFIG
function setup_kde {
	if [[ "$DESKTOP" == "kde" ]]; then
		# Modifier la police du système
		kwriteconfig5 --file kdeglobals --group General --key fixed "MesloLGS NF,9,-1,5,50,0,0,0,0,0"
		kwriteconfig5 --file kdeglobals --group General --key font "MesloLGS NF,10,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key menuFont "MesloLGS NF,10,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key smallestReadableFont "MesloLGS NF,8,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key toolBarFont "MesloLGS NF,10,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group WM --key activeFont "MesloLGS NF,10,-1,5,50,0,0,0,0,0"

		# Modifier teminal par défaut
		kwriteconfig5 --file kdeglobals --group General --key TerminalApplication "terminator"
		kwriteconfig5 --file kdeglobals --group General --key TerminalService "terminator.desktop"

		# Vérifier et ajouter le groupe [Icons] si nécéssaire
		grep -q '^\[Icons\]' ~/.config/kdeglobals || echo -e "\n[Icons]" >>~/.config/kdeglobals

		# Activer les Icones
		kwriteconfig5 --file kdeglobals --group Icons --key Theme "buuf-nestort"

		# Activer le thème Breeze sombre
		lookandfeeltool -a org.kde.breezedark.desktop

		# Config de KFileDialiog
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort directories first" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort hidden files last" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "View Style" "DetailTree"

		# Raccourci terminator
		#kwriteconfig5 --file kglobalshortcutsrc --group "kde-konsole.desktop" --key "NewTerminal" "terminator,none,Open Terminal"
		sed -i 's|konsole|terminator|' ~/.config/kglobalshortcutsrc

		# Configurer un simple clic pour ouvrir les fichiers
		kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false

		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmDelete false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmEmptyTrash false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmTrash false

		# Appliquer les changements
		qdbus org.kde.KWin /KWin reconfigure
	fi
}

# Adapt GNOME-specific settings (example placeholder)
function setup_gnome {
	if [[ "$DESKTOP" == "gnome" ]]; then
		echo "Setting up GNOME-specific configurations..."

		# Modifier la police du système
		gsettings set org.gnome.desktop.interface font-name 'MesloLGS NF 10'
		gsettings set org.gnome.desktop.interface document-font-name 'MesloLGS NF 10'
		gsettings set org.gnome.desktop.wm.preferences titlebar-font 'MesloLGS NF Bold 10'
		gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS NF 9'

		# Définir le thème d'icônes
		gsettings set org.gnome.desktop.interface icon-theme 'buuf-nestort'

		# Définir le thème sombre Breeze
		gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark'
		gsettings set org.gnome.desktop.wm.preferences theme 'Breeze-Dark'

		# Modifier le terminal par défaut
		gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'
		gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-x'

		# Afficher les fichiers cachés dans le gestionnaire de fichiers
		gsettings set org.gnome.nautilus.preferences show-hidden-files true

		# Trier les dossiers en premier
		gsettings set org.gnome.nautilus.preferences sort-directories-first true

		# Utiliser un simple clic pour ouvrir les fichiers
		gsettings set org.gnome.nautilus.preferences click-policy 'single'

		# Désactiver les confirmations de suppression
		gsettings set org.gnome.desktop.interface enable-delete false
		gsettings set org.gnome.desktop.privacy remember-recent-files false

		# Appliquer les changements immédiatement (relancer GNOME Shell si Wayland)
		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
			gnome-extensions disable "user-theme@gnome-shell-extensions.gcampax.github.com"
			gnome-extensions enable "user-theme@gnome-shell-extensions.gcampax.github.com"
		else
			killall -3 gnome-shell
		fi

		echo "GNOME configuration applied successfully!"
	fi
}

# SET XFCE CONFIG
function setup_xfce {
	if [[ "$DESKTOP" == "xfce" ]]; then
		echo "Setting up XFCE-specific configurations..."

		# Modifier la police du système
		xfconf-query -c xsettings -p /Gtk/FontName -s "MesloLGS NF 10"

		# Définir le thème d'icônes
		xfconf-query -c xsettings -p /Net/IconThemeName -s "buuf-nestort"

		# Définir le thème GTK
		xfconf-query -c xsettings -p /Net/ThemeName -s "Breeze-Dark"

		# Modifier le terminal par défaut
		xfconf-query -c xfce4-terminal -p /general/default-emulator -s "terminator"

		# Trier les dossiers en premier et afficher les fichiers cachés
		xfconf-query -c thunar -p /misc-small-toolbar-icons -s false
		xfconf-query -c thunar -p /misc-show-hidden -s true

		echo "XFCE configuration applied successfully!"
	fi
}

# SET LXDE CONFIG
function setup_lxde {
	if [[ "$DESKTOP" == "lxde" ]]; then
		echo "Setting up LXDE-specific configurations..."

		# Modifier la police du système (Openbox)
		sed -i 's/^ *<font .*$/  <font>MesloLGS NF 10<\/font>/' ~/.config/openbox/lxde-rc.xml

		# Définir le thème d'icônes
		sed -i 's/^ *gtk-icon-theme-name=.*$/gtk-icon-theme-name="buuf-nestort"/' ~/.config/lxsession/LXDE/desktop.conf

		# Définir le thème GTK
		sed -i 's/^ *gtk-theme-name=.*$/gtk-theme-name="Breeze-Dark"/' ~/.config/lxsession/LXDE/desktop.conf

		# Modifier le terminal par défaut
		sed -i 's/^ *terminal=.*$/terminal=terminator/' ~/.config/lxsession/LXDE/desktop.conf

		echo "LXDE configuration applied successfully!"
	fi
}

# SET LXQT CONFIG
function setup_lxqt {
	if [[ "$DESKTOP" == "lxqt" ]]; then
		echo "Setting up LXQt-specific configurations..."

		# Modifier la police du système
		lxqt-config-appearance --set-font "MesloLGS NF 10"

		# Définir le thème d'icônes
		lxqt-config-appearance --set-icon-theme "buuf-nestort"

		# Définir le thème GTK
		lxqt-config-appearance --set-style "Breeze-Dark"

		# Modifier le terminal par défaut
		lxqt-config-session --set-terminal "terminator"

		echo "LXQt configuration applied successfully!"
	fi
}

# SET MATE CONFIG
function setup_mate {
	if [[ "$DESKTOP" == "mate" ]]; then
		echo "Setting up MATE-specific configurations..."

		# Modifier la police du système
		gsettings set org.mate.interface font-name 'MesloLGS NF 10'
		gsettings set org.mate.interface document-font-name 'MesloLGS NF 10'
		gsettings set org.mate.interface monospace-font-name 'MesloLGS NF 9'
		gsettings set org.mate.Marco.general titlebar-font 'MesloLGS NF Bold 10'

		# Définir le thème d'icônes
		gsettings set org.mate.interface icon-theme 'buuf-nestort'

		# Définir le thème GTK
		gsettings set org.mate.interface gtk-theme 'Breeze-Dark'

		# Modifier le terminal par défaut
		gsettings set org.mate.applications-terminal exec 'terminator'

		# Afficher les fichiers cachés et trier les dossiers en premier
		gsettings set org.mate.caja.preferences show-hidden-files true
		gsettings set org.mate.caja.preferences sort-directories-first true

		echo "MATE configuration applied successfully!"
	fi
}

# SET CINNAMON CONFIG
function setup_cinnamon {
	if [[ "$DESKTOP" == "cinnamon" ]]; then
		echo "Setting up Cinnamon-specific configurations..."

		# Modifier la police du système
		gsettings set org.cinnamon.desktop.interface font-name 'MesloLGS NF 10'
		gsettings set org.cinnamon.desktop.interface document-font-name 'MesloLGS NF 10'
		gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'MesloLGS NF Bold 10'
		gsettings set org.cinnamon.desktop.interface monospace-font-name 'MesloLGS NF 9'

		# Définir le thème d'icônes
		gsettings set org.cinnamon.desktop.interface icon-theme 'buuf-nestort'

		# Définir le thème GTK
		gsettings set org.cinnamon.desktop.interface gtk-theme 'Breeze-Dark'

		# Modifier le terminal par défaut
		gsettings set org.cinnamon.desktop.default-applications.terminal exec 'terminator'

		# Afficher les fichiers cachés et trier les dossiers en premier
		gsettings set org.nemo.preferences show-hidden-files true
		gsettings set org.nemo.preferences sort-directories-first true

		echo "Cinnamon configuration applied successfully!"
	fi
}

# FUNCTIONS
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

function check_package {
	dpkg -s ${1} &>/dev/null

	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
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

# Modify package installation for more distributions
function get_package {
	if [[ "$DISTRO" == "arch" ]]; then
		sudo pacman -S --noconfirm ${1}
	elif [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
		sudo apt-get install -y ${1}
	elif [[ "$DISTRO" == "fedora" ]]; then
		sudo dnf install -y ${1}
	elif [[ "$DISTRO" == "opensuse" ]]; then
		sudo zypper install -y ${1}
	else
		echo "Unsupported distribution for package installation."
		exit 1
	fi
}

# Check if launched with sudo
function check_sudo {
	if [ "$UID" -eq "0" ]; then
		echo -e "${REDHI}Do not execute with sudo, Your password will be asked in the console.${RESET}"
		exit
	fi
}

# Update
function p_update {
	echo -e "${BLUEHI}"
	sudo apt-get update -y && sudo apt-get upgrade -y
	echo -e "${RESET}"
}

# Clean
function p_clean {
	echo -e "${BLUEHI}"
	sudo apt-get autoclean -y && sudo apt-get autoremove -y
	echo -e "${RESET}"
}

# Display logo
function display_logo {
	echo -e "${GREENHI}"
	echo "   ██████╗ ██████╗ ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗"
	echo "  ██╔════╝██╔═████╗██╔══██╗██║   ██║██╔══██╗╚██╗██╔╝"
	echo "  ██║     ██║██╔██║██████╔╝██║   ██║███████║ ╚███╔╝"
	echo "  ██║     ████╔╝██║██╔══██╗╚██╗ ██╔╝██╔══██║ ██╔██╗"
	echo "  ╚██████╗╚██████╔╝██║  ██║ ╚████╔╝ ██║  ██║██╔╝ ██╗"
	echo "   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝"
	echo -e "${BLUEHI}"

	echo "         ██████╗  ██████╗ ███████╗████████╗"
	echo "         ██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝"
	echo "         ██████╔╝██║   ██║███████╗   ██║   "
	echo "         ██╔═══╝ ██║   ██║╚════██║   ██║   "
	echo "         ██║     ╚██████╔╝███████║   ██║   "
	echo "         ╚═╝      ╚═════╝ ╚══════╝   ╚═╝   "
	echo ""
	echo "██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     "
	echo "██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     "
	echo "██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     "
	echo "██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     "
	echo "██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗"
	echo "╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝"
	echo -e "${RESET}"
}

TABLE_WIDTH=96

function print_table_line {
	printf "+%.0s" $(seq 1 $TABLE_WIDTH)
	printf "+\n"
}

function print_table_header {
	local title=$1
	local padding=$(((TABLE_WIDTH - ${#title} - 2) / 2))
	local remainder=$(((TABLE_WIDTH - ${#title} - 2) % 2 - 1))
	print_table_line
	printf "|"
	printf " %.0s" $(seq 1 $padding)
	# Votre calcul pour le reste est un peu complexe, simplifions-le tout en garantissant l'alignement
	echo -e -n " ${BLUEHI}${title}${RESET} "
	printf " %.0s" $(seq 1 $((padding + remainder)))
	printf "|\n"
	print_table_line
}

# --- Bulletproof Audit Logic ---

# Generic grid printer: the definitive solution for aligned, colored columns.
function print_grid {
	local num_cols=$1
	shift
	local items_with_colors=("$@")

	# Calculate the width of the content area for each column
	local col_content_width=$(((TABLE_WIDTH - 1) / num_cols - 2)) # -2 for spaces

	for i in $(seq 0 $((num_cols * 2)) $((${#items_with_colors[@]} - 1))); do
		local line_to_print="|"
		for j in $(seq 0 $((num_cols - 1))); do
			local text_idx=$((i + j * 2))
			local color_idx=$((text_idx + 1))

			local text=${items_with_colors[text_idx]:-""}
			local color=${items_with_colors[color_idx]:-$RESET}

			# 1. Pad the text WITHOUT color to ensure correct width calculation
			local padded_text
			printf -v padded_text " %-*s " "$col_content_width" "$text"

			# 2. Build the line segment with color applied around the padded text
			line_to_print+="${color}${padded_text}${RESET}|"
		done
		echo -e "$line_to_print"
	done
}

# Prints only the content for packages, without header or footer lines.
function print_packages_content {
	declare -A seen_items
	local master_list=()
	for item in \
		"${PKGS_CORE_UTILS[@]}" \
		"${PKGS_UTILS[@]}" \
		"${PKGS_DEV[@]}" \
		"${PKGS_SHELL[@]}" \
		"${PKGS_NVIM[@]}" \
		"${PKGS_APPS[@]}" \
		"${PKGS_OFFICE[@]}" \
		"${PKGS_EMBEDDED[@]}"; do
		if [[ -z "${seen_items[$item]}" ]]; then
			master_list+=("$item")
			seen_items["$item"]=1
		fi
	done

	local current_packages_to_print=()
	local is_first_category=true
	for item in "${master_list[@]}"; do
		if [[ $item == '#'* ]]; then
			if [ ${#current_packages_to_print[@]} -gt 0 ]; then
				print_grid 4 "${current_packages_to_print[@]}"
				current_packages_to_print=()
			fi

			if [ "$is_first_category" = false ]; then
				print_table_line
			fi

			local category_title
			printf -v category_title ">> %s" "$(echo "$item" | sed -e 's/# --- //' -e 's/ ---//')"
			local padded_title
			# Correction de l'alignement du titre de catégorie
			printf -v padded_title " %-*s" $(($TABLE_WIDTH - 2)) "$category_title"
			echo -e "|${YELLOW}${padded_title}${RESET}|"

			is_first_category=false
		else
			check_package "$item"
			if [ $? -eq 0 ]; then
				current_packages_to_print+=("$item" "$GREENHI")
			else
				current_packages_to_print+=("$item" "$REDHI")
			fi
		fi
	done

	if [ ${#current_packages_to_print[@]} -gt 0 ]; then
		print_grid 4 "${current_packages_to_print[@]}"
	fi
}

# Prints only the content for configurations, without header or footer lines.
function print_configurations_content {
	local checks=(
		"Oh My Zsh" "check_directory '$HOME/.oh-my-zsh'"
		"Zsh Custom Config" "check_directory '$HOME/.zsh'"
		"Nvim Config" "check_directory '$HOME/.config/nvim'"
		"Nvim AppImage" "check_file '$HOME/AppImage/nvim.appimage'"
		"MesloLGS Fonts" "check_file '$HOME/Themes/Fonts/MesloLGS NF Regular.ttf'"
		"Buuf Nestort Icons" "check_directory '$HOME/Themes/Icons/buuf-nestort'"
		"Docker" "check_package 'docker-ce'"
		"Git User Name" "git config --global user.name >/dev/null 2>&1"
		"Git User Email" "git config --global user.email >/dev/null 2>&1"
		"SSH Key (ed25519)" "check_file '$HOME/.ssh/id_ed25519'"
	)

	local items_to_print=()
	local all_dots="............................................................"
	for i in $(seq 0 2 $((${#checks[@]} - 1))); do
		local description=${checks[i]}
		local check_command=${checks[i + 1]}
		local text_to_print color

		local dot_padding_len=$((42 - ${#description} - 2))
		local dot_padding=${all_dots:0:$dot_padding_len}

		if eval "$check_command"; then
			text_to_print="${description} ${dot_padding} [✔]"
			color=$GREENHI
		else
			text_to_print="${description} ${dot_padding} [✘]"
			color=$REDHI
		fi
		items_to_print+=("$text_to_print" "$color")
	done

	print_grid 2 "${items_to_print[@]}"
}

# ** NEW ** Prints the Distro and Desktop row.
function print_system_info_row {
	local all_dots="............................................................"
	local items_to_print=()

	# Format Distro info
	local distro_desc="Distribution"
	local distro_pad_len=$((42 - ${#distro_desc} - ${#DISTRO}))
	local distro_pad=${all_dots:0:$distro_pad_len}
	items_to_print+=("${distro_desc} ${distro_pad} ${DISTRO}" "$BLUE")

	# Format Desktop info
	local desktop_desc="Desktop Env"
	local desktop_pad_len=$((42 - ${#desktop_desc} - ${#DESKTOP}))
	local desktop_pad=${all_dots:0:$desktop_pad_len}
	items_to_print+=("${desktop_desc} ${desktop_pad} ${DESKTOP}" "$BLUE")

	print_grid 2 "${items_to_print[@]}"
}

# The main function that orchestrates the unified audit table.
function run_audit {
	detect_distro
	detect_desktop

	# --- Start of the Unified Table ---
	print_table_header "SYSTEM AUDIT"

	# 1. Print System Info
	print_system_info_row

	# 2. Print Separator and Packages
	print_table_line
	print_packages_content

	# 3. Print Separator and Configurations
	print_table_line
	print_configurations_content

	# --- End of the Unified Table ---
	print_table_line
}

