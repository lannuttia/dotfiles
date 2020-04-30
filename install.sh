#!/bin/sh

set -e

pwd=$(pwd)
basename=$(dirname $(readlink -f ./install.sh))
cd $basename

./add-repositories

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
    ubuntu)
      sudo apt install -y $(./packages)
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

if [ ! -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ln -sf $basename/.vimrc $HOME/.vimrc
ln -sf $basename/.zshrc $HOME/.zshrc
