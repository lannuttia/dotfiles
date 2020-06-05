#!/bin/sh

set -e

skip_chsh=false
skip_ssh_keygen=false

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "\t-h\t--help\t\t\tDisplay this help menu"
  echo "\t-S\t--no-chsh\t\tSkip running chsh for user [DEFAULT=$skip_chsh]"
  echo "\t-s\t--use-shell\t\tUse the specified shell"
  echo "\t-K\t--no-ssh-keygen\t\tSkip Automated SSH key generation"
  echo "\t-k\t--ssh-email\t\tEmail address to use during SSH key generation"
}

# Transform long options to short options
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--no-chsh") set -- "$@" "-S" ;;
    "--user-shell") set -- "$@" "-s" ;;
    "--no-ssh-keygen") set -- "$@" "-K" ;;
    "--ssh-email") set -- "$@" "-k" ;;
    *)        set -- "$@" "$arg" ;;
  esac
done

# Parse short options
OPTIND=1
while getopts "hSKs:k:" opt; do
  case "$opt" in
    "h") usage; exit 0 ;;
    "S") skip_chsh=true ;;
    "s") user_shell=$OPTARG ;;
    "K") skip_ssh_keygen=true ;;
    "k") ssh_email=$OPTARG ;;
    "?") usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

basename=$(dirname $(readlink -f $0))

$basename/add-repositories

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

if [ "$skip_chsh" = false ]; then
  if [ -z "$user_shell" ]; then
    echo 'Select one of these shells to be your default shell'
    grep ^/bin /etc/shells
    read user_shell;
  fi
  chsh --shell $user_shell $USER
fi

if [ "$skip_ssh_keygen" = false ] && [ ! -f $HOME/.ssh/id_rsa ] && [ ! -f $HOME/.ssh/id_rsa.pub ]; then
  if [ -z "$ssh_email" ]; then
    echo -n 'What is the email address for you SSH key: '
    read ssh_email
  fi
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
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

for file in .vimrc .zshenv .zshrc .tmux.conf; do
  ln -sf $basename/$file $HOME/$file
done
