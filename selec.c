// #define _XOPEN_SOURCE_EXTENDED 1

// #include <ncurses.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>
// #include <stdbool.h>
// #include <locale.h>
// #include <wchar.h> 

// typedef enum { LEVEL_BASE, LEVEL_FULL, LEVEL_OPTIONAL, LEVEL_UNKNOWN } PackageLevel;
// typedef struct { char *description; PackageLevel level; bool selected; } PackageItem;
// typedef struct { char *name; int *package_indices; int package_count; } CategoryItem;

// void parse_input(PackageItem **packages, int *package_count, CategoryItem **categories, int *category_count);
// void draw_ui(WINDOW *win, WINDOW *help_win, CategoryItem *categories, int cat_count, PackageItem *packages, int highlighted_cat_idx);
// void free_memory(PackageItem *packages, int package_count, CategoryItem *categories, int category_count);

// int main(void) {
//     setlocale(LC_ALL, "");

//     PackageItem *all_packages = NULL;
//     CategoryItem *all_categories = NULL;
//     int package_count = 0, category_count = 0;

//     parse_input(&all_packages, &package_count, &all_categories, &category_count);
    
//     SCREEN *main_screen = NULL;
//     FILE *tty_in = NULL, *tty_out = NULL;
//     if (!isatty(STDIN_FILENO)) {
//         tty_in = fopen("/dev/tty", "r"); tty_out = fopen("/dev/tty", "w");
//         if (!tty_in || !tty_out) { return 1; }
//         main_screen = newterm(NULL, tty_out, tty_in);
//         set_term(main_screen);
//     } else {
//         initscr();
//     }

//     cbreak(); noecho(); curs_set(0); start_color(); keypad(stdscr, TRUE);

//     init_pair(1, COLOR_WHITE, COLOR_BLUE);      
//     init_pair(2, COLOR_CYAN, COLOR_BLACK);      
//     init_pair(3, COLOR_GREEN, COLOR_BLACK);     
//     init_pair(4, COLOR_CYAN, COLOR_BLACK);
//     init_pair(5, COLOR_WHITE, COLOR_BLACK);     
//     init_pair(6, COLOR_BLACK, COLOR_WHITE);     

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
//             case KEY_UP:
//                 highlighted_cat = (highlighted_cat == 0) ? category_count - 1 : highlighted_cat - 1;
//                 break;
//             case 'j':
//             case KEY_DOWN:
//                 highlighted_cat = (highlighted_cat == category_count - 1) ? 0 : highlighted_cat + 1;
//                 break;
//             case ' ': {
//                 CategoryItem *cat = &all_categories[highlighted_cat];
//                 bool should_select_all = false;
//                 for (int i = 0; i < cat->package_count; i++) {
//                     PackageItem *pkg = &all_packages[cat->package_indices[i]];
//                     if (pkg->level != LEVEL_BASE && !pkg->selected) {
//                         should_select_all = true;
//                         break;
//                     }
//                 }
//                 for (int i = 0; i < cat->package_count; i++) {
//                     PackageItem *pkg = &all_packages[cat->package_indices[i]];
//                     if (pkg->level != LEVEL_BASE) {
//                         pkg->selected = should_select_all;
//                     }
//                 }
//                 break;
//             }
//             case 10: // Entrée
//                 goto end_loop;
//         }
//         draw_ui(main_win, help_win, all_categories, category_count, all_packages, highlighted_cat);
//     }
// end_loop:
//     endwin();
//     if (main_screen) { delscreen(main_screen); if(tty_in) fclose(tty_in); if(tty_out) fclose(tty_out); }
    
//     if (ch == 10) {
//         for (int i = 0; i < package_count; i++) {
//             if (all_packages[i].selected) printf("%s\n", all_packages[i].description);
//         }
//     }
//     free_memory(all_packages, package_count, all_categories, category_count);
//     return 0;
// }


