# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve DOTFILES_DIR (assuming ~/.dotfiles on distros without readlink and/or $BASH_SOURCE/$0)
CURRENT_SCRIPT=$BASH_SOURCE

if [ -n "$CURRENT_SCRIPT" ] && command -v readlink >/dev/null 2>&1; then
  SCRIPT_PATH=$(readlink -n "$CURRENT_SCRIPT")
  DOTFILES_DIR="${PWD}/$(dirname "$(dirname "$SCRIPT_PATH")")"
elif [ -d "$HOME/dotfiles" ]; then
  DOTFILES_DIR="$HOME/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

for DOTFILE in "$DOTFILES_DIR"/system/.{path,function,function_*,alias,grep,autojump,completion,custom}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,function,fnm}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Wrap up

unset CURRENT_SCRIPT SCRIPT_PATH DOTFILE
export DOTFILES_DIR
