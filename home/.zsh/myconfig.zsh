# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
#  export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autosuggestions
#  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# export MANPATH="/usr/local/man:$MANPATH"
export USER='aduvilla'
export MAIL='aduvilla@sudent.42.fr'

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# File explo
alias 42er='~/Code/embeded/Rush00/'
alias 42e='~/Code/exam06/'
alias 42i='~/Code/TC/inception/'
alias 42tr='~/Code/TC/ft_transcendence/'
alias 42c='~/Code/embeded/Module09/ex03/'
alias 42v='~/Code/TC/vrac/'
alias 42t='~/Code/tests/'
alias 42s='~/Code/TC/scripts/'
alias sniprc="~/.config/nvim/snippets/snippets/"
alias nvirc="~/.config/nvim/"
alias doccv="~/Documents/CV/"
alias bat='batcat */*'
alias trea="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Compilation
alias vala='clear && valgrind --track-fds=yes --track-origins=yes --leak-check=full --show-leak-kinds=all --trace-children=yes --show-leak-kinds=all'
alias valm='clear && valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --tool=memcheck --keep-debuginfo=yes --trace-children=yes --suppressions=valgrind/valgrind.doc --quiet ./minishell'
alias flcc='clear && cc -Wall -Wextra -Werror'
alias flgcc='clear && gcc -Wall -Wextra -Werror'
alias cdbr="rm -rf compile_flags.txt compile_commands.json .cache/"
alias cdb="cdbr ; compiledb -n make && echo '-I\ninclude/' >> compile_flags.txt"
alias ircser="valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --track-fds=yes ./ircserv 6667 port"

# Edit rc
alias zshrc="nvi ~/.zsh/myconfig.zsh"
alias szsh='source ~/.zshrc'
alias vimrc="nvi ~/.config/nvim"
alias pince="sudo -E ~/AppImage/PINCE-x86_64.AppImage"

# Exec
alias ledger="~/ledger_live/ledger-live-desktop-*.AppImage"
alias nvi="~/AppImage/nvim.appimage"
alias nvio="~/AppImage/nvim.appimage -O"
alias proc="ps -Af"
alias glog="git log --graph --oneline --decorate"
alias chgedit="git config core.editor ~/AppImage/nvim.appimage"

# Update
alias savenvirc="mkdir ~/nvim_backup_stable_$(date +%Y%m%d) && cp -r ~/.config/nvim ~/nvim_backup_stable_$(date +%Y%m%d)/config && cp -r ~/.local/share/nvim/lazy ~/nvim_backup_stable_$(date +%Y%m%d)/lazy_plugins"
alias agu="sudo apt-get update"
alias nagu="sudo nala update"
alias agg="sudo apt-get upgrade"
alias nagg="sudo nala upgrade"
alias agd="sudo apt-get dist-upgrade"
alias nagd="sudo nala dist-upgrade"
alias maj="agu && agg && agd"
alias nmaj="nagu && nagg && nagd"

# Remember
alias catdirs='find app/services/shared -type f ! -name 'out.txt' | while read fichier; do
  echo "// $fichier\n" >> back.txt
  cat "$fichier" >> back.txt
  echo "" >> back.txt
done'
alias catdirf='find app/frontend \( -path "app/frontend/public/assets" -o -path "app/frontend/public/fonts" \) -prune -o -type f ! -name "out.txt" -print | while read fichier; do
  echo "// $fichier" >> front.txt
  cat "$fichier" >> front.txt
  echo "" >> front.txt
done'
alias savealiases='alias > ~/.bash_aliases'
alias rsydoc="rsync --progress -avz ~/Documents c0rvax@192.168.1.6:NetBackup"
alias rssydoc="rsync -e 'ssh -p 22' --progress -avz ~/Documents c0rvax@192.168.1.6:NetBackup"

# Fonction pour sauvegarder la configuration Neovim (LazyVim)
savimrc() {
  local backup_dir="$HOME/nvim_backup/$(date +%Y%m%d_%H%M%S)"
  if [ -d "$backup_dir" ]; then
    echo "Erreur : Le répertoire de sauvegarde '$backup_dir' existe déjà."
    return 1
  fi

  echo "Création de la sauvegarde dans : $backup_dir"
  mkdir -p "$backup_dir"

  echo "Copie de la configuration ~/.config/nvim ..."
  rsync -avh --progress ~/.config/nvim "$backup_dir/config"

  echo "Copie des plugins ~/.local/share/nvim/lazy ..."
  rsync -avh --progress ~/.local/share/nvim/lazy "$backup_dir/lazy_plugins"

  echo "Sauvegarde terminée avec succès !"
}

# Fonction pour restaurer la DERNIÈRE sauvegarde Neovim
restvimrc() {
  local backup_root="$HOME/nvim_backup"

  # 1. Trouver le répertoire de sauvegarde le plus récent
  echo "Recherche de la dernière sauvegarde dans $backup_root..."
  local latest_backup=$(ls -1 "$backup_root" | sort -r | head -n 1)

  if [ -z "$latest_backup" ]; then
    echo "Erreur : Aucun répertoire de sauvegarde trouvé dans $backup_root."
    echo "Veuillez d'abord créer une sauvegarde avec 'savimrc'."
    return 1
  fi

  local backup_to_restore="$backup_root/$latest_backup"
  echo "Dernière sauvegarde trouvée : $latest_backup"

  # 2. Demander une confirmation (sécurité)
  # -n 1: lit un seul caractère, -r: ne pas interpréter les backslashs
  read -p "Voulez-vous restaurer cette version ? Votre configuration actuelle sera déplacée. (y/N) " -n 1 -r
  echo # pour sauter une ligne après la réponse de l'utilisateur
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restauration annulée."
    return 0
  fi

  # 3. Sauvegarder la configuration ACTUELLE avant de l'écraser
  echo "Mise de côté de la configuration actuelle..."
  local current_config="$HOME/.config/nvim"
  local current_share="$HOME/.local/share/nvim"
  local timestamp=$(date +%Y%m%d_%H%M%S)

  if [ -d "$current_config" ]; then
    mv "$current_config" "${current_config}.before-restore-${timestamp}"
    echo " -> Configuration actuelle déplacée vers : ${current_config}.before-restore-${timestamp}"
  fi
  if [ -d "$current_share" ]; then
    mv "$current_share" "${current_share}.before-restore-${timestamp}"
    echo " -> Données actuelles déplacées vers : ${current_share}.before-restore-${timestamp}"
  fi

  # 4. Restaurer les fichiers depuis la sauvegarde
  echo "Restauration depuis '$latest_backup'..."

  # Restaurer la configuration (le dossier .config/nvim)
  echo "Restauration de la configuration..."
  rsync -avh --progress "$backup_to_restore/config/" "$current_config"

  # Restaurer les plugins (le dossier .local/share/nvim/lazy)
  echo "Restauration des plugins..."
  # On s'assure que le dossier parent existe avant la copie
  mkdir -p "$current_share"
  rsync -avh --progress "$backup_to_restore/lazy_plugins/" "$current_share/lazy"

  echo "" # Ligne vide pour la lisibilité
  echo "✅ Restauration terminée avec succès !"
  echo "Lancez 'nvim' pour vérifier."
  echo "Si tout est OK, vous pourrez supprimer les dossiers '.before-restore-${timestamp}'."
}
