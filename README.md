# Linux Dotfiles - Automated System Provisioning

![Language](https://img.shields.io/badge/Language-Bash-informational) ![Automation](https://img.shields.io/badge/Automation-Scripts-orange) ![OS](https://img.shields.io/badge/OS-Linux-critical) ![Tool](https://img.shields.io/badge/Interface-TUI-green)

This repository hosts my personal framework of Bash scripts, designed to automate and standardize the configuration of a new development environment on a freshly installed Linux machine. The main goal is to transform a base operating system into a complete, personalized, and reproducible work environment with just a few commands.

<p align="center">
<img src="https://raw.githubusercontent.com/C0rvax/dotfiles/main/dotfiles.png" alt="Preview of the script in action"/>
</p>

---

## ✨ Key Features

The project is built upon a series of principles to ensure flexibility, ease of use, and robustness.

### 1. Modular Architecture
The script is organized into logical modules (UI, package management, specific installers, desktop configurations, etc.). This structure makes it easy to maintain, add new features, and allow for user customization.

### 2. Centralized Configuration
All packages to be installed, resource URLs, themes, and system settings are defined in dedicated configuration files (`config/*.conf`). This allows the script's behavior to be modified without touching the main code.

### 3. Two Installation Selection Modes
*   **Simple Interactive Mode**: A step-by-step guide offers a choice between a `Base` installation (system essentials) or a `Full` installation (with common graphical applications).
*   **TUI (Text-based User Interface)**: A user interface based on ncurses (compiled on the fly) allows for the precise selection of software *categories* to install, offering granular control.

### 4. Robust Pre-installation Audit
Before making any changes, the script analyzes your system to detect the Linux distribution (Debian/Ubuntu, Arch, Fedora, etc.) and the desktop environment (KDE, GNOME, XFCE, etc.). It then generates a detailed report on what is already installed or missing, allowing you to make informed decisions.

### 5. Integrated Git Submodules Management
The project properly integrates external dependencies such as `Oh My Zsh`, `Powerlevel10k`, and various `zsh` plugins via Git submodules, ensuring clean and versioned installations.

### 6. Advanced Automation
The script transparently handles:
*   Requesting and maintaining `sudo` privileges.
*   Creating SSH keys.
*   Configuring `git` (name, email).
*   Installing specific fonts (e.g., MesloLGS NF).
*   Applying themes and icons (e.g., Buuf Nestort).

### 7. Detailed Logging
Every action performed by the script (success, failure, information) is logged in a log file (`~/.dotfiles_install.log`), which greatly facilitates diagnostics and debugging in case of a problem.

---

## 🚀 Quick Start

⚠️ **Warning**: This script executes commands with `sudo` and modifies system and user configuration files. It is designed for **my personal needs**. I strongly recommend that you **read the code** to understand what it does before running it on your machine. Never run a script from the internet without understanding it.

### Prerequisites

*   A recent installation of a compatible Linux distribution.
*   `git`, `gcc`, and `libncurses-dev` (or equivalent) must be installed to clone the repository and compile the TUI selector.
    *   On Debian/Ubuntu:
        ```bash
        sudo apt update && sudo apt install git gcc libncurses-dev
        ```    *   On Arch Linux:
        ```bash
        sudo pacman -S git gcc ncurses
        ```
    *   On Fedora:
        ```bash
        sudo dnf install git gcc ncurses-devel
        ```

### Installation Steps

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/C0rvax/dotfiles.git
    ```

2.  **Navigate to the Project Directory**
    ```bash
    cd dotfiles
    ```

3.  **Initialize Git Submodules**
    This step is **crucial** as it downloads dependencies like Oh My Zsh and Powerlevel10k.
    ```bash
    git submodule update --init --recursive
    ```

4.  **Make the Main Script Executable**
    ```bash
    chmod +x dotf.sh
    ```

5.  **Run the Script**
    Launch the script (without `sudo`!) using one of the options below.

---

## 🛠️ Usage and Options

### Common Examples

```bash
# Run the script in standard interactive mode (recommended for the first time)
./dotf.sh

# Launch the TUI for fine-grained selection by category
./dotf.sh --select tui

# Simulate a full installation without modifying anything, displaying all steps
./dotf.sh --dry-run --verbose

# Run a fully automated base installation (for a provisioning script)
./dotf.sh --yes
```

### Help and Detailed Options

You can get the full list of options at any time by running: `./dotf.sh --help`.

| Option | Description |
| :--- | :--- |
| `-v, --verbose` | Enables verbose output. |
| `-d, --dry-run` | Simulates the installation without making any actual changes. |
| `-y, --yes` | Automatically answers 'yes' to all prompts (non-interactive mode). |
| `-h, --help` | Displays this help message. |
| `-s, --select` | Selects the installation mode (`interactive` or `tui`). |

---

## 📁 Repository Structure

```
dotfiles/
│
├── config/
│   ├── packages.conf       # Defines all packages, their categories, and installation commands.
│   └── settings.conf       # Global variables: URLs, themes, paths, etc.
│
├── home/
│   ├── .zshrc              # Main Zsh configuration file.
│   ├── .config/nvim/       # Neovim configuration.
│   └── ...                 # All "dotfiles" intended to be linked into your /home.
│
├── lib/
│   ├── desktop_configs/    # Scripts for each desktop environment (KDE, GNOME...).
│   ├── installers/         # Modules for complex installations (Docker, Node.js...).
│   ├── install_select.sh   # Installation selection functions (interactive or TUI).
│   ├── audit.sh            # System audit and report functions.
│   ├── package_manager.sh  # Package manager abstraction (apt, pacman...).
│   ├── system.sh           # System detection, logging, utility functions.
│   └── ui.sh               # Functions for UI display (tables, colors...).
│
├── vendor/
│   └── oh-my-zsh/          # "Vendor" submodule for the Oh My Zsh framework.
│
├── .gitmodules             # Declares Git submodules (oh-my-zsh, p10k, zsh plugins...).
├── dotf.sh                 # Main entry point that orchestrates the entire script.
└── selector.c              # C source code for the TUI selection interface.
```

---

## 💻 Technologies Used

*   **Language:** Bash
*   **Compilation (TUI):** GCC
*   **Interface (TUI):** Ncurses
*   **Version Control:** Git (with submodules)
*   **Environment:** Linux

---

## 👤 Author

*   **A. Duvillaret** ([C0rvax](https://github.com/C0rvax))
