#!/usr/bin/env bash

set -e

if command -v make >/dev/null; then
  echo "Installing dotfiles..."
  make
else
  echo "No make available. Aborting."
fi
