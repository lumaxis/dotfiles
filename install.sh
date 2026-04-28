#!/usr/bin/env bash

set -e

if ! command -v make > /dev/null 2>&1; then
  echo "No make available. Aborting."
else
  echo "Installing dotfiles..."
  make
fi
