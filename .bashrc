PS1='[\u@\h \W]\$'

# Alias
alias ls='ls --color=auto -al'

export GPG_TTY=$(tty)
export GCM_CREDENTIAL_STORE=gpg
. "$HOME/.cargo/env"
source /usr/share/nvm/init-nvm.sh
export PATH=/home/zzzpx0/.local/bin:$PATH
eval "$(starship init bash)"
eval "$(zoxide init bash)"
