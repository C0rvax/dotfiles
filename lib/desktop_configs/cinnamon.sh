#!/usr/bin/env bash

function setup_cinnamon {
	if [[ "$DESKTOP" == "cinnamon" ]]; then
		log "INFO" "Setting up Cinnamon desktop environment..."

		# Modifier la police du système
		gsettings set org.cinnamon.desktop.interface font-name "'$FONT_SYSTEM_NAME' 10"
		gsettings set org.cinnamon.desktop.interface document-font-name "'$FONT_SYSTEM_NAME' 10"
		gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "'$FONT_SYSTEM_NAME Bold' 10"
		gsettings set org.cinnamon.desktop.interface monospace-font-name "'$FONT_SYSTEM_NAME' 9"

		# Définir le thème d'icônes
		gsettings set org.cinnamon.desktop.interface icon-theme "'$BUUF_ICONS_NAME'"

		# Définir le thème GTK
		gsettings set org.cinnamon.desktop.interface gtk-theme "'$THEME_GTK_DARK'"

		# Modifier le terminal par défaut
		gsettings set org.cinnamon.desktop.default-applications.terminal exec "'$TERMINAL_APP'"

		# Afficher les fichiers cachés et trier les dossiers en premier
		gsettings set org.nemo.preferences show-hidden-files true
		gsettings set org.nemo.preferences sort-directories-first true

		log "SUCCESS" "Cinnamon configuration applied successfully!"
	fi
}
