#include "include/select.h"

int main(void) {
    setlocale(LC_ALL, "");

    t_packageItem *all_packages = NULL;
    t_categoryItem *all_categories = NULL;
    int package_count = 0, category_count = 0;

    parse_input(&all_packages, &package_count, &all_categories, &category_count);
    
    SCREEN *main_screen = NULL;
    FILE *tty_in = NULL, *tty_out = NULL;
    if (!isatty(STDIN_FILENO))
	{
        tty_in = fopen("/dev/tty", "r"); tty_out = fopen("/dev/tty", "w");
        if (!tty_in || !tty_out)
			return 1;
        main_screen = newterm(NULL, tty_out, tty_in);
        set_term(main_screen);
    } else 
		initscr();

    cbreak(); noecho(); curs_set(0); start_color(); keypad(stdscr, TRUE);
    init_pair(1, COLOR_WHITE, COLOR_BLUE); init_pair(2, COLOR_CYAN, COLOR_BLACK);
    init_pair(3, COLOR_GREEN, COLOR_BLACK); init_pair(4, COLOR_CYAN, COLOR_BLACK);
    init_pair(5, COLOR_WHITE, COLOR_BLACK); init_pair(6, COLOR_BLACK, COLOR_WHITE);
    init_pair(7, COLOR_BLACK, COLOR_WHITE);
    
    int screen_h, screen_w; getmaxyx(stdscr, screen_h, screen_w);
    WINDOW *main_win = newwin(screen_h - 1, screen_w, 0, 0);
    WINDOW *help_win = newwin(1, screen_w, screen_h - 1, 0);
    keypad(main_win, TRUE);

    int highlighted_cat = 0;
    int ch = 0;

    draw_ui(main_win, help_win, all_categories, category_count, all_packages, highlighted_cat);

    while ((ch = wgetch(main_win)) != 'q' && ch != 'Q') {
        switch (ch) {
            case 'k':
			case KEY_UP: highlighted_cat=(highlighted_cat==0)?category_count-1:highlighted_cat-1;
				break;
            case 'j':
			case KEY_DOWN: highlighted_cat=(highlighted_cat==category_count-1)?0:highlighted_cat+1;
				break;
            case ' ': 
				{
					t_categoryItem*cat=&all_categories[highlighted_cat]; bool should_select_all=false;
					for(int i=0;i<cat->package_count;i++)
					{
						t_packageItem*pkg=&all_packages[cat->package_indices[i]];
						if(pkg->level!=LEVEL_BASE && !pkg->is_installed && !pkg->selected){should_select_all=true;break;}
					}
					for(int i=0;i<cat->package_count;i++)
					{
						t_packageItem*pkg=&all_packages[cat->package_indices[i]];
						if(pkg->level!=LEVEL_BASE && !pkg->is_installed) pkg->selected=should_select_all;
					}
				break;
				}
            case 10:
				goto end_loop;
        }
        draw_ui(main_win, help_win, all_categories, category_count, all_packages, highlighted_cat);
    }
end_loop:
    endwin();
    if (main_screen) { delscreen(main_screen); if(tty_in) fclose(tty_in); if(tty_out) fclose(tty_out); }
    if (ch == 10) {
        for (int i = 0; i < package_count; i++) {
            if (all_packages[i].selected && !all_packages[i].is_installed) {
                printf("%s\n", all_packages[i].description);
            }
        }
    }
    free_memory(all_packages, package_count, all_categories, category_count);
    return 0;
}

