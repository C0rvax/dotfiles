// #include <ncurses.h>
// #include <stdlib.h>
// #include <string.h>

// // Structure pour stocker nos options de menu
// typedef struct {
//     char *name;      // Le nom de la catégorie à afficher
//     int selected;    // 0 = non sélectionné, 1 = sélectionné
// } MenuItem;

// void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight);

// int main(int argc, char *argv[]) {
//     // On s'attend à recevoir les options en arguments
//     if (argc == 1) {
//         fprintf(stderr, "Usage: %s <option1> <option2> ...\n", argv[0]);
//         return 1;
//     }

//     int n_choices = argc - 1;
//     MenuItem *menu_items = malloc(n_choices * sizeof(MenuItem));
//     for (int i = 0; i < n_choices; ++i) {
//         menu_items[i].name = argv[i + 1];
//         menu_items[i].selected = 0; // Initialement, rien n'est sélectionné
//     }

//     WINDOW *menu_win;
//     int highlight = 0;
//     int choice = 0;
//     int c;

//     // Initialisation de ncurses
//     initscr();
//     clear();
//     noecho();             // Ne pas afficher les touches pressées
//     cbreak();             // Réagir aux touches instantanément
//     curs_set(0);          // Cacher le curseur
//     start_color();        // Activer les couleurs
    
//     // Définir des paires de couleurs
//     init_pair(1, COLOR_WHITE, COLOR_BLUE); // Ligne sélectionnée (surbrillance)
//     init_pair(2, COLOR_GREEN, COLOR_BLACK); // Case cochée
//     init_pair(3, COLOR_WHITE, COLOR_BLACK); // Texte normal

//     // Créer la fenêtre pour le menu
//     int height = n_choices + 4; // Hauteur nécessaire
//     int width = 80;             // Largeur fixe pour l'exemple
//     int starty = (LINES - height) / 2;
//     int startx = (COLS - width) / 2;

//     menu_win = newwin(height, width, starty, startx);
//     keypad(menu_win, TRUE); // Activer les flèches, F1, etc.
    
//     mvprintw(0, (COLS - 45) / 2, "Sélectionnez les paquets à installer");
//     mvprintw(1, (COLS - 60) / 2, "(Utilisez les flèches HAUT/BAS, ESPACE pour cocher, ENTRÉE pour valider)");
//     refresh();

//     print_menu(menu_win, menu_items, n_choices, highlight);

//     // Boucle principale de l'interface
//     while (1) {
//         c = wgetch(menu_win);
//         switch (c) {
//             case KEY_UP:
//                 if (highlight == 0)
//                     highlight = n_choices - 1;
//                 else
//                     --highlight;
//                 break;
//             case KEY_DOWN:
//                 if (highlight == n_choices - 1)
//                     highlight = 0;
//                 else
//                     ++highlight;
//                 break;
//             case ' ': // Barre d'espace pour cocher/décocher
//                 menu_items[highlight].selected = !menu_items[highlight].selected;
//                 break;
//             case 10: // Touche Entrée
//                 choice = highlight;
//                 goto end_loop; // Sortir de la boucle
//             case 'q':
//             case 'Q':
//                 goto end_loop; // Quitter
//         }
//         print_menu(menu_win, menu_items, n_choices, highlight);
//     }
// end_loop:

//     // Terminer ncurses proprement
//     endwin();

//     // Imprimer les résultats sur stdout pour que le script bash puisse les lire
//     for (int i = 0; i < n_choices; ++i) {
//         if (menu_items[i].selected) {
//             printf("%s\n", menu_items[i].name);
//         }
//     }
    
//     free(menu_items);
//     return 0;
// }

// // Fonction pour afficher le menu
// void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight) {
//     int x = 2, y = 2;
//     box(menu_win, 0, 0);
//     for (int i = 0; i < count; ++i) {
//         if (highlight == i) { // Mettre la ligne en surbrillance
//             wattron(menu_win, A_REVERSE | COLOR_PAIR(1));
//         } else {
//             wattroff(menu_win, A_REVERSE | COLOR_PAIR(1));
//         }

//         // Afficher la checkbox
//         if(items[i].selected) {
//             mvwprintw(menu_win, y + i, x, "[x] %s", items[i].name);
//         } else {
//             mvwprintw(menu_win, y + i, x, "[ ] %s", items[i].name);
//         }
//     }
//     wrefresh(menu_win);
// }

#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> // Nécessaire pour isatty()

// Structure pour stocker nos options de menu
typedef struct {
    char *name;      // Le nom de la catégorie à afficher
    int selected;    // 0 = non sélectionné, 1 = sélectionné
} MenuItem;

// On passe le SCREEN* en plus
void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight);