// void draw_ui(WINDOW *win, WINDOW *help_win, CategoryItem *categories, int cat_count, PackageItem *packages, int highlighted_cat_idx) {
//     werase(win);
//     box(win, 0, 0);

//     int max_w, max_h;
//     getmaxyx(win, max_h, max_w);
    
//     const int NUM_COLUMNS = 3;
//     const int col_width = (max_w - 4) / NUM_COLUMNS;
//     int current_y = 1;

//     for (int i = 0; i < cat_count; i++) {
//         if (current_y >= max_h - 1) break;
        
//         CategoryItem *cat = &categories[i];
        
//         int header_pair = (i == highlighted_cat_idx) ? 1 : 2;
//         wattron(win, COLOR_PAIR(header_pair) | A_BOLD);
//         mvwhline(win, current_y, 1, ' ', max_w - 2);
//         mvwprintw(win, current_y, 3, "%s", cat->name);
//         wattroff(win, COLOR_PAIR(header_pair) | A_BOLD);
//         current_y++;

//         for (int j = 0; j < cat->package_count; j++) {
//             if (current_y >= max_h - 1) break;

//             int col = j % NUM_COLUMNS;
//             int current_x = 2 + col * col_width;
            
//             if (col == 0 && j > 0) {
//                 current_y++;
//                  if (current_y >= max_h - 1) break;
//             }
            
//             PackageItem *pkg = &packages[cat->package_indices[j]];
//             wchar_t display_str[256];
//             const wchar_t *prefix;
//             int color_pair;

//             if (pkg->level == LEVEL_BASE) {
//                 prefix = L"✓";
//                 color_pair = 4; // Bleu
//             } else if (pkg->selected) {
//                 prefix = L"✓";
//                 color_pair = 3; // Vert
//             } else {
//                 prefix = L"✗";
//                 color_pair = 5; // Gris/Blanc
//             }
//             wchar_t w_desc[256];
//             mbstowcs(w_desc, pkg->description, 256);

//             swprintf(display_str, sizeof(display_str)/sizeof(wchar_t), L"[%ls] %s", prefix, pkg->description);

//             wattron(win, COLOR_PAIR(color_pair));
//             if (i == highlighted_cat_idx) wattron(win, A_BOLD);
            
//             mvwaddwstr(win, current_y, current_x, display_str);

//             wattroff(win, COLOR_PAIR(color_pair));
//             if (i == highlighted_cat_idx) wattroff(win, A_BOLD);
//         }
//         current_y += 2;
//     }

//     wrefresh(win);

//     wbkgd(help_win, COLOR_PAIR(6));
//     werase(help_win);
//     mvwprintw(help_win, 0, 1, "↑/k, ↓/j: Navigate | SPACE: Toggle Category | ENTER: Confirm | Q: Quit");
//     wrefresh(help_win);
// }

// void free_memory(PackageItem *packages, int package_count, CategoryItem *categories, int category_count) {
//     if (packages) { for (int i = 0; i < package_count; i++) free(packages[i].description); free(packages); }
//     if (categories) { for (int i = 0; i < category_count; i++) { free(categories[i].name); free(categories[i].package_indices); } free(categories); }
// }

// int find_or_create_category(const char* name, CategoryItem **categories, int *count) {
//     for (int i = 0; i < *count; i++) if (strcmp((*categories)[i].name, name) == 0) return i;
//     int new_index = (*count)++;
//     *categories = realloc(*categories, (*count) * sizeof(CategoryItem));
//     (*categories)[new_index] = (CategoryItem){ .name = strdup(name), .package_indices = NULL, .package_count = 0 };
//     return new_index;
// }

