// #include "include/select.h"

// int main(void) {
//     setlocale(LC_ALL, "");

//     t_packageItem *all_packages = NULL;
//     t_categoryItem *all_categories = NULL;
//     int package_count = 0, category_count = 0;

//     parse_input(&all_packages, &package_count, &all_categories, &category_count);
    
//     SCREEN *main_screen = NULL;
//     FILE *tty_in = NULL, *tty_out = NULL;
//     if (!isatty(STDIN_FILENO))
// 	{
//         tty_in = fopen("/dev/tty", "r"); tty_out = fopen("/dev/tty", "w");
//         if (!tty_in || !tty_out)
// 			return 1;
//         main_screen = newterm(NULL, tty_out, tty_in);
//         set_term(main_screen);
//     } else 
// 		initscr();

//     cbreak(); noecho(); curs_set(0); start_color(); keypad(stdscr, TRUE);
//     init_pair(1, COLOR_WHITE, COLOR_BLUE); init_pair(2, COLOR_CYAN, COLOR_BLACK);
//     init_pair(3, COLOR_GREEN, COLOR_BLACK); init_pair(4, COLOR_CYAN, COLOR_BLACK);
//     init_pair(5, COLOR_WHITE, COLOR_BLACK); init_pair(6, COLOR_BLACK, COLOR_WHITE);
//     init_pair(7, COLOR_BLACK, COLOR_WHITE);
    
//     int screen_h, screen_w; getmaxyx(stdscr, screen_h, screen_w);
//     WINDOW *main_win = newwin(screen_h - 1, screen_w, 0, 0);
//     WINDOW *help_win = newwin(1, screen_w, screen_h - 1, 0);
//     keypad(main_win, TRUE);

//     int highlighted_cat = 0;
//     int ch = 0;

//     draw_ui(main_win, help_win, all_categories, category_count, all_packages, highlighted_cat);

//     while ((ch = wgetch(main_win)) != 'q' && ch != 'Q') {
//         switch (ch) {
//             case 'k':
// 			case KEY_UP: highlighted_cat=(highlighted_cat==0)?category_count-1:highlighted_cat-1;
// 				break;
//             case 'j':
// 			case KEY_DOWN: highlighted_cat=(highlighted_cat==category_count-1)?0:highlighted_cat+1;
// 				break;
//             case ' ': 
// 				{
// 					t_categoryItem*cat=&all_categories[highlighted_cat]; bool should_select_all=false;
// 					for(int i=0;i<cat->package_count;i++)
// 					{
// 						t_packageItem*pkg=&all_packages[cat->package_indices[i]];
// 						if(pkg->level!=LEVEL_BASE && !pkg->is_installed && !pkg->selected){should_select_all=true;break;}
// 					}
// 					for(int i=0;i<cat->package_count;i++)
// 					{
// 						t_packageItem*pkg=&all_packages[cat->package_indices[i]];
// 						if(pkg->level!=LEVEL_BASE && !pkg->is_installed) pkg->selected=should_select_all;
// 					}
// 				break;
// 				}
//             case 10:
// 				goto end_loop;
//         }
//         draw_ui(main_win, help_win, all_categories, category_count, all_packages, highlighted_cat);
//     }
// end_loop:
//     endwin();
//     if (main_screen) { delscreen(main_screen); if(tty_in) fclose(tty_in); if(tty_out) fclose(tty_out); }
//     if (ch == 10) {
//         for (int i = 0; i < package_count; i++) {
//             if (all_packages[i].selected && !all_packages[i].is_installed) {
//                 printf("%s\n", all_packages[i].description);
//             }
//         }
//     }
//     free_memory(all_packages, package_count, all_categories, category_count);
//     return 0;
// }

