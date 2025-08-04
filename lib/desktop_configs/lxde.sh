#!/usr/bin/env bash

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
