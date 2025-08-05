# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(
  git
  zsh-syntax-highlighting
  #fast-syntax-highlighting
  zsh-autosuggestions
#  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [ -f "$HOME/.zsh/myconfig.zsh" ]; then
    source "$HOME/.zsh/myconfig.zsh"
fi

if [ -f "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh" ]; then
    source "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh"
fi