// void parse_input(PackageItem **packages, int *package_count, CategoryItem **categories, int *category_count) {
//     char line[256];
//     while (fgets(line, sizeof(line), stdin)) {
//         line[strcspn(line, "\n")] = 0;
//         char *cat_name = strtok(line, ":"), *level_str = strtok(NULL, ":"), *desc = strtok(NULL, "");
//         if (!cat_name || !level_str || !desc) continue;
//         (*package_count)++;
//         *packages = realloc(*packages, (*package_count) * sizeof(PackageItem));
//         int pkg_idx = (*package_count) - 1;
//         (*packages)[pkg_idx] = (PackageItem){.description = strdup(desc)};
//         PackageItem *pkg = &(*packages)[pkg_idx];
//         if (strcmp(level_str, "base") == 0) { pkg->level = LEVEL_BASE; pkg->selected = true; }
//         else if (strcmp(level_str, "full") == 0) { pkg->level = LEVEL_FULL; pkg->selected = false; }
//         else if (strcmp(level_str, "optional") == 0) { pkg->level = LEVEL_OPTIONAL; pkg->selected = false; }
//         else { pkg->level = LEVEL_UNKNOWN; pkg->selected = false; }
//         int cat_idx = find_or_create_category(cat_name, categories, category_count);
//         CategoryItem *cat = &(*categories)[cat_idx];
//         cat->package_count++;
//         cat->package_indices = realloc(cat->package_indices, cat->package_count * sizeof(int));
//         cat->package_indices[cat->package_count - 1] = pkg_idx;
//     }
// }

#define _XOPEN_SOURCE_EXTENDED 1
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <locale.h>
#include <wchar.h> 

// --- STRUCTURES DE DONNÉES MODIFIÉES ---
typedef enum { LEVEL_BASE, LEVEL_FULL, LEVEL_OPTIONAL, LEVEL_UNKNOWN } PackageLevel;
typedef struct { char *description; PackageLevel level; bool selected; } PackageItem;
typedef struct { char *name; char *title; int *package_indices; int package_count; } CategoryItem; // Ajout de 'title'

// --- DÉCLARATIONS DE FONCTIONS MISES À JOUR ---
void parse_input(char ***logo, int *logo_h, PackageItem **packages, int *pkg_count, CategoryItem **cats, int *cat_count);
void draw_ui(WINDOW *win, WINDOW *help_win, char **logo, int logo_h, CategoryItem *cats, int cat_count, PackageItem *pkgs, int highlighted_cat_idx);
void free_memory(char **logo, int logo_h, PackageItem *pkgs, int pkg_count, CategoryItem *cats, int cat_count);
int find_or_create_category(const char* name, const char* title, CategoryItem **categories, int *count);


