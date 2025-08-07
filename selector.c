// #include <ncurses.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>

// // Structure pour stocker nos options de menu
// typedef struct {
//     char *name;      // Le nom de la catégorie à afficher
//     int selected;    // 0 = non sélectionné, 1 = sélectionné
// } MenuItem;

// // On passe le SCREEN* en plus
// void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight);

// int main(int argc, char *argv[]) {
//     // On s'attend à recevoir les options en arguments
//     if (argc == 1) {
//         fprintf(stderr, "Usage: %s <option1> <option2> ...\n", argv[0]);
//         return 1;
//     }

//     int n_choices = argc - 1;
//     MenuItem *menu_items = malloc(n_choices * sizeof(MenuItem));
//     if (menu_items == NULL) {
//         fprintf(stderr, "Erreur d'allocation mémoire\n");
//         return 1;
//     }
//     for (int i = 0; i < n_choices; ++i) {
//         menu_items[i].name = argv[i + 1];
//         menu_items[i].selected = 0; // Initialement, rien n'est sélectionné
//     }

//     SCREEN *main_screen = NULL;
//     FILE *tty_in = NULL;
//     FILE *tty_out = NULL;

//     // Si la sortie standard n'est PAS un terminal,
//     // on initialise ncurses sur /dev/tty explicitement.
//     if (!isatty(STDOUT_FILENO)) {
//         tty_in = fopen("/dev/tty", "r");
//         tty_out = fopen("/dev/tty", "w");
//         if (tty_in == NULL || tty_out == NULL) {
//             fprintf(stderr, "Impossible d'ouvrir /dev/tty\n");
//             if (tty_in) fclose(tty_in);
//             if (tty_out) fclose(tty_out);
//             free(menu_items);
//             return 1;
//         }
//         main_screen = newterm(NULL, tty_out, tty_in);
//         set_term(main_screen);
//     } else {
//         initscr();
//     }

//     clear();
//     noecho();
//     cbreak();
//     curs_set(0);
//     start_color();
    
//     init_pair(1, COLOR_WHITE, COLOR_BLUE);
//     init_pair(2, COLOR_GREEN, COLOR_BLACK);
//     init_pair(3, COLOR_WHITE, COLOR_BLACK);

//     int height = n_choices + 4;
//     int width = 80;
//     int starty = (LINES - height) / 2;
//     int startx = (COLS - width) / 2;
    
//     mvprintw(starty - 3, (COLS - 45) / 2, "Sélectionnez les paquets à installer");
//     mvprintw(starty - 2, (COLS - 60) / 2, "(ESPACE pour cocher, ENTRÉE pour valider, Q pour quitter)");
//     refresh();

//     WINDOW *menu_win = newwin(height, width, starty, startx);
//     keypad(menu_win, TRUE);

//     print_menu(menu_win, menu_items, n_choices, 0); // Highlight 0 au début

//     int highlight = 0;
//     int c;
//     int quit_flag = 0; // 0 = continuer, 1 = valider, 2 = annuler

//     while (!quit_flag) {
//         c = wgetch(menu_win);
//         switch (c) {
//             case KEY_UP:
//                 highlight = (highlight == 0) ? n_choices - 1 : highlight - 1;
//                 break;
//             case KEY_DOWN:
//                 highlight = (highlight == n_choices - 1) ? 0 : highlight + 1;
//                 break;
//             case ' ': // Barre d'espace pour cocher/décocher
//                 menu_items[highlight].selected = !menu_items[highlight].selected;
//                 break;
//             case 10: // Touche Entrée pour VALIDER
//                 quit_flag = 1; // Valider et sortir
//                 break;
//             case 'q':
//             case 'Q':
//                 quit_flag = 2; // Annuler et sortir
//                 break;
//         }
//         if (!quit_flag) {
//             print_menu(menu_win, menu_items, n_choices, highlight);
//         }
//     }

// end_loop:

//     endwin();

