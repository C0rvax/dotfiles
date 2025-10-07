# Activate alias completion
setopt completealiases

# File explo
alias gt42='~/Code/42/'
alias gtdot='~/dotfiles/'
alias gtcv='~/Documents/CV/'
alias gte='~/Code/Embedded/'
alias gtdoc='~/Documents/'
alias 42i='~/Code/42/inception/'
alias 42tr='~/Code/42/transcendence/'
alias 42e='~/Code/42/42_embedded/'
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
alias logan="~/AppImage/Logic-2.4.36-linux-x64.AppImage --no-sandbox"
alias nvi="~/AppImage/nvim.appimage"
alias nvio="~/AppImage/nvim.appimage -O"
alias proc="ps -Af"
alias glog="git log --graph --oneline --decorate"
alias chgedit="git config core.editor ~/AppImage/nvim.appimage"
alias duwd="du --max-depth=1 -h ."

# Update
alias agu="sudo apt-get update"
alias nagu="sudo nala update"
alias agg="sudo apt-get upgrade"
alias nagg="sudo nala upgrade"
alias agd="sudo apt-get dist-upgrade"
alias nagd="sudo nala dist-upgrade"
alias maj="agu && agg && agd"
alias nmaj="nagu && nagg && nagd"

# Remember
