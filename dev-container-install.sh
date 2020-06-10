#!/bin/sh
command='./install.sh --no-interactive'
if [ "$(id -u)" = 0 ]; then
  ./install.sh --no-interactive
elif [ ! -z $(command -v sudo) ] && [ "$(sudo -v)" = 0 ]; then
  sudo -H $command
else
  >&2 echo "Cannot run as non-root user without sudo priveledges"
  exit 1;
fi
