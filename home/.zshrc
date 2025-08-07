# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH=~/.oh-my-zsh
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
#  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

if [ -f "$HOME/.zsh/myconfig.zsh" ]; then
    source "$HOME/.zsh/myconfig.zsh"
fi

if [ -f "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh" ]; then
    source "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh"
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