//     // Si on a utilisé un terminal spécial, on le ferme
//     if (main_screen != NULL) {
//         delscreen(main_screen);
//         if (tty_in) fclose(tty_in);
//         if (tty_out) fclose(tty_out);
//     }
    
//     // Si l'utilisateur a validé (et non annulé), on imprime la sélection
//     if (quit_flag == 1) {
//         // Imprimer les résultats sur stdout pour que le script bash puisse les lire
//         for (int i = 0; i < n_choices; ++i) {
//             if (menu_items[i].selected) {
//                 printf("%s\n", menu_items[i].name);
//             }
//         }
//     }

//     free(menu_items);
//     return 0;
// }

// void print_menu(WINDOW *menu_win, MenuItem items[], int count, int highlight) {
//     int x = 2, y = 2;
//     box(menu_win, 0, 0);
//     for (int i = 0; i < count; ++i) {
//         wattron(menu_win, COLOR_PAIR(3)); // Couleur par défaut
//         if (highlight == i) {
//             wattron(menu_win, COLOR_PAIR(1));
//         }

//         if(items[i].selected) {
//             wattron(menu_win, COLOR_PAIR(2));
//             mvwprintw(menu_win, y + i, x, "[x]");
//             wattroff(menu_win, COLOR_PAIR(2));
//              if (highlight == i) { // Réappliquer la surbrillance
//                  wattron(menu_win, COLOR_PAIR(1));
//              }
//             mvwprintw(menu_win, y + i, x + 4, "%s", items[i].name);
//         } else {
//             mvwprintw(menu_win, y + i, x, "[ ] %s", items[i].name);
//         }

//         if (highlight == i) {
//             wattroff(menu_win, COLOR_PAIR(1));
//         }
//     }
//     wrefresh(menu_win);
// }

#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// --- STRUCTURES DE DONNÉES ---

typedef enum {
    LEVEL_BASE,
    LEVEL_FULL,
    LEVEL_OPTIONAL,
    LEVEL_UNKNOWN
} PackageLevel;

typedef struct {
    char *description;
    PackageLevel level;
    int category_index; // Index de sa catégorie dans le tableau `categories`
    bool selected;
} PackageItem;

typedef struct {
    char *name;
    int *package_indices; // Tableau d'indices vers les paquets de cette catégorie
    int package_count;
} CategoryItem;

// --- DÉCLARATIONS DE FONCTIONS ---

void parse_input(PackageItem **packages, int *package_count, CategoryItem **categories, int *category_count);
void draw_ui(WINDOW *cat_win, WINDOW *pkg_win, WINDOW *help_win, CategoryItem *categories, int cat_count, PackageItem *packages, int active_pane, int cat_highlight, int pkg_highlight, int pkg_scroll_offset);
void free_memory(PackageItem *packages, int package_count, CategoryItem *categories, int category_count);

// --- CONSTANTES ---

#define PANE_CATEGORIES 0
#define PANE_PACKAGES   1
#define MAX_ITEMS 512       // Nombre max de paquets/catégories
#define MAX_LINE_LEN 256

