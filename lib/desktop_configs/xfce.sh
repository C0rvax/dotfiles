#!/bin/bash

function setup_xfce {
	if [[ "$DESKTOP" == "xfce" ]]; then
		log "INFO" "Setting up XFCE-specific configurations..."

		# Modifier la police du système
		xfconf-query -c xsettings -p /Gtk/FontName -s "'$FONT_SYSTEM_NAME' 10"

		# Définir le thème d'icônes
		xfconf-query -c xsettings -p /Net/IconThemeName -s "'$BUUF_ICONS_NAME'"

		# Définir le thème GTK
		xfconf-query -c xsettings -p /Net/ThemeName -s "'$THEME_GTK_DARK'"

		# Modifier le terminal par défaut
		xfconf-query -c xfce4-terminal -p /general/default-emulator -s "'$TERMINAL_APP'"

		# Trier les dossiers en premier et afficher les fichiers cachés
		xfconf-query -c thunar -p /misc-small-toolbar-icons -s false
		xfconf-query -c thunar -p /misc-show-hidden -s true

		log "SUCCESS" "XFCE configuration applied successfully!"
	fi
}
