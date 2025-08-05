#!/bin/bash

get_display_width() {
    local str="$1"
    local clean_str=$(printf '%s' "$str" | sed 's/\x1b\[[0-9;]*m//g')
    
    # Si l'emoji ℹ️ prend 1 colonne mais wc -m le compte comme 2 caractères
    # Il faut soustraire 1 pour chaque emoji
    local base_length=$(printf '%s' "$clean_str" | wc -m)
    local info_count=$(printf '%s' "$clean_str" | grep -o 'ℹ️' | wc -l 2>/dev/null || echo 0)
    
    echo $((base_length - info_count))
}

function print_left_element {
    local text="$1"
    local color="$2"
    local visible_len=$(get_display_width "$text")
    local padding=$((TABLE_WIDTH - visible_len - 3))
    printf "|"
    printf " ${color}${text}${RESET}"
    printf " %.0s" $(seq 1 $padding)
    printf "|\n"
}

TABLE_WIDTH=80
BLUEHI='\033[1;34m'
RESET='\033[0m'
message="Sudo privileges will be required. Please enter your password if prompted."

echo "=== TESTS MULTIPLES ==="
echo "TABLE_WIDTH: $TABLE_WIDTH"
echo ""

test_str="ℹ️ $message"
echo "Chaîne de test: '$test_str'"
echo ""

echo "1. Test emoji = 1 colonne d'affichage:"
visible_len=$(get_display_width "$test_str")
echo "   Largeur calculée: $visible_len"
echo "   Padding: $((TABLE_WIDTH - visible_len - 3))"
print_left_element "ℹ️ $message" "$BLUEHI"
echo ""

echo "2. Comparaison avec chaîne équivalente (75 caractères 'X'):"
test_str_x=$(printf 'X%.0s' $(seq 1 75))
visible_len_x=$(printf '%s' "$test_str_x" | wc -m)
padding_x=$((TABLE_WIDTH - visible_len_x - 3))
echo "   Largeur 75 X: $visible_len_x, Padding: $padding_x"
printf "|"
printf " ${BLUEHI}${test_str_x}${RESET}"
printf " %.0s" $(seq 1 $padding_x)
printf "|\n"
echo ""


echo "3. Test de mesure manuelle:"
echo "|${test_str}|"
echo "Si c'est 76 caractères, l'emoji prend 1 colonne"
echo "Si c'est 77 caractères, l'emoji prend 2 colonnes"
echo ""


echo "4. Ligne de référence pour compter:"
echo "|1234567890123456789012345678901234567890123456789012345678901234567890123456|"
echo "|${test_str}|"
echo ""
