#!/usr/bin/env bash

set -e

if [ -z "make" ]; then
  echo "No make available. Aborting."
else
  echo "Installing dotfiles..."
  make
fi
