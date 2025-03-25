# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Source the dotfiles (order matters)
for DOTFILE in "$DOTFILES_DIR"/system/.{path,function,function_*,alias,grep,prompt,autojump,oh-my-zsh,completion}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,function,fnm}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Clean up

unset READLINK CURRENT_SCRIPT SCRIPT_PATH DOTFILE EXTRAFILE
