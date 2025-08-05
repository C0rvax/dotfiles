#include <ncurses.h>
#include <stdlib.h>
#include <string.h>

// Structure pour stocker nos options de menu
typedef struct {
    char *name;      // Le nom de la catégorie à afficher
    int selected;    // 0 = non sélectionné, 1 = sélectionné
} MenuItem;

void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight);

int main(int argc, char *argv[]) {
    // On s'attend à recevoir les options en arguments
    if (argc == 1) {
        fprintf(stderr, "Usage: %s <option1> <option2> ...\n", argv[0]);
        return 1;
    }

    int n_choices = argc - 1;
    MenuItem *menu_items = malloc(n_choices * sizeof(MenuItem));
    for (int i = 0; i < n_choices; ++i) {
        menu_items[i].name = argv[i + 1];
        menu_items[i].selected = 0; // Initialement, rien n'est sélectionné
    }

    WINDOW *menu_win;
    int highlight = 0;
    int choice = 0;
    int c;

    // Initialisation de ncurses
    initscr();
    clear();
    noecho();             // Ne pas afficher les touches pressées
    cbreak();             // Réagir aux touches instantanément
    curs_set(0);          // Cacher le curseur
    start_color();        // Activer les couleurs
    
    // Définir des paires de couleurs
    init_pair(1, COLOR_WHITE, COLOR_BLUE); // Ligne sélectionnée (surbrillance)
    init_pair(2, COLOR_GREEN, COLOR_BLACK); // Case cochée
    init_pair(3, COLOR_WHITE, COLOR_BLACK); // Texte normal

    // Créer la fenêtre pour le menu
    int height = n_choices + 4; // Hauteur nécessaire
    int width = 80;             // Largeur fixe pour l'exemple
    int starty = (LINES - height) / 2;
    int startx = (COLS - width) / 2;

    menu_win = newwin(height, width, starty, startx);
    keypad(menu_win, TRUE); // Activer les flèches, F1, etc.
    
    mvprintw(0, (COLS - 45) / 2, "Sélectionnez les paquets à installer");
    mvprintw(1, (COLS - 60) / 2, "(Utilisez les flèches HAUT/BAS, ESPACE pour cocher, ENTRÉE pour valider)");
    refresh();

    print_menu(menu_win, menu_items, n_choices, highlight);

    // Boucle principale de l'interface
    while (1) {
        c = wgetch(menu_win);
        switch (c) {
            case KEY_UP:
                if (highlight == 0)
                    highlight = n_choices - 1;
                else
                    --highlight;
                break;
            case KEY_DOWN:
                if (highlight == n_choices - 1)
                    highlight = 0;
                else
                    ++highlight;
                break;
            case ' ': // Barre d'espace pour cocher/décocher
                menu_items[highlight].selected = !menu_items[highlight].selected;
                break;
            case 10: // Touche Entrée
                choice = highlight;
                goto end_loop; // Sortir de la boucle
            case 'q':
            case 'Q':
                goto end_loop; // Quitter
        }
        print_menu(menu_win, menu_items, n_choices, highlight);
    }
end_loop:

    // Terminer ncurses proprement
    endwin();

    // Imprimer les résultats sur stdout pour que le script bash puisse les lire
    for (int i = 0; i < n_choices; ++i) {
        if (menu_items[i].selected) {
            printf("%s\n", menu_items[i].name);
        }
    }
    
    free(menu_items);
    return 0;
}

// Fonction pour afficher le menu
void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight) {
    int x = 2, y = 2;
    box(menu_win, 0, 0);
    for (int i = 0; i < count; ++i) {
        if (highlight == i) { // Mettre la ligne en surbrillance
            wattron(menu_win, A_REVERSE | COLOR_PAIR(1));
        } else {
            wattroff(menu_win, A_REVERSE | COLOR_PAIR(1));
        }

        // Afficher la checkbox
        if(items[i].selected) {
            mvwprintw(menu_win, y + i, x, "[x] %s", items[i].name);
        } else {
            mvwprintw(menu_win, y + i, x, "[ ] %s", items[i].name);
        }
    }
    wrefresh(menu_win);
}