// void draw_ui(WINDOW *win, WINDOW *help_win, t_categoryItem *categories, int cat_count, t_packageItem *packages, int highlighted_cat_idx) {
//     werase(win);
// 	box(win, 0, 0);
//     int max_w, max_h;
// 	getmaxyx(win, max_h, max_w);
//     const int NUM_COLUMNS = 3;
// 	const int col_width = (max_w - 4) / NUM_COLUMNS;
// 	int current_y = 1;

//     for (int i = 0; i < cat_count; i++)
// 	{
//         if (current_y >= max_h - 1) break;
//         t_categoryItem *cat = &categories[i];
//         int header_pair = (i==highlighted_cat_idx) ? 1 : 2;
//         wattron(win,COLOR_PAIR(header_pair)|A_BOLD);
//         mvwhline(win, current_y, 1, ' ', max_w - 2);
//         mvwprintw(win, current_y, 3, "%s", cat->title);
//         wattroff(win, COLOR_PAIR(header_pair) | A_BOLD);
//         current_y++;

//         for (int j = 0; j < cat->package_count; j++) {
//             if (current_y >= max_h - 1) break;
//             int col=j%NUM_COLUMNS;
//             if (col == 0 && j > 0)
// 				if(++current_y >= max_h - 1)
// 					break;
//             t_packageItem *pkg = &packages[cat->package_indices[j]];
//             wchar_t display_str[256];
// 			const wchar_t *prefix;
// 			int color_pair;
// 			attr_t extra_attrs = A_NORMAL;

//             if (pkg->is_installed) {
//                 prefix = L"✓";
//                 color_pair = 7; // Paquet installé (gris)
//                 extra_attrs = A_DIM; // plus sombre
//             } else if (pkg->level == LEVEL_BASE) {
//                 prefix = L"✓";
//                 color_pair = 4; // Bloqué
//             } else if (pkg->selected) {
//                 prefix = L"✓";
//                 color_pair = 3; // Sélectionné
//             } else {
//                 prefix = L"✗";
//                 color_pair = 5; // Non sélectionné
//             }

//             wchar_t w_desc[256]; mbstowcs(w_desc, pkg->description, 256);
//             swprintf(display_str, sizeof(display_str)/sizeof(wchar_t), L"[%ls] %ls", prefix, w_desc);
            
//             wattron(win, COLOR_PAIR(color_pair) | extra_attrs);
//             if (i==highlighted_cat_idx) wattron(win, A_BOLD);
//             mvwaddwstr(win, current_y, 2+col*col_width, display_str);
//             wattroff(win, COLOR_PAIR(color_pair) | extra_attrs);
//             if (i==highlighted_cat_idx) wattroff(win, A_BOLD);
//         }
//         current_y += 2;
//     }
//     wrefresh(win);

//     wbkgd(help_win, COLOR_PAIR(6)); werase(help_win);
//     mvwprintw(help_win, 0, 1, "↑/k, ↓/j: Navigate | SPACE: Toggle Category | ENTER: Confirm | Q: Quit");
//     wrefresh(help_win);
// }

// void parse_input(t_packageItem **packages, int *pkg_count, t_categoryItem **cats, int *cat_count) {
//     char line[512];
//     while (fgets(line, sizeof(line), stdin))
// 	{
//         line[strcspn(line, "\n")] = 0;
//         char *name=strtok(line,":"), *title=strtok(NULL,":"), *level=strtok(NULL,":"), *desc=strtok(NULL,":"), *status=strtok(NULL,"");
//         if (!name || !title || !level || !desc || !status) continue;
        
//         (*pkg_count)++;
//         *packages = realloc(*packages, (*pkg_count) * sizeof(t_packageItem));
//         int pkg_idx = (*pkg_count) - 1;
//         (*packages)[pkg_idx] = (t_packageItem){.description=strdup(desc)};
//         t_packageItem *pkg = &(*packages)[pkg_idx];
        
//         pkg->is_installed = (strcmp(status, "installed") == 0);

