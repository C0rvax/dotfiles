#!/usr/bin/env bash

function setup_kde {
	if [[ "$DESKTOP" == "kde" ]]; then
		# Modifier la police du système
		kwriteconfig5 --file kdeglobals --group General --key fixed "$FONT_SYSTEM_NAME,$FONT_SIZE_MONO,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key font "$FONT_SYSTEM_NAME,$FONT_SIZE_NORMAL,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key menuFont "$FONT_SYSTEM_NAME,$FONT_SIZE_NORMAL,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key smallestReadableFont "$FONT_SYSTEM_NAME,$FONT_SIZE_SMALL,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group General --key toolBarFont "$FONT_SYSTEM_NAME,$FONT_SIZE_NORMAL,-1,5,50,0,0,0,0,0,Regular"
		kwriteconfig5 --file kdeglobals --group WM --key activeFont "$FONT_SYSTEM_NAME,$FONT_SIZE_NORMAL,-1,5,50,0,0,0,0,0"

		# Activer le thème Breeze sombre
		lookandfeeltool -a "$KDE_THEME_DARK"

		# Modifier teminal par défaut
		kwriteconfig5 --file kdeglobals --group General --key TerminalApplication "$TERMINAL_APP"
		kwriteconfig5 --file kdeglobals --group General --key TerminalService "${TERMINAL_APP}.desktop"

		# Vérifier et ajouter le groupe [Icons] si nécéssaire
		# grep -q '^\[Icons\]' ~/.config/kdeglobals || echo -e "\n[Icons]" >>~/.config/kdeglobals
		kwriteconfig5 --file kdeglobals --group Icons --key Theme "$BUUF_ICONS_NAME"

		# Config de KFileDialiog
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort directories first" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort hidden files last" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "View Style" "DetailTree"

		# Raccourci terminal
		# kwriteconfig5 --file kglobalshortcutsrc --group "kde-konsole.desktop" --key "NewTerminal" "terminator,none,Open Terminal"
		kwriteconfig5 --file kglobalshortcutsrc --group "${TERMINAL_APP}.desktop" --key "_launch" "$TERMINAL_SHORTCUT,none,${TERMINAL_APP^}"
		#sed -i 's|konsole|${TERMINAL_APP}|g' ~/.config/kglobalshortcutsrc

		# Configurer un simple clic pour ouvrir les fichiers
		kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false

		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmDelete false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmEmptyTrash false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmTrash false

		# Appliquer les changements
		qdbus org.kde.KWin /KWin reconfigure
	fi
}
