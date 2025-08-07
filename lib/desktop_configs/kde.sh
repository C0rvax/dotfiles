#!/bin/bash

function setup_kde {
	if [[ "$DESKTOP" == "kde" ]]; then
		if [[ "$DRY_RUN" == "true" ]]; then
			log "INFO" "[DRY-RUN] Would set up KDE desktop environment configurations."
			return 0
		fi
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
		kwriteconfig5 --file kdeglobals --group Icons --key Theme "$BUUF_ICONS_NAME"

		# Config de KFileDialiog
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort directories first" true
		# kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Sort hidden files last" true
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "View Style" "DetailTree"

		# hidden files
		pkill -f dolphin 2>/dev/null || true
		# Configuration principale pour les fichiers cachés
		kwriteconfig5 --file dolphinrc --group "General" --key "ShowHiddenFiles" true

		# Configuration pour les propriétés de vue globales
		kwriteconfig5 --file dolphinrc --group "ViewProperties" --key "hiddenFilesShown" true

		# Configuration alternative pour les versions récentes
		kwriteconfig5 --file dolphinrc --group "PreviewSettings" --key "hiddenFilesShown" true

		# Configuration pour ne pas se souvenir des propriétés de vue individuelles
		kwriteconfig5 --file dolphinrc --group "General" --key "RememberViewProperties" false

		# Configuration globale des fichiers cachés (pour KDE en général)
		kwriteconfig5 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" true

		# Raccourci terminal
		# kwriteconfig5 --file kglobalshortcutsrc --group "kde-konsole.desktop" --key "NewTerminal" "terminator,none,Open Terminal"
		kwriteconfig5 --file kglobalshortcutsrc --group "${TERMINAL_APP}.desktop" --key "_launch" "$TERMINAL_SHORTCUT,none,${TERMINAL_APP^}"

		# Configurer un simple clic pour ouvrir les fichiers
		kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false

		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmDelete false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmEmptyTrash false
		kwriteconfig5 --file kiorc --group Confirmations --key ConfirmTrash false

		# Forcer la synchronisation des configurations
		sync

		# Appliquer les changements
		qdbus org.kde.KWin /KWin reconfigure

		qdbus org.kde.kded5 /kded unloadModule filenamesearchmodule 2>/dev/null || true
		qdbus org.kde.kded5 /kded loadModule filenamesearchmodule 2>/dev/null || true
	fi
}