//         if(strcmp(level,"base")==0)
// 		{
// 			pkg->level=LEVEL_BASE;
// 			pkg->selected=true;
// 		}
//         else{if(strcmp(level,"full")==0)pkg->level=LEVEL_FULL;else if(strcmp(level,"optional")==0)pkg->level=LEVEL_OPTIONAL;else pkg->level=LEVEL_UNKNOWN;pkg->selected=false;}
        
//         int cat_idx = find_or_create_category(name, title, cats, cat_count);
//         t_categoryItem *cat = &(*cats)[cat_idx];
//         cat->package_count++;
//         cat->package_indices = realloc(cat->package_indices, cat->package_count * sizeof(int));
//         cat->package_indices[cat->package_count - 1] = pkg_idx;
//     }
// }

// int find_or_create_category(const char* name, const char* title, t_categoryItem **categories, int *count)
// {
//     for (int i=0; i<*count; i++)
// 		if (strcmp((*categories)[i].name, name) == 0)
// 			return i;
//     int new_index = (*count)++;
//     *categories = realloc(*categories, (*count) * sizeof(t_categoryItem));
// 	if (!*categories) {
// 		perror("Failed to allocate memory for categories");
// 		// prevoir sortie propre avec free_memory
// 		exit(EXIT_FAILURE);
// 	}
//     (*categories)[new_index] = (t_categoryItem) { .name=strdup(name), .title=strdup(title), .package_indices=NULL, .package_count=0 };
//     return new_index;
// }

// void free_memory(t_packageItem *pkgs, int pkg_count, t_categoryItem *cats, int cat_count)
// {
//     if (pkgs)
// 	{ 
// 		for (int i=0; i<pkg_count; i++)
// 			free(pkgs[i].description);
// 		free(pkgs);
// 	}
//     if (cats)
// 	{
// 		for (int i=0; i<cat_count; i++)
// 		{
// 			free(cats[i].name);
// 			free(cats[i].title);
// 			free(cats[i].package_indices);
// 		}
// 		free(cats);
// 	}
// }

#include "include/select.h"
#include "include/select.h"
#include <stdio.h> // Pour fprintf et stderr

// --- Prototypes ---
void parse_input(t_ui_state *state);
void init_ncurses_and_windows(t_ui_state *state);
void main_loop(t_ui_state *state);
void draw_ui(t_ui_state *state);
void draw_profile_win(t_ui_state *state);
void draw_package_win(t_ui_state *state);
bool package_in_profile(const t_package *pkg, const t_profile *prof);
void free_all(t_ui_state *state);

int main(void) {
    setlocale(LC_ALL, "");
    t_ui_state state = {0};
    
    // ================== MODIFICATION CLÉ ==================
    // 1. Initialiser ncurses en se connectant au VRAI terminal AVANT TOUTE CHOSE.
    FILE *tty_fp = fopen("/dev/tty", "r+");
    if (!tty_fp) {
        // Si on ne peut pas ouvrir le terminal, il est inutile de continuer.
        // On écrit sur stderr car stdout est redirigé vers un fichier.
        fprintf(stderr, "Fatal Error: Could not open /dev/tty. Cannot start TUI.\n");
        return 1;
    }
    SCREEN *main_screen = newterm(NULL, tty_fp, tty_fp);
    set_term(main_screen);

    // 2. Maintenant que ncurses contrôle le terminal, on peut lire les données
    // depuis l'entrée standard (le pipe) sans risque de conflit.
    parse_input(&state);
    
    // Vérification : si aucune donnée n'a été lue, on quitte proprement.
    if (state.profile_count == 0 || state.package_count == 0) {
        fprintf(stderr, "Error: No profile or package data received on stdin. Exiting.\n");
        // Nettoyage avant de quitter
        endwin();
        delscreen(main_screen);
        fclose(tty_fp);
        free_all(&state);
        return 1;
    }
    
    // 3. Lancer l'interface graphique textuelle
    init_ncurses_and_windows(&state);
    main_loop(&state);

    // 4. Nettoyage final
    endwin();
    delscreen(main_screen);
    fclose(tty_fp);

    // 5. Afficher le nom du profil sélectionné sur stdout (qui sera capturé par le script shell)
    if (state.highlighted_profile != -1) {
        printf("%s\n", state.profiles[state.highlighted_profile].name);
    }

    free_all(&state);
    return 0;
}


