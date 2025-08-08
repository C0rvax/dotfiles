
CC = gcc

name = selector
SRC = select.c

CFLAGS = -Wall -Wextra -Werror
LDFLAGS = -lncursesw

DEB_DEPS = gcc libncurses-dev
ARCH_DEPS = gcc ncurses
FEDORA_DEPS = gcc ncurses-devel

DOTFILES_SCRIPT = ./dotf.sh

all: name

name: install_deps $(SRC)
	@echo "Compiling TUI selector..."
	@$(CC) $(CFLAGS) $(SRC) -o $(name) $(LDFLAGS)
	@echo "✅ TUI selector compiled successfully."

install_deps:
	@# Vérification de la présence de sudo
	@if ! command -v sudo &> /dev/null; then \
		echo "❌ sudo command not found. Please install it to continue."; \
		exit 1; \
	fi
	@# Détection de la distribution et installation des paquets
	@if [ -f /etc/os-release ]; then \
		. /etc/os-release; \
		if [[ "$$ID" == "ubuntu" || "$$ID" == "debian" ]]; then \
			if ! dpkg -s $(DEB_DEPS) >/dev/null 2>&1; then \
				echo "Dependencies missing. Installing for Debian/Ubuntu..."; \
				sudo apt-get update -y && sudo apt-get install -y $(DEB_DEPS); \
			fi; \
		elif [[ "$$ID" == "arch" ]]; then \
			if ! pacman -Q $(ARCH_DEPS) >/dev/null 2>&1; then \
				echo "Dependencies missing. Installing for Arch Linux..."; \
				sudo pacman -S --noconfirm $(ARCH_DEPS); \
			fi; \
		elif [[ "$$ID" == "fedora" ]]; then \
			if ! dnf list installed $(FEDORA_DEPS) >/dev/null 2>&1; then \
				echo "Dependencies missing. Installing for Fedora..."; \
				sudo dnf install -y $(FEDORA_DEPS); \
			fi; \
		else \
			echo "⚠️ Unsupported distribution for automatic dependency installation. Please install 'gcc' and 'ncurses' manually."; \
		fi \
	else \
		echo "❌ Cannot detect Linux distribution from /etc/os-release."; \
		exit 1; \
	fi


clean:
	@echo "Cleaning compiled files..."
	@rm -f $(name)
	@echo "✅ Clean done."


pclean: clean
	@echo "Cleaning project log file..."
	@rm -f $(HOME)/.dotfiles_install.log
	@echo "✅ Project clean done."

re: clean all

help:
	@$(DOTFILES_SCRIPT) --help

dry_run:
	@echo "Running in dry-run mode..."
	@$(DOTFILES_SCRIPT) --d

tui:
	@$(DOTFILES_SCRIPT) -s tui

.PHONY: all clean pclean re help install_deps