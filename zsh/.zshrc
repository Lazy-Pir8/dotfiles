# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="alanpeabody"

plugins=( 
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# check the dnf plugins commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dnf


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
export PATH="$HOME/.local/bin:$PATH"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH="$HOME/.cargo/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/lazy_pirate/google-cloud-sdk/path.zsh.inc' ]; then . '/home/lazy_pirate/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/lazy_pirate/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/lazy_pirate/google-cloud-sdk/completion.zsh.inc'; fi
export PATH=/home/lazy_pirate/bin:/home/lazy_pirate/google-cloud-sdk/bin:/home/lazy_pirate/.cargo/bin:/home/lazy_pirate/.local/bin:/home/lazy_pirate/projects/appdev/flutter/bin:/home/lazy_pirate/projects/appdev/flutter/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/var/lib/snapd/snap/bin
export PATH=/home/lazy_pirate/bin:/home/lazy_pirate/bin:/home/lazy_pirate/google-cloud-sdk/bin:/home/lazy_pirate/.cargo/bin:/home/lazy_pirate/.local/bin:/home/lazy_pirate/projects/appdev/flutter/bin:/home/lazy_pirate/projects/appdev/flutter/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/var/lib/snapd/snap/bin
