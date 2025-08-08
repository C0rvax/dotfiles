#include "include/select.h"
#include <stdio.h>
#include <string.h>

int main(void) {
    setlocale(LC_ALL, "");
    t_ui_state state = {0};
    
    FILE *tty_fp = fopen("/dev/tty", "r+");
    if (!tty_fp) {
        fprintf(stderr, "Fatal Error: Could not open /dev/tty.\n");
        return 1;
    }
    SCREEN *main_screen = newterm(NULL, tty_fp, tty_fp);
    set_term(main_screen);

    parse_input(&state);
    
    if (state.profile_count == 0 || state.package_count == 0) {
        fprintf(stderr, "Error: No profile or package data received.\n");
        endwin();
        delscreen(main_screen);
        fclose(tty_fp);
        free_all(&state);
        return 1;
    }
    
    init_ncurses_and_windows(&state);
    main_loop(&state);

    endwin();
    delscreen(main_screen);
    fclose(tty_fp);

    if (state.highlighted_profile != -1) {
        printf("%s\n", state.profiles[state.highlighted_profile].name);
    }

    free_all(&state);
    return 0;
}

void parse_input(t_ui_state *state) {
    char line[1024];
    bool reading_packages = false;

    while (fgets(line, sizeof(line), stdin) != NULL) {
        line[strcspn(line, "\n")] = 0; // Enlève le saut de ligne

        if (strcmp(line, "---PACKAGES---") == 0) {
            reading_packages = true;
            continue;
        }

        if (!reading_packages) { // Parsing des profils: "NAME:DESC:TAGS"
            char *name, *desc, *tags;
            char *first_colon, *second_colon;

            first_colon = strchr(line, ':');
            if (!first_colon) continue; // Ligne malformée
            *first_colon = '\0';
            name = line;

            second_colon = strchr(first_colon + 1, ':');
            if (!second_colon) continue; // Ligne malformée
            *second_colon = '\0';
            desc = first_colon + 1;

            tags = second_colon + 1; // Le reste est la liste des tags

            state->profiles = realloc(state->profiles, (state->profile_count + 1) * sizeof(t_profile));
            state->profiles[state->profile_count++] = (t_profile){strdup(name), strdup(desc), strdup(tags)};

        } else { // Parsing des paquets: "DESC:TAGS:STATUS"
            char *desc, *tags, *status;
            char *first_colon, *second_colon;

            first_colon = strchr(line, ':');
            if (!first_colon) continue; // Ligne malformée
            *first_colon = '\0';
            desc = line;

            second_colon = strchr(first_colon + 1, ':');
            if (!second_colon) continue; // Ligne malformée
            *second_colon = '\0';
            tags = first_colon + 1;
            
            status = second_colon + 1;

            state->packages = realloc(state->packages, (state->package_count + 1) * sizeof(t_package));
            state->packages[state->package_count++] = (t_package){
                .description = strdup(desc),
                .tags_str = strdup(tags),
                .is_installed = (strcmp(status, "installed") == 0)
            };
        }
    }
}

void init_ncurses_and_windows(t_ui_state *state) {
    cbreak(); noecho(); curs_set(0); start_color();

    init_pair(1, COLOR_BLACK, COLOR_WHITE);
    init_pair(2, COLOR_YELLOW, COLOR_BLACK);
    init_pair(3, COLOR_WHITE, COLOR_GREEN);
    
    int max_y, max_x; getmaxyx(stdscr, max_y, max_x);
    int profile_win_width = 30;
    
    state->profile_win = newwin(max_y, profile_win_width, 0, 0);
    state->package_win = newwin(max_y, max_x - profile_win_width, 0, profile_win_width);
    state->highlighted_profile = 0;
    
    // On active les touches spéciales (flèches) pour la fenêtre des profils
    keypad(state->profile_win, TRUE);
}

void main_loop(t_ui_state *state) {
    int ch; 
    draw_ui(state);
    
    while ((ch = wgetch(state->profile_win)) != 'q' && ch != 'Q' && ch != 10) {
        switch (ch) {
            case 'k':
            case KEY_UP: 
                state->highlighted_profile = (state->highlighted_profile == 0) ? state->profile_count - 1 : state->highlighted_profile - 1; 
                break;
            case 'j':
            case KEY_DOWN: 
                state->highlighted_profile = (state->highlighted_profile + 1) % state->profile_count; 
                break;
        }
        draw_ui(state);
    }
    if (ch == 'q' || ch == 'Q') {
        state->highlighted_profile = -1;
    }
}

void draw_ui(t_ui_state *state) {
    clear(); // Efface l'écran physique
    
    draw_profile_win(state); 
    draw_package_win(state);
    
    // Rafraîchit les buffers des fenêtres SANS toucher à l'écran
    wnoutrefresh(state->profile_win); 
    wnoutrefresh(state->package_win);
    
    // Met à jour l'écran physique une seule fois avec tous les changements
    doupdate();
}

void draw_profile_win(t_ui_state *state) {
    werase(state->profile_win); 
    box(state->profile_win, 0, 0);
    wattron(state->profile_win, A_BOLD);
    mvwprintw(state->profile_win, 1, 2, "PROFILES");
    wattroff(state->profile_win, A_BOLD);
    mvwhline(state->profile_win, 2, 1, ACS_HLINE, getmaxx(state->profile_win) - 2);
    
    for (int i = 0; i < state->profile_count; i++) {
        if (i == state->highlighted_profile) {
            wattron(state->profile_win, COLOR_PAIR(1));
        }
        mvwprintw(state->profile_win, 4 + i, 2, " %-*s ", getmaxx(state->profile_win) - 4, state->profiles[i].name);
        if (i == state->highlighted_profile) {
            wattroff(state->profile_win, COLOR_PAIR(1));
        }
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
    int num_cols = (max_x > 4) ? (max_x - 4) / col_width : 1;
    
    int y = 5, col = 0;
    for (int i = 0; i < state->package_count; i++) {
        t_package *pkg = &state->packages[i];
        
        if (package_in_profile(pkg, current_profile)) {
            int current_x = 2 + col * col_width;
            
            if (pkg->is_installed) {
                wattron(state->package_win, COLOR_PAIR(2));
                mvwprintw(state->package_win, y, current_x, "✓ %s", pkg->description);
                wattroff(state->package_win, COLOR_PAIR(2));
            } else {
                wattron(state->package_win, COLOR_PAIR(3) | A_BOLD);
                mvwprintw(state->package_win, y, current_x, "□ %s", pkg->description);
                wattroff(state->package_win, COLOR_PAIR(3) | A_BOLD);
            }
            
            col++;
            if (col >= num_cols) {
                col = 0;
                y++;
                if (y >= max_y - 1) break;
            }
        }
    }
}


// Utilisation de strtok_r qui est plus sûr, mais le bug était ailleurs
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
    if (state->profiles) {
        for (int i = 0; i < state->profile_count; i++) {
            free(state->profiles[i].name); 
            free(state->profiles[i].description); 
            free(state->profiles[i].tags_str);
        }
        free(state->profiles);
    }
    if (state->packages) {
        for (int i = 0; i < state->package_count; i++) {
            free(state->packages[i].description); 
            free(state->packages[i].tags_str);
        }
        free(state->packages);
    }
}