int main(void) {
    // --- LECTURE ET PARSING DES DONNÉES DEPUIS STDIN ---
    PackageItem *all_packages = NULL;
    CategoryItem *all_categories = NULL;
    int package_count = 0;
    int category_count = 0;
    
    parse_input(&all_packages, &package_count, &all_categories, &category_count);

    // --- INITIALISATION NCURSES ---
    initscr();
    cbreak();
    noecho();
    curs_set(0);
    start_color();
    keypad(stdscr, TRUE);

    init_pair(1, COLOR_CYAN, COLOR_BLACK);      // Titres de fenêtre
    init_pair(2, COLOR_WHITE, COLOR_BLUE);      // Ligne sélectionnée
    init_pair(3, COLOR_YELLOW, COLOR_BLACK);    // Pane actif
    init_pair(4, COLOR_GREEN, COLOR_BLACK);     // Paquet sélectionné [x]
    init_pair(5, COLOR_BLUE, COLOR_BLACK);      // Paquet de base [✓] (non modifiable)
    init_pair(6, COLOR_WHITE, COLOR_BLACK);     // Texte normal
    init_pair(7, COLOR_BLACK, COLOR_WHITE);     // Barre d'aide

    // --- MISE EN PAGE DE L'INTERFACE ---
    int screen_h, screen_w;
    getmaxyx(stdscr, screen_h, screen_w);

    int cat_win_w = screen_w / 4;
    int pkg_win_w = screen_w - cat_win_w;
    int win_h = screen_h - 3; // Laisse 1 ligne pour le titre, 2 pour l'aide

    mvprintw(0, (screen_w - 28) / 2, "Dotfiles - Package Selector");
    refresh();

    WINDOW *cat_win = newwin(win_h, cat_win_w, 1, 0);
    WINDOW *pkg_win = newwin(win_h, pkg_win_w, 1, cat_win_w);
    WINDOW *help_win = newwin(1, screen_w, screen_h - 1, 0);

    // --- VARIABLES D'ÉTAT DE L'UI ---
    int active_pane = PANE_CATEGORIES;
    int cat_highlight = 0;
    int pkg_highlight = 0;
    int pkg_scroll_offset = 0;
    int ch;

    // --- BOUCLE PRINCIPALE ---
    while ((ch = getch()) != 'q' && ch != 'Q') {
        CategoryItem *current_category = &all_categories[cat_highlight];
        int packages_in_cat = current_category->package_count;

        switch (ch) {
            case KEY_UP:
                if (active_pane == PANE_CATEGORIES) {
                    cat_highlight = (cat_highlight == 0) ? cat_count - 1 : cat_highlight - 1;
                    pkg_highlight = 0; // Reset sur changement de catégorie
                    pkg_scroll_offset = 0;
                } else if (packages_in_cat > 0) {
                    pkg_highlight--;
                    if (pkg_highlight < 0) pkg_highlight = packages_in_cat - 1;
                    // Gérer le scrolling
                    if (pkg_highlight < pkg_scroll_offset) {
                        pkg_scroll_offset = pkg_highlight;
                    }
                    if (pkg_highlight >= pkg_scroll_offset + (win_h - 2)) {
                        pkg_scroll_offset = pkg_highlight - (win_h - 2) + 1;
                    }
                }
                break;
            
            case KEY_DOWN:
                if (active_pane == PANE_CATEGORIES) {
                    cat_highlight = (cat_highlight == cat_count - 1) ? 0 : cat_highlight + 1;
                    pkg_highlight = 0; // Reset
                    pkg_scroll_offset = 0;
                } else if (packages_in_cat > 0) {
                    pkg_highlight++;
                    if (pkg_highlight >= packages_in_cat) pkg_highlight = 0;
                    // Gérer le scrolling
                    if (pkg_highlight >= pkg_scroll_offset + (win_h - 2)) {
                        pkg_scroll_offset++;
                    }
                     if (pkg_highlight < pkg_scroll_offset) {
                        pkg_scroll_offset = pkg_highlight;
                    }
                }
                break;

            case '\t': // Touche Tab pour changer de panneau
            case KEY_RIGHT:
            case KEY_LEFT:
                active_pane = (active_pane == PANE_CATEGORIES) ? PANE_PACKAGES : PANE_CATEGORIES;
                break;
            
            case ' ': // Barre espace
                if (active_pane == PANE_PACKAGES && packages_in_cat > 0) {
                    // Coche/décoche un paquet individuel
                    int pkg_idx = current_category->package_indices[pkg_highlight];
                    if (all_packages[pkg_idx].level != LEVEL_BASE) { // On ne peut pas décocher un paquet de base
                        all_packages[pkg_idx].selected = !all_packages[pkg_idx].selected;
                    }
                } else if (active_pane == PANE_CATEGORIES) {
                    // Coche/décoche tous les paquets (non-base) de la catégorie
                    bool all_selected = true;
                    for (int i = 0; i < packages_in_cat; i++) {
                        int pkg_idx = current_category->package_indices[i];
                        if (all_packages[pkg_idx].level != LEVEL_BASE && !all_packages[pkg_idx].selected) {
                            all_selected = false;
                            break;
                        }
                    }
                    for (int i = 0; i < packages_in_cat; i++) {
                        int pkg_idx = current_category->package_indices[i];
                        if (all_packages[pkg_idx].level != LEVEL_BASE) {
                             all_packages[pkg_idx].selected = !all_selected;
                        }
                    }
                }
                break;

            case 10: // Touche Entrée
                goto end_loop;
        }

        draw_ui(cat_win, pkg_win, help_win, all_categories, category_count, all_packages, active_pane, cat_highlight, pkg_highlight, pkg_scroll_offset);
    }

end_loop:
    endwin();

    // --- IMPRESSION DES RÉSULTATS ---
    if (ch == 10) { // Si on a quitté avec Entrée
        for (int i = 0; i < package_count; i++) {
            if (all_packages[i].selected) {
                printf("%s\n", all_packages[i].description);
            }
        }
    }
    
    // --- NETTOYAGE ---
    free_memory(all_packages, package_count, all_categories, category_count);
    return 0;
}


