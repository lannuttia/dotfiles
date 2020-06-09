#!/bin/sh

set -e

no_interactive=false
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
  echo "\t-n\t--git-user-name\t\tUse the specified git user name"
  echo "\t-e\t--git-user-email\t\tUse the specified git user email"
  echo "\t-I\t--no-interactive\t\tSkip all interactive steps"
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
    "--git-user-name") set -- "$@" "-n" ;;
    "--git-user-email") set -- "$@" "-e" ;;
    "--no-interactive") set -- "$@" "-I" ;;
    *)        set -- "$@" "$arg" ;;
  esac
done

# Parse short options
OPTIND=1
while getopts "hSKIs:k:n:e:" opt; do
  case "$opt" in
    "h") usage; exit 0 ;;
    "S") skip_chsh=true ;;
    "s") user_shell=$OPTARG ;;
    "K") skip_ssh_keygen=true ;;
    "k") ssh_email=$OPTARG ;;
    "n") git_user_name=$OPTARG ;;
    "e") git_user_email=$OPTARG ;;
    "I") no_interactive=true ;;
    "?") usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

basename=$(dirname $(readlink -f $0))
if [ -f /etc/os-release ]; then
  . /etc/os-release
else
  >&2 echo 'Failed to sniff environment'
  exit 1
fi

if [ $ID_LIKE ]; then
  os=$ID_LIKE
else
  os=$ID
fi

update() {
  case $os in
    debian)
      apt update
    ;;
    arch)
      pacman -Sy
    ;;
    *)
      >&2 echo "Unsupported Distribution: $os"
      exit 1
    ;;
}

install() {
  case $os in
    debian)
      apt install -y $($basename/packages)
    ;;
    arch)
      pacman -S --noconfirm $($basename/packages)
    ;;
    *)
      >&2 echo "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
}


update
$basename/add-repositories
update
install

if [ "$skip_chsh" = false ]; then
  if [ "$no_interactive" = true ] && [ ! -z "$user_shell" ]; then
    if [ -z "$user_shell" ]; then
      echo 'Select one of these shells to be your default shell'
      grep ^/bin /etc/shells
      read user_shell;
    fi
    chsh --shell $user_shell $USER
  fi
fi

if [ "$skip_ssh_keygen" = false ] && [ ! -f $HOME/.ssh/id_rsa ] && [ ! -f $HOME/.ssh/id_rsa.pub ]; then
  if [ "$no_interactive" = true ] && [ ! -z "$ssh_email" ]; then
    if [ -z "$ssh_email" ]; then
      echo -n 'What is the email address for you SSH key: '
      read ssh_email
    fi
    ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -b 4096 -C $ssh_email
  fi
fi

if [ -z "$(git config user.email)" ]; then
  if [ "$no_interactive" = true ] && [ ! -z "$git_user_email" ]; then
    if [ -z "$git_user_email" ]; then
      echo -n 'What is the email address you want to use for git: '
      read git_user_email
    fi
    git config --global user.email "$git_user_email"
  fi
fi

if [ -z "$(git config user.name)" ]; then
  if [ "$no_interactive" = true ] && [ ! -z "$git_user_name" ]; then
    if [ -z "$git_user_name" ]; then
      echo -n 'What is the name you want to use for git: '
      read git_user_name
    fi
    git config --global user.name "$git_user_name"
  fi
fi

if [ ! -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

for file in .vimrc .zshenv .zshrc .tmux.conf; do
  ln -sf $basename/$file $HOME/$file
done
