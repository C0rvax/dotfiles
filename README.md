Absolument ! Votre projet a énormément évolué. Il est passé d'un ensemble de quelques scripts à une véritable petite infrastructure modulaire et configurable. Le `README.md` actuel ne lui rend plus du tout justice.

Voici une proposition de `README.md` entièrement mise à jour qui reflète la nouvelle structure, les fonctionnalités avancées (comme le TUI en C), et qui intègre correctement la notion cruciale des sous-modules Git.

---

# Mes Scripts de Post-Installation Linux

Ce dépôt contient mon framework personnel de scripts Bash, conçu pour automatiser et standardiser la configuration d'un nouvel environnement de développement sur une machine Linux fraîchement installée. L'objectif est simple : passer d'un système d'exploitation de base à un environnement de travail complet, personnalisé et reproductible en quelques commandes.

<p align="center">
<img src="https://raw.githubusercontent.com/C0rvax/dotfiles/main/screenshot.png" alt="Aperçu du script en action"/>
</p>

*(N'oubliez pas de mettre à jour la capture d'écran `screenshot.png` pour refléter la nouvelle interface !)*

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
-   `git` et `gcc` doivent être installés pour cloner le dépôt et compiler le sélecteur TUI :
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

5.  **Exécutez le script** (sans `sudo` !) :
    ```bash
    ./postInstall.sh
    ```
    Pour une expérience plus ciblée, vous pouvez lancer directement l'interface TUI :
    ```bash
    ./postInstall.sh --select tui
    ```

Le script vous demandera votre mot de passe lorsque des privilèges `sudo` seront nécessaires. Suivez ensuite les instructions affichées dans le terminal.

---

## 📂 Structure du Dépôt

Le projet est organisé de manière logique pour séparer la configuration, le code et les ressources :

-   `postInstall.sh` : Le point d'entrée principal qui orchestre l'ensemble du processus.
-   `config/`:
    -   `settings.conf`: Contient les variables globales (URLs, noms de thèmes, chemins, etc.).
    -   `packages.conf`: Le cœur de la configuration. Définit toutes les applications, leurs descriptions, les commandes pour vérifier leur présence et les installer, ainsi que leur catégorie.
-   `lib/`:
    -   `system.sh`, `package_manager.sh`, `audit.sh`, `ui.sh`: Fonctions de base pour la gestion du système, des paquets, de l'audit et de l'interface utilisateur.
    -   `installers/`: Scripts modulaires pour chaque installation complexe (Docker, Node.js, Neovim, etc.).
    -   `desktop_configs/`: Scripts pour appliquer les configurations spécifiques à chaque environnement de bureau.
-   `home/`: Contient les véritables "dotfiles" (ex: `.zshrc`, `.config/nvim/`) qui seront liés symboliquement dans votre répertoire personnel. Les sous-modules y sont également nichés.
-   `vendor/`: Contient les sous-modules qui sont des dépendances "fournisseur", comme le framework `oh-my-zsh`.
-   `selector.c`: Le code source en C pour l'interface de sélection TUI.
-   `.gitmodules`: Fichier qui déclare les sous-modules Git utilisés dans le projet.

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

## 🛠️ Personnalisation

Ce framework est un excellent point de départ pour créer votre propre système d'automatisation. Pour l'adapter à vos besoins :

-   **Modifiez les paquets** : Ajoutez, modifiez ou supprimez des entrées dans `config/packages.conf` pour qu'il corresponde à votre pile logicielle.
-   **Ajustez les paramètres** : Changez les URLs, les noms de thèmes ou les chemins dans `config/settings.conf`.
-   **Ajoutez un installeur** : Créez un nouveau fichier `lib/installers/mon_app.sh` avec une fonction `install_mon_app` et ajoutez-le à `config/packages.conf`.
-   **Changez les dotfiles** : Modifiez les fichiers dans le dossier `home/` pour qu'ils correspondent à vos configurations personnelles.

---

## 📜 Options de Ligne de Commande

Le script supporte plusieurs options pour personnaliser son exécution :

-   `--help`: Affiche l'aide et les options disponibles.
-   `--dry-run`: Mode de simulation. Affiche tout ce qu'il *ferait* sans rien modifier. Idéal pour vérifier les actions avant de les lancer.
-   `--verbose`: Affiche des informations détaillées sur chaque étape.
-   `--yes`: Répond automatiquement "oui" à toutes les questions, pour une exécution non-interactive.
-   `--select <mode>`: Choisit le mode de sélection.
    -   `interactive` (défaut) : Questions simples "Base" ou "Complète".
    -   `tui` : Lance l'interface ncurses pour une sélection par catégorie.

## Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour plus de détails.