int main(int argc, char *argv[]) {
    // On s'attend à recevoir les options en arguments
    if (argc == 1) {
        fprintf(stderr, "Usage: %s <option1> <option2> ...\n", argv[0]);
        return 1;
    }

    int n_choices = argc - 1;
    MenuItem *menu_items = malloc(n_choices * sizeof(MenuItem));
    if (menu_items == NULL) {
        fprintf(stderr, "Erreur d'allocation mémoire\n");
        return 1;
    }
    for (int i = 0; i < n_choices; ++i) {
        menu_items[i].name = argv[i + 1];
        menu_items[i].selected = 0; // Initialement, rien n'est sélectionné
    }

    // --- DEBUT DE LA MODIFICATION MAJEURE ---

    SCREEN *main_screen = NULL;
    FILE *tty_in = NULL;
    FILE *tty_out = NULL;

    // Si la sortie standard n'est PAS un terminal,
    // on initialise ncurses sur /dev/tty explicitement.
    if (!isatty(STDOUT_FILENO)) {
        tty_in = fopen("/dev/tty", "r");
        tty_out = fopen("/dev/tty", "w");
        if (tty_in == NULL || tty_out == NULL) {
            fprintf(stderr, "Impossible d'ouvrir /dev/tty\n");
            // Nettoyage avant de quitter
            if (tty_in) fclose(tty_in);
            if (tty_out) fclose(tty_out);
            free(menu_items);
            return 1;
        }
        main_screen = newterm(NULL, tty_out, tty_in);
        set_term(main_screen);
    } else {
        // Comportement normal si lancé directement
        initscr();
    }

    // --- FIN DE LA MODIFICATION MAJEURE ---

    // Le reste du code reste quasi identique, on utilise la fenêtre par défaut
    clear();
    noecho();
    cbreak();
    curs_set(0);
    start_color();
    
    init_pair(1, COLOR_WHITE, COLOR_BLUE);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_WHITE, COLOR_BLACK);

    int height = n_choices + 4;
    int width = 80;
    int starty = (LINES - height) / 2;
    int startx = (COLS - width) / 2;
    
    // Le titre et les instructions sont mieux dans la fenêtre elle-même
    // car le `clear()` les efface.
    // On les affichera sur `stdscr` qui est la fenêtre principale.
    mvprintw(starty - 3, (COLS - 45) / 2, "Sélectionnez les paquets à installer");
    mvprintw(starty - 2, (COLS - 60) / 2, "(ESPACE pour cocher, ENTRÉE pour valider, Q pour quitter)");
    refresh();

    WINDOW *menu_win = newwin(height, width, starty, startx);
    keypad(menu_win, TRUE);

    print_menu(menu_win, menu_items, n_choices, 0); // Highlight 0 au début

    int highlight = 0;
    int c;
    int quit_flag = 0; // 0 = continuer, 1 = valider, 2 = annuler

    while (!quit_flag) {
        c = wgetch(menu_win);
        switch (c) {
            case KEY_UP:
                highlight = (highlight == 0) ? n_choices - 1 : highlight - 1;
                break;
            case KEY_DOWN:
                highlight = (highlight == n_choices - 1) ? 0 : highlight + 1;
                break;
            case ' ': // Barre d'espace pour cocher/décocher
                menu_items[highlight].selected = !menu_items[highlight].selected;
                break;
            case 10: // Touche Entrée pour VALIDER
                quit_flag = 1; // Valider et sortir
                break;
            case 'q':
            case 'Q':
                quit_flag = 2; // Annuler et sortir
                break;
        }
        if (!quit_flag) {
            print_menu(menu_win, menu_items, n_choices, highlight);
        }
    }

end_loop: // Le goto n'est plus nécessaire mais on le garde pour la structure

    endwin();

    // Si on a utilisé un terminal spécial, on le ferme
    if (main_screen != NULL) {
        delscreen(main_screen);
        if (tty_in) fclose(tty_in);
        if (tty_out) fclose(tty_out);
    }
    
    // Si l'utilisateur a validé (et non annulé), on imprime la sélection
    if (quit_flag == 1) {
        // Imprimer les résultats sur stdout pour que le script bash puisse les lire
        for (int i = 0; i < n_choices; ++i) {
            if (menu_items[i].selected) {
                printf("%s\n", menu_items[i].name);
            }
        }
    }
    // Si quit_flag est 2 (ou 0), on n'imprime rien, ce qui est correct pour une annulation.

    free(menu_items);
    return 0;
}

// Pas de changement ici
void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight) {
    int x = 2, y = 2;
    box(menu_win, 0, 0);
    for (int i = 0; i < count; ++i) {
        wattron(menu_win, COLOR_PAIR(3)); // Couleur par défaut
        if (highlight == i) {
            wattron(menu_win, COLOR_PAIR(1));
        }

        if(items[i].selected) {
            wattron(menu_win, COLOR_PAIR(2));
            mvwprintw(menu_win, y + i, x, "[x]");
            wattroff(menu_win, COLOR_PAIR(2));
             if (highlight == i) { // Réappliquer la surbrillance
                 wattron(menu_win, COLOR_PAIR(1));
             }
            mvwprintw(menu_win, y + i, x + 4, "%s", items[i].name);
        } else {
            mvwprintw(menu_win, y + i, x, "[ ] %s", items[i].name);
        }

        if (highlight == i) {
            wattroff(menu_win, COLOR_PAIR(1));
        }
    }
    wrefresh(menu_win);
}