// =====================================================================
// ===                  FONCTIONS INCHANGÉES                       ===
// =====================================================================

void parse_input(t_ui_state *state) {
    char line[1024];
    bool reading_packages = false;

    while (fgets(line, sizeof(line), stdin) != NULL) {
        line[strcspn(line, "\n")] = 0;

        if (!reading_packages) {
            if (strcmp(line, "---PACKAGES---") == 0) {
                reading_packages = true;
                continue;
            }
            
            char *name = strtok(line, ":");
            char *desc = strtok(NULL, ":");
            char *tags = strtok(NULL, "");

            if (name && desc && tags) {
                state->profiles = realloc(state->profiles, (state->profile_count + 1) * sizeof(t_profile));
                state->profiles[state->profile_count++] = (t_profile){strdup(name), strdup(desc), strdup(tags)};
            }
        } else {
            char *desc = strtok(line, ":");
            char *tags = strtok(NULL, ":");
            char *status = strtok(NULL, "");

            if (desc && tags && status) {
                state->packages = realloc(state->packages, (state->package_count + 1) * sizeof(t_package));
                state->packages[state->package_count++] = (t_package){
                    .description = strdup(desc),
                    .tags_str = strdup(tags),
                    .is_installed = (strcmp(status, "installed") == 0)
                };
            }
        }
    }
}

void init_ncurses_and_windows(t_ui_state *state) {
    cbreak(); noecho(); curs_set(0); keypad(stdscr, TRUE); start_color();
    // Couleurs: 1=Selectionné (inversé), 2=Installé (vert), 3=Normal (blanc sur noir)
    init_pair(1, COLOR_BLACK, COLOR_WHITE); 
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    // init_pair(2, COLOR_GREEN, -1);
    init_pair(3, COLOR_WHITE, COLOR_BLACK);
    // init_pair(3, COLOR_WHITE, -1);
    
    int max_y, max_x; getmaxyx(stdscr, max_y, max_x);
    int profile_win_width = 30;
    
    state->profile_win = newwin(max_y, profile_win_width, 0, 0);
    state->package_win = newwin(max_y, max_x - profile_win_width, 0, profile_win_width);
    state->highlighted_profile = 0;
}

void main_loop(t_ui_state *state) {
    int ch; 
    draw_ui(state);
    while ((ch = getch()) != 'q' && ch != 'Q' && ch != 10) {
        switch (ch) {
            case KEY_UP: 
                state->highlighted_profile = (state->highlighted_profile == 0) ? state->profile_count - 1 : state->highlighted_profile - 1; 
                break;
            case KEY_DOWN: 
                state->highlighted_profile = (state->highlighted_profile + 1) % state->profile_count; 
                break;
        }
        draw_ui(state);
    }
    // Si l'utilisateur quitte avec 'q', on ne sélectionne rien.
    if (ch == 'q' || ch == 'Q') {
        state->highlighted_profile = -1;
    }
}

void draw_ui(t_ui_state *state) {
    clear();
    draw_profile_win(state); 
    draw_package_win(state);
    wrefresh(state->profile_win); 
    wrefresh(state->package_win);
    doupdate();
}

