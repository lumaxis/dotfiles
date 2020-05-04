# Resolve DOTFILES_DIR (assuming ~/dotfiles on distros without readlink and/or  ${(%):-%N})

READLINK=$(which greadlink 2>/dev/null || which readlink)
CURRENT_SCRIPT=${(%):-%N}

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

for DOTFILE in "$DOTFILES_DIR"/env/.{env,path}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/env/.{env,path}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Export

export DOTFILES_DIR DOTFILES_EXTRA_DIR