int main(void) {
    setlocale(LC_ALL, "");

    // Variables pour stocker les données parsées
    char **logo_lines = NULL;
    PackageItem *all_packages = NULL;
    CategoryItem *all_categories = NULL;
    int logo_height = 0, package_count = 0, category_count = 0;

    parse_input(&logo_lines, &logo_height, &all_packages, &package_count, &all_categories, &category_count);
    
    SCREEN *main_screen = NULL;
    FILE *tty_in = NULL, *tty_out = NULL;
    if (!isatty(STDIN_FILENO)) {
        tty_in = fopen("/dev/tty", "r"); tty_out = fopen("/dev/tty", "w");
        if (!tty_in || !tty_out) { return 1; }
        main_screen = newterm(NULL, tty_out, tty_in);
        set_term(main_screen);
    } else { initscr(); }

    cbreak(); noecho(); curs_set(0); start_color(); keypad(stdscr, TRUE);
    init_pair(1, COLOR_WHITE, COLOR_BLUE); init_pair(2, COLOR_CYAN, COLOR_BLACK);
    init_pair(3, COLOR_GREEN, COLOR_BLACK); init_pair(4, COLOR_CYAN, COLOR_BLACK);
    init_pair(5, COLOR_WHITE, COLOR_BLACK); init_pair(6, COLOR_BLACK, COLOR_WHITE);
    init_pair(7, COLOR_YELLOW, COLOR_BLACK); // Couleur pour le logo

    int screen_h, screen_w; getmaxyx(stdscr, screen_h, screen_w);
    WINDOW *main_win = newwin(screen_h - 1, screen_w, 0, 0);
    WINDOW *help_win = newwin(1, screen_w, screen_h - 1, 0);
    keypad(main_win, TRUE);

    int highlighted_cat = 0;
    int ch = 0;

    draw_ui(main_win, help_win, logo_lines, logo_height, all_categories, category_count, all_packages, highlighted_cat);

    while ((ch = wgetch(main_win)) != 'q' && ch != 'Q') {
        // La boucle de contrôle reste identique
        switch (ch) {
            case 'k': case KEY_UP: highlighted_cat=(highlighted_cat==0)?category_count-1:highlighted_cat-1; break;
            case 'j': case KEY_DOWN: highlighted_cat=(highlighted_cat==category_count-1)?0:highlighted_cat+1; break;
            case ' ': {
                CategoryItem*cat=&all_categories[highlighted_cat]; bool should_select_all=false;
                for(int i=0;i<cat->package_count;i++){ PackageItem*pkg=&all_packages[cat->package_indices[i]]; if(pkg->level!=LEVEL_BASE&&!pkg->selected){should_select_all=true;break;}}
                for(int i=0;i<cat->package_count;i++){ PackageItem*pkg=&all_packages[cat->package_indices[i]]; if(pkg->level!=LEVEL_BASE)pkg->selected=should_select_all;}
                break;
            }
            case 10: goto end_loop;
        }
        draw_ui(main_win, help_win, logo_lines, logo_height, all_categories, category_count, all_packages, highlighted_cat);
    }
end_loop:
    endwin();
    if (main_screen) { delscreen(main_screen); if(tty_in) fclose(tty_in); if(tty_out) fclose(tty_out); }
    if (ch == 10) for (int i = 0; i < package_count; i++) if (all_packages[i].selected) printf("%s\n", all_packages[i].description);
    
    free_memory(logo_lines, logo_height, all_packages, package_count, all_categories, category_count);
    return 0;
}


void draw_ui(WINDOW *win, WINDOW *help_win, char **logo, int logo_h, CategoryItem *categories, int cat_count, PackageItem *packages, int highlighted_cat_idx) {
    werase(win); box(win, 0, 0);
    int max_w, max_h; getmaxyx(win, max_h, max_w);
    
    // --- DESSIN DU LOGO ---
    int current_y = 1;
    if (logo && logo_h > 0) {
        wattron(win, COLOR_PAIR(7) | A_BOLD);
        int max_logo_w = 0;
        for (int i=0; i<logo_h; i++) { int len = strlen(logo[i]); if (len > max_logo_w) max_logo_w = len; }
        int logo_x_start = (max_w - max_logo_w) / 2;

        for (int i=0; i<logo_h; i++) {
            if (current_y >= max_h -1) break;
            mvwprintw(win, current_y++, logo_x_start, "%s", logo[i]);
        }
        wattroff(win, COLOR_PAIR(7) | A_BOLD);
        current_y++; // Espace après le logo
    }

    // --- DESSIN DES CATÉGORIES ET PAQUETS ---
    const int NUM_COLUMNS = 3;
    const int col_width = (max_w - 4) / NUM_COLUMNS;

    for (int i = 0; i < cat_count; i++) {
        if (current_y >= max_h - 1) break;
        CategoryItem *cat = &categories[i];
        int header_pair = (i == highlighted_cat_idx) ? 1 : 2;
        wattron(win, COLOR_PAIR(header_pair) | A_BOLD);
        mvwhline(win, current_y, 1, ' ', max_w - 2);
        mvwprintw(win, current_y, 3, "%s", cat->title); // Utilisation de cat->title
        wattroff(win, COLOR_PAIR(header_pair) | A_BOLD);
        current_y++;

        for (int j = 0; j < cat->package_count; j++) {
            if (current_y >= max_h - 1) break;
            int col = j % NUM_COLUMNS;
            if (col == 0 && j > 0) if (++current_y >= max_h - 1) break;
            
            PackageItem *pkg = &packages[cat->package_indices[j]];
            wchar_t display_str[256]; const wchar_t *prefix; int color_pair;
            if (pkg->level==LEVEL_BASE){prefix=L"✓";color_pair=4;}else if(pkg->selected){prefix=L"✓";color_pair=3;}else{prefix=L"✗";color_pair=5;}
            wchar_t w_desc[256]; mbstowcs(w_desc, pkg->description, 256);
            swprintf(display_str, sizeof(display_str)/sizeof(wchar_t), L"[%ls] %ls", prefix, w_desc);
            
            wattron(win, COLOR_PAIR(color_pair)); if (i == highlighted_cat_idx) wattron(win, A_BOLD);
            mvwaddwstr(win, current_y, 2 + col * col_width, display_str);
            wattroff(win, COLOR_PAIR(color_pair)); if (i == highlighted_cat_idx) wattroff(win, A_BOLD);
        }
        current_y += 2;
    }
    wrefresh(win);

    wbkgd(help_win, COLOR_PAIR(6)); werase(help_win);
    mvwprintw(help_win, 0, 1, "↑/k, ↓/j: Navigate | SPACE: Toggle Category | ENTER: Confirm | Q: Quit");
    wrefresh(help_win);
}