void draw_profile_win(t_ui_state *state) {
    werase(state->profile_win); 
    box(state->profile_win, 0, 0);
    mvwprintw(state->profile_win, 1, 2, "Installation Profiles");
    mvwhline(state->profile_win, 2, 1, ACS_HLINE, getmaxx(state->profile_win) - 2);
    
    for (int i = 0; i < state->profile_count; i++) {
        if (i == state->highlighted_profile) wattron(state->profile_win, COLOR_PAIR(1));
        mvwprintw(state->profile_win, 4 + i, 2, "%s", state->profiles[i].name);
        if (i == state->highlighted_profile) wattroff(state->profile_win, COLOR_PAIR(1));
    }
}

void draw_package_win(t_ui_state *state) {
    werase(state->package_win); 
    box(state->package_win, 0, 0);
    
    t_profile *current_profile = &state->profiles[state->highlighted_profile];
    wattron(state->package_win, A_BOLD);
    mvwprintw(state->package_win, 1, 2, "Profile: %s", current_profile->name);
    wattroff(state->package_win, A_BOLD);
    mvwprintw(state->package_win, 2, 2, "%s", current_profile->description);
    mvwhline(state->package_win, 3, 1, ACS_HLINE, getmaxx(state->package_win) - 2);
    
    int max_y, max_x; getmaxyx(state->package_win, max_y, max_x);
    int col_width = 28; 
    int num_cols = (max_x > 2) ? (max_x - 4) / col_width : 0;
    if (num_cols == 0) return;
    
    int y = 5, x = 2;
    for (int i = 0; i < state->package_count; i++) {
        t_package *pkg = &state->packages[i];
        
        if (package_in_profile(pkg, current_profile)) {
            if (pkg->is_installed) {
                wattron(state->package_win, COLOR_PAIR(2)); // Vert pour déjà installé
                mvwprintw(state->package_win, y, x, "✓ %-*s", col_width - 3, pkg->description);
                wattroff(state->package_win, COLOR_PAIR(2));
            } else {
                wattron(state->package_win, COLOR_PAIR(3) | A_BOLD); // Blanc gras pour à installer
                mvwprintw(state->package_win, y, x, "□ %-*s", col_width - 3, pkg->description);
                wattroff(state->package_win, COLOR_PAIR(3) | A_BOLD);
            }
            
            x += col_width;
            if (x + col_width > max_x) {
                x = 2;
                y++;
                if (y >= max_y - 1) break;
            }
        }
    }
}

bool package_in_profile(const t_package *pkg, const t_profile *prof) {
    if (strcmp(prof->name, "CUSTOM") == 0) return false;

    char *pkg_tags_copy = strdup(pkg->tags_str);
    char *prof_tags_copy = strdup(prof->tags_str);
    if (!pkg_tags_copy || !prof_tags_copy) { 
        free(pkg_tags_copy); free(prof_tags_copy); return false; 
    }

    char *pkg_tag_saveptr;
    char *pkg_tag = strtok_r(pkg_tags_copy, ",", &pkg_tag_saveptr);
    bool found = false;

    while (pkg_tag) {
        char *p_tags_temp = strdup(prof_tags_copy);
        if (!p_tags_temp) break;

        char *prof_tag_saveptr;
        char *prof_tag = strtok_r(p_tags_temp, ",", &prof_tag_saveptr);
        while (prof_tag) {
            if (strcmp(pkg_tag, prof_tag) == 0) { 
                found = true; 
                break; 
            }
            prof_tag = strtok_r(NULL, ",", &prof_tag_saveptr);
        }
        free(p_tags_temp);
        if (found) break;
        pkg_tag = strtok_r(NULL, ",", &pkg_tag_saveptr);
    }
    
    free(pkg_tags_copy); 
    free(prof_tags_copy);
    return found;
}

void free_all(t_ui_state *state) {
    for (int i = 0; i < state->profile_count; i++) {
        free(state->profiles[i].name); 
        free(state->profiles[i].description); 
        free(state->profiles[i].tags_str);
    }
    free(state->profiles);

    for (int i = 0; i < state->package_count; i++) {
        free(state->packages[i].description); 
        free(state->packages[i].tags_str);
    }
    free(state->packages);
}