#!/bin/sh

set -e

pwd=$(pwd)
basename=$(dirname $(readlink -f ./install.sh))

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
    ubuntu)
      echo 'Preparing ubuntu environment'
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

# Create a soft link for all configuration files that are not listed in install-exceptions
find $basename \
  -mindepth 1 \
  -maxdepth 1 \
  $(while IFS='' read -r pattern || [ -n "$pattern" ]; do echo "-and -not -name $pattern"; done < $basename/install-exceptions) \
  -exec sh -c "ln -sf {} $HOME/\$(basename {})" \;
