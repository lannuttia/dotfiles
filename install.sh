#!/bin/sh

set -e

pwd=$(pwd)
basename=$(dirname $(readlink -f ./install.sh))

$basename/add-repositories

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
    ubuntu)
      sudo apt install -y $($basename/packages)
    ;;
    *)
      >&2 echo "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
else
  >&2 echo 'Failed to sniff environment'
  exit 1
fi

# If Oh My ZSH isn't installed, install it
if [ -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Create a soft link for all configuration files that are not listed in install-exceptions
find $basename \
  -mindepth 1 \
  -maxdepth 1 \
  $(while IFS='' read -r pattern || [ -n "$pattern" ]; do echo "-and -not -name $pattern"; done < $basename/install-exceptions) \
  -exec sh -c "ln -sf {} $HOME/\$(basename {})" \;
