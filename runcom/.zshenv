# Resolve DOTFILES_DIR (assuming ~/dotfiles on distros without readlink and/or  ${(%):-%N})

CURRENT_SCRIPT=${(%):-%N}

if type /opt/homebrew/bin/greadlink >/dev/null; then
  # Use greadlink when installed in new Homebrew directory
  READLINK=/opt/homebrew/bin/greadlink
elif type /usr/local/bin/greadlink >/dev/null; then
  # Use greadlink when installed in legacy Homebrew directory
  READLINK=/usr/local/bin/greadlink
elif [[ ! "$OSTYPE" =~ ^darwin ]]; then
  # Only look for regular readlink when not on macOS because the macOS version does not support the -f flag
  READLINK=$(which readlink)
fi

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