void parse_input(char ***logo, int *logo_h, PackageItem **packages, int *pkg_count, CategoryItem **cats, int *cat_count) {
    char line[512];
    bool data_started = false;

    while (fgets(line, sizeof(line), stdin)) {
        if (!data_started) {
            if (strncmp(line, "---DATA---", 10) == 0) {
                data_started = true;
                continue;
            }
            (*logo_h)++;
            *logo = realloc(*logo, (*logo_h) * sizeof(char*));
            (*logo)[*logo_h - 1] = strdup(line);
        } else {
            line[strcspn(line, "\n")] = 0;
            char *name=strtok(line,":"), *title=strtok(NULL,":"), *level=strtok(NULL,":"), *desc=strtok(NULL,"");
            if (!name || !title || !level || !desc) continue;
            
            (*pkg_count)++;
            *packages = realloc(*packages, (*pkg_count) * sizeof(PackageItem));
            int pkg_idx = (*pkg_count) - 1;
            (*packages)[pkg_idx] = (PackageItem){.description=strdup(desc)};
            PackageItem *pkg = &(*packages)[pkg_idx];
            if(strcmp(level,"base")==0){pkg->level=LEVEL_BASE;pkg->selected=true;}else if(strcmp(level,"full")==0){pkg->level=LEVEL_FULL;pkg->selected=false;}else if(strcmp(level,"optional")==0){pkg->level=LEVEL_OPTIONAL;pkg->selected=false;}else{pkg->level=LEVEL_UNKNOWN;pkg->selected=false;}
            
            int cat_idx = find_or_create_category(name, title, cats, cat_count);
            CategoryItem *cat = &(*cats)[cat_idx];
            cat->package_count++;
            cat->package_indices = realloc(cat->package_indices, cat->package_count * sizeof(int));
            cat->package_indices[cat->package_count - 1] = pkg_idx;
        }
    }
}

int find_or_create_category(const char* name, const char* title, CategoryItem **categories, int *count) {
    for (int i=0; i<*count; i++) if (strcmp((*categories)[i].name, name) == 0) return i;
    int new_index = (*count)++;
    *categories = realloc(*categories, (*count) * sizeof(CategoryItem));
    (*categories)[new_index] = (CategoryItem){ .name=strdup(name), .title=strdup(title), .package_indices=NULL, .package_count=0 };
    return new_index;
}

void free_memory(char **logo, int logo_h, PackageItem *pkgs, int pkg_count, CategoryItem *cats, int cat_count) {
    if (logo) { for(int i=0; i<logo_h; i++) free(logo[i]); free(logo); }
    if (pkgs) { for (int i = 0; i < pkg_count; i++) free(pkgs[i].description); free(pkgs); }
    if (cats) { for (int i = 0; i < cat_count; i++) { free(cats[i].name); free(cats[i].title); free(cats[i].package_indices); } free(cats); }
}