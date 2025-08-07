#!/bin/bash

# ==============================================================================
#  SCRIPT DE DIAGNOSTIC DES FONCTIONNALITÉS AVANCÉES DE BASH
# ==============================================================================

# On définit une couleur pour la sortie, c'est plus lisible
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Fonctions utilitaires ---

# Affiche un titre de section
section() {
    echo -e "\n${YELLOW}--- $1 ---${NC}"
}

# Affiche le résultat d'un test
# Usage: check "Description du test" $?
check() {
    if [ "$2" -eq 0 ]; then
        echo -e "  [${GREEN}OK${NC}] $1"
    else
        echo -e "  [${RED}ÉCHEC${NC}] $1"
    fi
}

# Une fonction simple qui génère plusieurs lignes de texte
# C'est notre "source de données" pour les tests.
generateur_de_lignes() {
    echo "ligne 1: a b"
    echo "ligne 2: c d"
    echo "ligne 3: e f"
}

# ==============================================================================
#                             DÉBUT DES TESTS
# ==============================================================================

section "1. Informations sur le Shell"
echo "  - Variable \$SHELL : $SHELL"
echo "  - Interpréteur actuel (via ps) : $(ps -p $$ -o comm=)"
echo "  - Version de Bash :"
bash --version | head -n 1
echo

# --- TEST N°1 : Le subshell classique avec un pipe `|` ---
section "2. Test du Subshell avec Pipe (le comportement qui pose problème)"
SUBTEST_VAR="initiale"
generateur_de_lignes | while read -r line; do
    # Cette modification ne devrait PAS être visible à l'extérieur
    SUBTEST_VAR="modifiée dans le pipe"
done
echo "  -> Variable après la boucle 'pipe | while': ${SUBTEST_VAR}"
# Le test réussit si la variable N'A PAS changé
if [[ "$SUBTEST_VAR" == "initiale" ]]; then
    check "La variable n'a pas été modifiée (comportement attendu, pipe crée un subshell)" 0
else
    check "La variable A été modifiée (comportement inattendu)" 1
fi

# --- TEST N°2 : La 'Process Substitution' < <(...) ---
section "3. Test de la Process Substitution (la solution recommandée)"
SUBTEST_VAR="initiale"
while IFS= read -r line; do
    # Cette modification DEVRAIT être visible à l'extérieur
    SUBTEST_VAR="modifiée avec < <(...)"
done < <(generateur_de_lignes)
echo "  -> Variable après la boucle 'while < <(...)': ${SUBTEST_VAR}"
# Le test réussit si la variable A changé
if [[ "$SUBTEST_VAR" == "modifiée avec < <(...)" ]]; then
    check "La variable a été modifiée (la process substitution fonctionne !)" 0
else
    check "La variable n'a pas été modifiée (la process substitution A ÉCHOUÉ)" 1
fi

# --- TEST N°3 : `mapfile` (ou `readarray`) avec 'Process Substitution' ---
section "4. Test de 'mapfile' (readarray) avec Process Substitution"
# On déclare un tableau vide
declare -a MON_TABLEAU=()
# On essaie de le remplir avec mapfile
mapfile -t MON_TABLEAU < <(generateur_de_lignes)

echo "  -> Nombre d'éléments dans le tableau : ${#MON_TABLEAU[@]}"
echo "  -> Contenu du premier élément : '${MON_TABLEAU[0]}'"
echo "  -> Contenu du tableau (via declare -p) :"
declare -p MON_TABLEAU

# Le test réussit si le tableau a 3 éléments
if [ "${#MON_TABLEAU[@]}" -eq 3 ]; then
    check "mapfile a correctement rempli le tableau" 0
else
    check "mapfile N'A PAS rempli le tableau" 1
fi

    