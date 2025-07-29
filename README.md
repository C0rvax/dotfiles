# Mes Scripts de Post-Installation Linux

Ce dépôt contient mon ensemble de scripts Bash personnels, conçus pour automatiser et standardiser la configuration d'un nouvel environnement de développement sur une machine Linux fraîchement installée. L'objectif est simple : passer d'un système d'exploitation de base à un environnement de travail complet et personnalisé en une seule commande.

<p align="center">
<img src="https://raw.githubusercontent.com/C0rvax/dotfiles/main/screenshot.png" alt="Aperçu du script en action"/>
</p>

*(capture sous le nom `screenshot.png`!)*

---

## 🚀 Fonctionnalités Principales

-   **Détection Automatique** : Identifie la distribution (Debian/Ubuntu, Arch, Fedora...) et l'environnement de bureau (KDE, GNOME, XFCE...) pour appliquer les configurations adéquates.
-   **Installation Modulaire** : Propose une installation "Légère" pour les besoins essentiels ou "Complète" pour un environnement de développement complet.
-   **Configuration d'Outils** : Installe et configure automatiquement des outils clés comme `git`, `neovim` (avec ma configuration personnelle), `docker`, `zsh` (avec Oh My Zsh et Powerlevel10k).
-   **Personnalisation de l'Interface** : Applique automatiquement les thèmes, polices (MesloLGS NF), et icônes (Buuf Nestort) pour une expérience visuelle cohérente.
-   **Automatisation Complète** : De la mise à jour des paquets à la création de clés SSH, le script gère tout le processus pour minimiser les interventions manuelles.

---

## ⚙️ Comment l'utiliser

⚠️ **Attention** : Ce script exécute des commandes avec `sudo` et modifie des fichiers de configuration système. Il est conçu pour **mes besoins personnels**. Je vous recommande fortement de **lire le code** pour comprendre ce qu'il fait avant de l'exécuter sur votre machine. N'exécutez jamais un script depuis internet sans le comprendre.

### Prérequis

-   Une installation fraîche d'une distribution Linux compatible.
-   `git` doit être installé pour cloner le dépôt : `sudo apt install git` / `sudo pacman -S git`.

### Étapes d'installation

1.  **Clonez ce dépôt** sur votre machine :
    ```bash
    git clone https://github.com/C0rvax/dotfiles.git
    ```

2.  **Naviguez dans le dossier** du projet :
    ```bash
    cd dotfiles
    ```

3.  **Rendez le script principal exécutable** :
    ```bash
    chmod +x postInstall.sh
    ```

4.  **Exécutez le script** (sans `sudo` !) :
    ```bash
    ./postInstall.sh
    ```

Le script vous demandera votre mot de passe lorsque des privilèges `sudo` seront nécessaires. Suivez ensuite les instructions affichées dans le terminal.

---

## 📂 Structure du Dépôt

Le projet est divisé en trois fichiers pour une meilleure organisation :

-   `postInstall.sh` : Le script principal, qui sert de point d'entrée. Il gère la logique d'interaction avec l'utilisateur et appelle les fonctions nécessaires.
-   `postList` : Contient les listes de paquets à installer pour les différentes configurations (complète, légère, embarqué, optionnelle).
-   `postFunctions.sh` : Le cœur du projet. Il contient toutes les fonctions pour la détection du système, l'installation des paquets, et la configuration des applications et de l'environnement de bureau.

---

## 🛠️ Personnalisation

Ce script est un excellent point de départ si vous souhaitez créer votre propre système d'automatisation. N'hésitez pas à **forker** ce dépôt et à modifier :
-   Les listes de paquets dans `postList` pour correspondre à vos outils préférés.
-   Les fonctions de configuration dans `postFunctions.sh` pour utiliser vos propres thèmes, alias, ou configurations (par exemple, en clonant votre propre dépôt de configuration `nvim`).

---

## 📜 Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour plus de détails.
