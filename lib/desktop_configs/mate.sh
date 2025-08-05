#!/usr/bin/env bash

function setup_mate {
	if [[ "$DESKTOP" == "mate" ]]; then
		log "INFO" "Setting up MATE-specific configurations..."

		# Modifier la police du système
		gsettings set org.mate.interface font-name "'$FONT_SYSTEM_NAME' 10"
		gsettings set org.mate.interface document-font-name "'$FONT_SYSTEM_NAME' 10"
		gsettings set org.mate.interface monospace-font-name "'$FONT_SYSTEM_NAME' 9"
		gsettings set org.mate.Marco.general titlebar-font "'$FONT_SYSTEM_NAME Bold' 10"

		# Définir le thème d'icônes
		gsettings set org.mate.interface icon-theme "'$BUUF_ICONS_NAME'"

		# Définir le thème GTK
		gsettings set org.mate.interface gtk-theme "'$THEME_GTK_DARK'"

		# Modifier le terminal par défaut
		gsettings set org.mate.applications-terminal exec "'$TERMINAL_APP'"

		# Afficher les fichiers cachés et trier les dossiers en premier
		gsettings set org.mate.caja.preferences show-hidden-files true
		gsettings set org.mate.caja.preferences sort-directories-first true

		log "SUCCESS" "MATE configuration applied successfully!"
	fi
}