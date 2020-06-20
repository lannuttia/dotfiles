#!/bin/sh
basename=$(dirname $(readlink -f $0))
DOTFILES="$basename/.." $basename/install.sh --no-interactive