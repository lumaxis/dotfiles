# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Source the dotfiles (order matters)
# Completions must be initalized before oh-my-zsh
for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,alias,grep,prompt,autojump,completion,custom,oh-my-zsh}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,function,nodenv}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Hook for extra/custom stuff

DOTFILES_EXTRA_DIR="$HOME/.extra"

if [ -d "$DOTFILES_EXTRA_DIR" ]; then
  for EXTRAFILE in "$DOTFILES_EXTRA_DIR"/runcom/*.sh; do
    [ -f "$EXTRAFILE" ] && . "$EXTRAFILE"
  done
fi

# Clean up

unset READLINK CURRENT_SCRIPT SCRIPT_PATH DOTFILE EXTRAFILE