void draw_ui(WINDOW *win, WINDOW *help_win, t_categoryItem *categories, int cat_count, t_packageItem *packages, int highlighted_cat_idx) {
    werase(win);
	box(win, 0, 0);
    int max_w, max_h;
	getmaxyx(win, max_h, max_w);
    const int NUM_COLUMNS = 3;
	const int col_width = (max_w - 4) / NUM_COLUMNS;
	int current_y = 1;

    for (int i = 0; i < cat_count; i++)
	{
        if (current_y >= max_h - 1) break;
        t_categoryItem *cat = &categories[i];
        int header_pair = (i==highlighted_cat_idx) ? 1 : 2;
        wattron(win,COLOR_PAIR(header_pair)|A_BOLD);
        mvwhline(win, current_y, 1, ' ', max_w - 2);
        mvwprintw(win, current_y, 3, "%s", cat->title);
        wattroff(win, COLOR_PAIR(header_pair) | A_BOLD);
        current_y++;

        for (int j = 0; j < cat->package_count; j++) {
            if (current_y >= max_h - 1) break;
            int col=j%NUM_COLUMNS;
            if (col == 0 && j > 0)
				if(++current_y >= max_h - 1)
					break;
            t_packageItem *pkg = &packages[cat->package_indices[j]];
            wchar_t display_str[256];
			const wchar_t *prefix;
			int color_pair;
			attr_t extra_attrs = A_NORMAL;

            if (pkg->is_installed) {
                prefix = L"✓";
                color_pair = 7; // Paquet installé (gris)
                extra_attrs = A_DIM; // plus sombre
            } else if (pkg->level == LEVEL_BASE) {
                prefix = L"✓";
                color_pair = 4; // Bloqué
            } else if (pkg->selected) {
                prefix = L"✓";
                color_pair = 3; // Sélectionné
            } else {
                prefix = L"✗";
                color_pair = 5; // Non sélectionné
            }

            wchar_t w_desc[256]; mbstowcs(w_desc, pkg->description, 256);
            swprintf(display_str, sizeof(display_str)/sizeof(wchar_t), L"[%ls] %ls", prefix, w_desc);
            
            wattron(win, COLOR_PAIR(color_pair) | extra_attrs);
            if (i==highlighted_cat_idx) wattron(win, A_BOLD);
            mvwaddwstr(win, current_y, 2+col*col_width, display_str);
            wattroff(win, COLOR_PAIR(color_pair) | extra_attrs);
            if (i==highlighted_cat_idx) wattroff(win, A_BOLD);
        }
        current_y += 2;
    }
    wrefresh(win);

    wbkgd(help_win, COLOR_PAIR(6)); werase(help_win);
    mvwprintw(help_win, 0, 1, "↑/k, ↓/j: Navigate | SPACE: Toggle Category | ENTER: Confirm | Q: Quit");
    wrefresh(help_win);
}

void parse_input(t_packageItem **packages, int *pkg_count, t_categoryItem **cats, int *cat_count) {
    char line[512];
    while (fgets(line, sizeof(line), stdin))
	{
        line[strcspn(line, "\n")] = 0;
        char *name=strtok(line,":"), *title=strtok(NULL,":"), *level=strtok(NULL,":"), *desc=strtok(NULL,":"), *status=strtok(NULL,"");
        if (!name || !title || !level || !desc || !status) continue;
        
        (*pkg_count)++;
        *packages = realloc(*packages, (*pkg_count) * sizeof(t_packageItem));
        int pkg_idx = (*pkg_count) - 1;
        (*packages)[pkg_idx] = (t_packageItem){.description=strdup(desc)};
        t_packageItem *pkg = &(*packages)[pkg_idx];
        
        pkg->is_installed = (strcmp(status, "installed") == 0);

        if(strcmp(level,"base")==0)
		{
			pkg->level=LEVEL_BASE;
			pkg->selected=true;
		}
        else{if(strcmp(level,"full")==0)pkg->level=LEVEL_FULL;else if(strcmp(level,"optional")==0)pkg->level=LEVEL_OPTIONAL;else pkg->level=LEVEL_UNKNOWN;pkg->selected=false;}
        
        int cat_idx = find_or_create_category(name, title, cats, cat_count);
        t_categoryItem *cat = &(*cats)[cat_idx];
        cat->package_count++;
        cat->package_indices = realloc(cat->package_indices, cat->package_count * sizeof(int));
        cat->package_indices[cat->package_count - 1] = pkg_idx;
    }
}

int find_or_create_category(const char* name, const char* title, t_categoryItem **categories, int *count)
{
    for (int i=0; i<*count; i++)
		if (strcmp((*categories)[i].name, name) == 0)
			return i;
    int new_index = (*count)++;
    *categories = realloc(*categories, (*count) * sizeof(t_categoryItem));
	if (!*categories) {
		perror("Failed to allocate memory for categories");
		// prevoir sortie propre avec free_memory
		exit(EXIT_FAILURE);
	}
    (*categories)[new_index] = (t_categoryItem) { .name=strdup(name), .title=strdup(title), .package_indices=NULL, .package_count=0 };
    return new_index;
}

void free_memory(t_packageItem *pkgs, int pkg_count, t_categoryItem *cats, int cat_count)
{
    if (pkgs)
	{ 
		for (int i=0; i<pkg_count; i++)
			free(pkgs[i].description);
		free(pkgs);
	}
    if (cats)
	{
		for (int i=0; i<cat_count; i++)
		{
			free(cats[i].name);
			free(cats[i].title);
			free(cats[i].package_indices);
		}
		free(cats);
	}
}