// --- DÉFINITIONS DE FONCTIONS ---

void draw_ui(WINDOW *cat_win, WINDOW *pkg_win, WINDOW *help_win, CategoryItem *categories, int cat_count, PackageItem *packages, int active_pane, int cat_highlight, int pkg_highlight, int pkg_scroll_offset) {
    werase(cat_win);
    werase(pkg_win);

    // Dessiner les boîtes et les titres
    wattron(cat_win, COLOR_PAIR(1) | A_BOLD);
    box(cat_win, 0, 0);
    mvwprintw(cat_win, 0, 2, " Categories ");
    wattroff(cat_win, COLOR_PAIR(1) | A_BOLD);
    
    wattron(pkg_win, COLOR_PAIR(1) | A_BOLD);
    box(pkg_win, 0, 0);
    mvwprintw(pkg_win, 0, 2, " Packages ");
    wattroff(pkg_win, COLOR_PAIR(1) | A_BOLD);

    // Mettre en évidence le panneau actif
    if (active_pane == PANE_CATEGORIES) {
        wattron(cat_win, COLOR_PAIR(3));
        box(cat_win, 0, 0); // Redessiner la boîte avec la couleur active
        mvwprintw(cat_win, 0, 2, " Categories ");
        wattroff(cat_win, COLOR_PAIR(3));
    } else {
        wattron(pkg_win, COLOR_PAIR(3));
        box(pkg_win, 0, 0);
        mvwprintw(pkg_win, 0, 2, " Packages ");
        wattroff(pkg_win, COLOR_PAIR(3));
    }

    // Dessiner la liste des catégories
    for (int i = 0; i < cat_count; i++) {
        if (i == cat_highlight) {
            wattron(cat_win, COLOR_PAIR(2));
        }
        mvwprintw(cat_win, i + 1, 2, "%s", categories[i].name);
        if (i == cat_highlight) {
            wattroff(cat_win, COLOR_PAIR(2));
        }
    }

    // Dessiner la liste des paquets pour la catégorie sélectionnée
    CategoryItem *current_cat = &categories[cat_highlight];
    int win_h, win_w;
    getmaxyx(pkg_win, win_h, win_w);
    int displayable_items = win_h - 2;

    for (int i = 0; i < displayable_items && (i + pkg_scroll_offset) < current_cat->package_count; i++) {
        int current_pkg_list_idx = i + pkg_scroll_offset;
        int pkg_idx = current_cat->package_indices[current_pkg_list_idx];
        PackageItem *pkg = &packages[pkg_idx];

        if (current_pkg_list_idx == pkg_highlight) {
            wattron(pkg_win, COLOR_PAIR(2));
        } else {
            wattron(pkg_win, COLOR_PAIR(6));
        }
        
        const char *prefix;
        int color_pair;

        if (pkg->level == LEVEL_BASE) {
            prefix = "[✓]";
            color_pair = 5;
        } else if (pkg->selected) {
            prefix = "[x]";
            color_pair = 4;
        } else {
            prefix = "[ ]";
            color_pair = 6;
        }

        mvwprintw(pkg_win, i + 1, 2, ""); // Positionner le curseur
        wattron(pkg_win, COLOR_PAIR(color_pair));
        wprintw(pkg_win, "%s", prefix);
        wattroff(pkg_win, COLOR_PAIR(color_pair));

        // Réappliquer la surbrillance pour le reste de la ligne
        if (current_pkg_list_idx == pkg_highlight) {
             wattron(pkg_win, COLOR_PAIR(2));
        } else {
             wattron(pkg_win, COLOR_PAIR(6));
        }
        wprintw(pkg_win, " %s", pkg->description);

        if (current_pkg_list_idx == pkg_highlight) {
            wattroff(pkg_win, COLOR_PAIR(2));
        }
    }

    // Dessiner la barre d'aide
    wbkgd(help_win, COLOR_PAIR(7));
    werase(help_win);
    mvwprintw(help_win, 0, 1, "↑/↓: Navigate | TAB: Switch Pane | SPACE: Toggle | ENTER: Confirm | Q: Quit");

    wrefresh(cat_win);
    wrefresh(pkg_win);
    wrefresh(help_win);
}

