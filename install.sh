#!/bin/sh

set -e

pwd=$(pwd)
basename=$(dirname $(readlink -f ./install.sh))

./add-repositories

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
    ubuntu|debian|kali)
      sudo apt install -y $($basename/packages)
    ;;
    arch)
      sudo pacman -S --noconfirm $($basename/packages)
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

echo 'Select one of these shells to be your default shell'
grep ^/bin /etc/shells
read shell;
chsh --shell $shell $USER

if [ ! -f $HOME/.ssh/id_rsa ] && [ ! -f $HOME/.ssh/id_rsa.pub ]; then
  echo -n 'What is the email address for you SSH key: '
  read ssh_email
  ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -b 4096 -C $ssh_email
fi

if [ -z "$(git config user.email)" ]; then
  echo -n 'What is the email address you want to use for git: '
  read git_user_email
  git config --global user.email "$git_user_email"
fi

if [ -z "$(git config user.name)" ]; then
  echo -n 'What is the name you want to use for git: '
  read git_user_name
  git config --global user.name "$git_user_name"
fi

if [ ! -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fskSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

for file in .vimrc .zshenv .zshrc .tmux.conf; do
  ln -sf $basename/$file $HOME/$file
done
