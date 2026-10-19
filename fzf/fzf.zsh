# fzf shell integration
# Ctrl-R: search command history
# Ctrl-T: insert selected files/directories
# Alt-C: change into a selected directory
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
