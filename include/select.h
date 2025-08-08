#ifndef SELECT_H
# define SELECT_H

#define _XOPEN_SOURCE_EXTENDED 1
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <locale.h>
#include <wchar.h> 

typedef enum e_packageLevel
{
	LEVEL_BASE,
	LEVEL_FULL,
	LEVEL_OPTIONAL,
	LEVEL_UNKNOWN
}	t_packageLevel;

typedef struct s_packageItem
{
	char			*description;
	t_packageLevel	level;
	bool			selected;
	bool			is_installed;
}	t_packageItem;

typedef struct s_categoryItem
{
	char			*name;
	char			*title;
	int				*package_indices;
	int				package_count;
}	t_categoryItem;

// Structure pour un profil (pour l'affichage à gauche)
typedef struct {
    char *name;
    char *description;
    char *tags_str; // "base,gui,office"
} t_profile;

// Structure pour un paquet (pour l'affichage à droite)
typedef struct {
    char *description;
    char *tags_str;
    bool is_installed;
} t_package;

// Structure principale pour gérer l'état de l'UI
typedef struct {
    WINDOW *profile_win;
    WINDOW *package_win;
    t_profile *profiles;
    t_package *packages;
    int profile_count;
    int package_count;
    int highlighted_profile;
} t_ui_state;

// void	draw_ui(WINDOW *win, WINDOW *help_win, t_categoryItem *cats, int cat_count, t_packageItem *pkgs, int highlighted_cat_idx);
// int		find_or_create_category(const char* name, const char* title, t_categoryItem **categories, int *count);
// void	parse_input(t_packageItem **packages, int *pkg_count, t_categoryItem **cats, int *cat_count);
// void	free_memory(t_packageItem *pkgs, int pkg_count, t_categoryItem *cats, int cat_count);


void parse_input(t_ui_state *state);
void init_ui(t_ui_state *state);
void main_loop(t_ui_state *state);
void draw_ui(t_ui_state *state);
void draw_profile_win(t_ui_state *state);
void draw_package_win(t_ui_state *state);
bool package_in_profile(const t_package *pkg, const t_profile *prof);
void free_all(t_ui_state *state);

#endif /* __SELECT_H__ */
