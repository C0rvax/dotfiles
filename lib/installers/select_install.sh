# #!/bin/bash

# function select_installables_interactive {
#     local selected_level
    
#     if [[ "$ASSUME_YES" == "true" ]]; then
#         selected_level="base" # Par défaut en non-interactif
#         log "INFO" "Non-interactive mode: Defaulting to a 'base' installation."
#     else
#         print_title_element "INSTALLATION TYPE" "$BLUEHI"
#         print_table_line
#         print_left_element "1) Base (Minimal: core utils, dev tools, shell, nvim config)" "$BLUEHI"
#         print_left_element "2) Full (Recommended: 'Base' + graphical apps, Docker, etc.)" "$BLUEHI"
#         ask_question "Enter your choice [1-2]" choice

#         case "$choice" in
#             1) selected_level="base";;
#             2) selected_level="full";;
#             *) log "ERROR" "Invalid choice. Exiting."; print_table_line; exit 1;;
#         esac
#     fi

#     # Construire la liste des IDs à installer
#     local ids_to_consider=()
#     for id in "${!INSTALLABLES_LEVEL[@]}"; do
#         local level=${INSTALLABLES_LEVEL[$id]}
#         if [[ "$level" == "base" ]]; then
#             ids_to_consider+=("$id")
#         elif [[ "$level" == "full" && "$selected_level" == "full" ]]; then
#             ids_to_consider+=("$id")
#         fi
#     done

#     # Gérer les paquets optionnels
#     if [[ "$ASSUME_YES" != "true" ]]; then
#         ask_question "Include EMBEDDED packages (avr-libc, etc.)? [y/N]" include_embedded
#         if [[ "$include_embedded" =~ ^[yY]$ ]]; then
#             for id in "${!INSTALLABLES_LEVEL[@]}"; do
#                 if [[ "${INSTALLABLES_LEVEL[$id]}" == "optional" && "${INSTALLABLES_CATEGORY[$id]}" == "C_EMBEDDED" ]]; then
#                     ids_to_consider+=("$id")
#                 fi
#             done
#         fi

#         ask_question "Include LibreOffice suite? [y/N]" include_office
#         if [[ "$include_office" =~ ^[yY]$ ]]; then
#             for id in "${!INSTALLABLES_LEVEL[@]}"; do
#                 if [[ "${INSTALLABLES_LEVEL[$id]}" == "optional" && "${INSTALLABLES_CATEGORY[$id]}" == "C_OFFICE" ]]; then
#                     ids_to_consider+=("$id")
#                 fi
#             done
#         fi
#     fi

#     SELECTED_IDS=("${ids_to_consider[@]}")
# }

# function select_installables_tui {
#     log "INFO" "Launching TUI package selector..."

#     # Le TUI sélectionne par catégorie. On lui passe les titres.
#     local category_titles=()
#     declare -gA TITLE_TO_CAT_NAME_MAP # Pour retrouver le nom de la variable après sélection
#     for category_info in "${CATEGORIES_ORDER[@]}"; do
#         local cat_name="${category_info%%:*}"
#         local cat_title="${category_info#*:}"
#         local clean_title=$(echo "$cat_title" | sed -e 's/--- //' -e 's/ ---//' -e 's/ (Optionnel)//')
#         category_titles+=("$clean_title")
#         TITLE_TO_CAT_NAME_MAP["$clean_title"]="$cat_name"
#     done
    
#     # Compilation du sélecteur (inchangé)
#     if [ ! -x ./selector ]; then
#         log "WARNING" "'selector' not compiled. Attempting compilation..."
#         if ! command -v gcc &> /dev/null || ! gcc selector.c -o selector -lncurses; then
#             log "ERROR" "Failed to compile 'selector'. Aborting."
#             exit 1
#         else
#             log "SUCCESS" "'selector' compiled."
#         fi
#     fi

#     local selected_output
#     selected_output=$(./selector "${category_titles[@]}")
    
#     if [ -z "$selected_output" ]; then
#         log "WARNING" "No categories selected or operation cancelled. Exiting."
#         return
#     fi
    
#     local selected_titles=()
#     mapfile -t selected_titles <<< "$selected_output"

#     local ids_to_consider=()
#     for title in "${selected_titles[@]}"; do
#         local cat_name=${TITLE_TO_CAT_NAME_MAP["$title"]}
#         if [ -n "$cat_name" ]; then
#             # Utiliser l'indirection pour obtenir les IDs de la catégorie
#             local ids_in_category_ref="${cat_name}[@]"
#             ids_to_consider+=("${!ids_in_category_ref}")
#         fi
#     done
    
#     SELECTED_IDS=("${ids_to_consider[@]}")
# }

#!/bin/bash
# Contient tout ce qui est lié à la sélection des paquets.
select_installation_type() {
    print_table_line
	echo "| Choisissez votre type d'installation:                                                              |"
	echo "|   1) Base (outils essentiels pour le développement en console)                                    |"
	echo "|   2) Complète (Base + applications graphiques et outils lourds comme Docker)                       |"
	echo "|   3) Personnalisée (TUI pour choisir les catégories - à venir)                                     |"
    print_table_line
	read -p "Votre choix [1-3]: " choice
	case "$choice" in
	1) echo "base" ;;
	2) echo "full" ;;
	3) echo "custom" ;;
	*) echo "base" ;;
	esac
}

select_optional_packages() {
    local optional_packages_to_add=()
    local temp_packages=()
    echo >&2
    echo "Paquets optionnels disponibles:" >&2
    read -p "Inclure les outils de développement embarqué? [y/N]: " embedded
    if [[ "$embedded" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "embedded")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi
    read -p "Inclure LibreOffice? [y/N]: " office
    if [[ "$office" =~ ^[yY]$ ]]; then
        mapfile -t temp_packages < <(get_packages_by_category "office")
        optional_packages_to_add+=("${temp_packages[@]}")
    fi
    if [[ ${#optional_packages_to_add[@]} -gt 0 ]]; then
        printf '%s\n' "${optional_packages_to_add[@]}"
    fi
}

install_selected_packages() {
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
        if [[ -z "$id" ]]; then
            log "ERROR" "ID de paquet vide détecté. Ligne: '${pkg_def}'. On saute."
            continue
        fi
        if [[ "${AUDIT_STATUS[$id]}" == "installed" ]]; then
            log "SUCCESS" "($current/$total) Déjà installé : $desc"
            continue
        fi
        log "INFO" "($current/$total) Installation : $desc"
        if eval "$install_cmd"; then
            log "SUCCESS" "($current/$total) OK : $desc installé."
            AUDIT_STATUS[$id]="installed"
        else
            log "ERROR" "($current/$total) ÉCHEC : L'installation de $desc a échoué."
        fi
        print_table_line
    done
}