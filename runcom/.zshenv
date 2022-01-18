# Resolve DOTFILES_DIR (assuming ~/dotfiles on distros without readlink and/or  ${(%):-%N})

CURRENT_SCRIPT=${(%):-%N}
READLINK=$(which readlink)

if [[ -n $CURRENT_SCRIPT && -x "$READLINK" ]]; then
  SCRIPT_PATH=$($READLINK -f "$CURRENT_SCRIPT")
  DOTFILES_DIR=$(dirname "$(dirname "$SCRIPT_PATH")")
elif [ -d "$HOME/dotfiles" ]; then
  DOTFILES_DIR="$HOME/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Source the env files
for DOTFILE in "$DOTFILES_DIR"/env/.env; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if $DOTFILES_DIR/bin/is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/env/.{env,path}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Export

export DOTFILES_DIR DOTFILES_EXTRA_DIR
