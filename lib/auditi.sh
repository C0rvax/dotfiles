#!/bin/bash

# Contient tout ce qui est lié à l'audit et à son affichage.
function audit_packages() {
    local installed=0
    local missing=0
    mapfile -t all_packages < <(get_all_packages)
    local total=${#all_packages[@]}

    log "INFO" "Lancement de l'audit de ${total} paquets..."
    print_table_line
    for pkg_def in "${all_packages[@]}"; do
        local id; id=$(get_package_info "$pkg_def" id)
        local desc; desc=$(get_package_info "$pkg_def" desc)
        local check_cmd; check_cmd=$(get_package_info "$pkg_def" check)
        if eval "$check_cmd"; then
            ((installed++))
            AUDIT_STATUS[$id]="installed"
            print_left_element "✓ $desc" "$GREEN"
        else
            ((missing++))
            AUDIT_STATUS[$id]="missing"
            print_left_element "✗ $desc" "$RED"
        fi
    done
    print_table_line
    log "SUCCESS" "Audit terminé : $installed installés, $missing manquants."
}