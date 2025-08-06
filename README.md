# Mes Scripts de Post-Installation Linux

Ce dépôt contient mon framework personnel de scripts Bash, conçu pour automatiser et standardiser la configuration d'un nouvel environnement de développement sur une machine Linux fraîchement installée. L'objectif est simple : passer d'un système d'exploitation de base à un environnement de travail complet, personnalisé et reproductible en quelques commandes.

<p align="center">
<img src="https://raw.githubusercontent.com/C0rvax/dotfiles/main/screenshot.png" alt="Aperçu du script en action"/>
</p>

*(Ajoute `screenshot.png`)*

---

## 🚀 Fonctionnalités Principales

-   **Architecture Modulaire** : Le projet est organisé en modules logiques (UI, gestion des paquets, installeurs spécifiques, configurations de bureau), ce qui rend la maintenance et la personnalisation très simples.
-   **Configuration Centralisée** : Tous les paquets, URLs, thèmes et paramètres sont définis dans des fichiers dédiés (`config/*.conf`), permettant de modifier le comportement du script sans toucher au code principal.
-   **Deux Modes de Sélection** :
    1.  **Interactif simple** : Un guide pas-à-pas pour choisir une installation `Base` (essentiels) ou `Complète` (avec les applications graphiques).
    2.  **Interface TUI (Text-based User Interface)** : Une interface en ncurses (compilée à la volée) pour sélectionner précisément les *catégories* de logiciels à installer.
-   **Audit Pré-installation** : Avant toute action, le script analyse votre système, détecte la distribution (Debian/Ubuntu, Arch, etc.) et l'environnement de bureau (KDE, GNOME, etc.), et vous présente un rapport sur ce qui est déjà installé ou manquant.
-   **Gestion des Sous-modules Git** : Intègre proprement des dépendances externes comme `Oh My Zsh`, `Powerlevel10k` et des plugins `zsh`, garantissant des installations propres et versionnées.
-   **Automatisation Poussée** : Gère la demande de privilèges `sudo` de manière transparente (keep-alive), la création de clés SSH, la configuration de `git`, l'installation de polices (MesloLGS NF), thèmes et icônes (Buuf Nestort).
-   **Journalisation Détaillée** : Chaque action, succès ou échec, est consignée dans un fichier log (`~/.dotfiles_install.log`) pour un diagnostic facile en cas de problème.

---

## ⚙️ Comment l'utiliser

⚠️ **Attention** : Ce script exécute des commandes avec `sudo` et modifie des fichiers de configuration système et utilisateur. Il est conçu pour **mes besoins personnels**. Je vous recommande fortement de **lire le code** pour comprendre ce qu'il fait avant de l'exécuter sur votre machine. N'exécutez jamais un script depuis internet sans le comprendre.

### Prérequis

-   Une installation fraîche d'une distribution Linux compatible.
-   `git`, `gcc`, et `libncurses-dev` (ou équivalent) doivent être installés pour cloner le dépôt et compiler le sélecteur TUI :
    -   Sur Debian/Ubuntu : `sudo apt update && sudo apt install git gcc libncurses-dev`
    -   Sur Arch Linux : `sudo pacman -S git gcc ncurses`
    -   Sur Fedora : `sudo dnf install git gcc ncurses-devel`

### Étapes d'installation

1.  **Clonez ce dépôt** sur votre machine :
    ```bash
    git clone https://github.com/C0rvax/dotfiles.git
    ```

2.  **Naviguez dans le dossier** du projet :
    ```bash
    cd dotfiles
    ```

3.  **Initialisez les sous-modules Git** : Cette étape est **cruciale**. Elle télécharge les dépendances comme Oh My Zsh et Powerlevel10k.
    ```bash
    git submodule update --init --recursive
    ```

4.  **Rendez le script principal exécutable** :
    ```bash
    chmod +x postInstall.sh
    ```

5.  **Exécutez le script** (sans `sudo` !) en utilisant l'une des options ci-dessous.

---

## 🛠️ Usage et Options

### Exemples courants

```bash
# Lancer le script en mode interactif standard (recommandé pour la première fois)
./postInstall.sh

# Lancer l'interface TUI pour une sélection fine par catégorie
./postInstall.sh --select tui

# Simuler une installation complète sans rien modifier, en affichant toutes les étapes
./postInstall.sh --dry-run --verbose

# Lancer une installation de base entièrement automatisée (pour un script de provisioning)
./postInstall.sh --yes
```

### Aide et détail des options

Vous pouvez obtenir la liste complète des options à tout moment en exécutant : `./postInstall.sh --help`.

```text
Usage: postInstall.sh [options]
Options:
  -v, --verbose       Enable verbose output
  -d, --dry-run       Simulate installation without making changes
  -y, --yes           Assume 'yes' answer to prompts
  -h, --help          Show this help message
  -s, --select        Select installation mode (interactive or tui)
```

---

## 📂 Structure du Dépôt

Le projet est organisé de manière logique pour séparer la configuration, le code et les ressources

```text
dotfiles/
│
├── config/
│   ├── packages.conf    # Définit tous les paquets, leurs catégories et commandes d'installation.
│   └── settings.conf    # Variables globales : URLs, thèmes, chemins, etc.
│
├── home/
│   ├── .zshrc           # Fichier de configuration Zsh principal.
│   ├── .config/nvim/    # Configuration Neovim.
│   └── ...              # Tous les "dotfiles" destinés à être liés dans votre /home.
│
├── lib/
│   ├── desktop_configs/ # Scripts pour chaque environnement de bureau (KDE, GNOME...).
│   ├── installers/      # Modules pour les installations complexes (Docker, Node.js...).
│   ├── audit.sh         # Fonctions d'audit et de rapport système.
│   ├── package_manager.sh # Abstraction du gestionnaire de paquets (apt, pacman...).
│   ├── system.sh        # Détection du système, logging, fonctions utilitaires.
│   └── ui.sh            # Fonctions pour l'affichage de l'interface (tableaux, couleurs...).
│
├── vendor/
│   └── oh-my-zsh/       # Sous-module "fournisseur" pour le framework Oh My Zsh.
│
├── .gitmodules          # Déclare les sous-modules Git (oh-my-zsh, p10k, plugins zsh...).
├── postInstall.sh       # Point d'entrée principal qui orchestre l'ensemble du script.
└── selector.c           # Code source en C pour l'interface de sélection TUI.
```
---

## Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour plus de détails.
