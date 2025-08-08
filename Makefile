
SHELL := /bin/bash

CC = gcc

name = selector
SRC = select.c

CFLAGS = -Wall -Wextra -Werror -I./include
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
	sudo apt-get update -y && sudo apt-get install -y $(DEB_DEPS)

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