// Fonction pour trouver l'index d'une catégorie. Si elle n'existe pas, la crée.
int find_or_create_category(const char* name, CategoryItem **categories, int *count) {
    for (int i = 0; i < *count; i++) {
        if (strcmp((*categories)[i].name, name) == 0) {
            return i;
        }
    }
    
    // Pas trouvée, on la crée
    int new_index = *count;
    (*count)++;
    *categories = realloc(*categories, (*count) * sizeof(CategoryItem));
    
    (*categories)[new_index].name = strdup(name);
    (*categories)[new_index].package_indices = NULL;
    (*categories)[new_index].package_count = 0;
    
    return new_index;
}

void parse_input(PackageItem **packages, int *package_count, CategoryItem **categories, int *category_count) {
    char line[MAX_LINE_LEN];
    *packages = malloc(MAX_ITEMS * sizeof(PackageItem));
    *categories = malloc(MAX_ITEMS * sizeof(CategoryItem));

    while (fgets(line, sizeof(line), stdin)) {
        line[strcspn(line, "\n")] = 0; // Enlever le newline

        char *cat_name = strtok(line, ":");
        char *level_str = strtok(NULL, ":");
        char *desc = strtok(NULL, "");

        if (!cat_name || !level_str || !desc) continue;

        int pkg_idx = (*package_count)++;
        PackageItem *pkg = &(*packages)[pkg_idx];
        
        pkg->description = strdup(desc);
        
        // Parser le niveau
        if (strcmp(level_str, "base") == 0) {
            pkg->level = LEVEL_BASE;
            pkg->selected = true; // Les paquets de base sont sélectionnés par défaut
        } else if (strcmp(level_str, "full") == 0) {
            pkg->level = LEVEL_FULL;
            pkg->selected = false;
        } else if (strcmp(level_str, "optional") == 0) {
            pkg->level = LEVEL_OPTIONAL;
            pkg->selected = false;
        } else {
            pkg->level = LEVEL_UNKNOWN;
            pkg->selected = false;
        }

        // Gérer les catégories
        int cat_idx = find_or_create_category(cat_name, categories, category_count);
        pkg->category_index = cat_idx;

        CategoryItem *cat = &(*categories)[cat_idx];
        cat->package_count++;
        cat->package_indices = realloc(cat->package_indices, cat->package_count * sizeof(int));
        cat->package_indices[cat->package_count - 1] = pkg_idx;
    }
}

void free_memory(PackageItem *packages, int package_count, CategoryItem *categories, int category_count) {
    for (int i = 0; i < package_count; i++) {
        free(packages[i].description);
    }
    free(packages);

    for (int i = 0; i < category_count; i++) {
        free(categories[i].name);
        free(categories[i].package_indices);
    }
    free(categories);
}