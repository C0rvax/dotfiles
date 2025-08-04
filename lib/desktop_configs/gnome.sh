#!/bin/bash

function setup_gnome {
	if [[ "$DESKTOP" == "gnome" ]]; then
		echo "Setting up GNOME-specific configurations..."

		# Modifier la police du système
		gsettings set org.gnome.desktop.interface font-name "'$FONT_SYSTEM_NAME 10'"
		gsettings set org.gnome.desktop.interface document-font-name "'$FONT_SYSTEM_NAME 10'"
		gsettings set org.gnome.desktop.wm.preferences titlebar-font "'$FONT_SYSTEM_NAME Bold 10'"
		gsettings set org.gnome.desktop.interface monospace-font-name "'$FONT_SYSTEM_NAME 9'"

		# Définir le thème d'icônes
		gsettings set org.gnome.desktop.interface icon-theme "'$BUUF_ICONS_NAME'"

		# Définir le thème sombre Breeze
		gsettings set org.gnome.desktop.interface gtk-theme "'$KDE_THEME_DARK'"
		gsettings set org.gnome.desktop.wm.preferences theme "'$KDE_THEME_DARK'"

		# Modifier le terminal par défaut
		gsettings set org.gnome.desktop.default-applications.terminal exec "'$TERMINAL_APP'"
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
