#!/bin/sh
if [ "$(id -u)" = 0 ]; then
  ./install.sh --no-interactive
elif [ ! -z $(command -v sudo) ]; then
  sudo -v
  if [ $? -eq 0 ]; then
    sudo -E ./install.sh --no-interactive
  else
    >&2 echo "Failed to validate sudo"
    exit 1;
  fi
else
  >&2 echo "Cannot run as non-root user without sudo priveledges"
  exit 1;
fi
