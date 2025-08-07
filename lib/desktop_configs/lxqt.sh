#!/bin/bash

function setup_lxqt {
	if [[ "$DESKTOP" == "lxqt" ]]; then
		log "INFO" "Setting up LXQt-specific configurations..."

		# Modifier la police du système
		lxqt-config-appearance --set-font "'$FONT_SYSTEM_NAME 10"

		# Définir le thème d'icônes
		lxqt-config-appearance --set-icon-theme "'$BUUF_ICONS_NAME'"

		# Définir le thème GTK
		lxqt-config-appearance --set-style "'$KDE_THEME_DARK'"

		# Modifier le terminal par défaut
		lxqt-config-session --set-terminal "'$TERMINAL_APP'"

		log "SUCCESS" "LXQt configuration applied successfully!"
	fi
}