#!/bin/sh

set -e

# Default settings
DOTFILES=${DOTFILES:-~/.dotfiles}
repo=${repo:-lannuttia/dotfiles}
remote=${remote:-https://github.com/${repo}.git}
branch=${branch:-master}

chsh=${chsh:-true}
ssh_keygen=${ssh_keygen:-true}
git_config=${git_config:-true}

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

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

run_as_root() {
  if [ "$EUID" = 0 ]; then
    eval "$*"
  elif command_exists sudo; then
    sudo -v
    if [ $? -eq 0 ]; then
      eval "sudo sh -c '$*'"
    else
      su -c "$*"
    fi
  else
    su -c "$*"
  fi
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

clone_dotfiles() {
  echo "${BLUE}Cloning Anthony Lannutti's Dotfiles...${RESET}"

  command_exists git || {
    error "git is not installed"
    exit 1
  }

  if [ "$OSTYPE" = cygwin ] && git --version | grep -q msysgit; then
		error "Windows/MSYS Git is not supported on Cygwin"
		error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

  git clone -c core.eol=lf -c core.autocrlf=false \
      -c fsck.zeroPaddedFilemode=ignore \
      -c fetch.fsck.zeroPaddedFilemode=ignore \
      -c receive.fsck.zeroPaddedFilemode=ignore \
      --depth=2 --branch "$branch" "$remote" "$DOTFILES" || {
    error "git clone of Anthony Lannutti's Dotfiles repo failed"
    exit 1
  }

  echo
}

setup_shell() {
  if [ "$chsh" = false ]; then
    return
  fi

  if ! command_exists chsh; then
    cat <<-EOF
			I can't change your shell automatically because this system does not have chsh.
			${BLUE}If you want a different shell, you will have to manually change it.${RESET}
		EOF
  fi

  if [ "$chsh" = true ]; then
    echo "${YELLOW}Select one of these shells to be your default shell"
    grep -v '^#' /etc/shells
    read user_shell;
    chsh --shell $user_shell $USER
  fi
}

setup_gitconfig() {
  if [ "$git_config" = true ]; then
    echo -n 'What is the email address you want to use for git: '
    read git_user_email
    git config --global user.email "$git_user_email"
    
    echo -n 'What is the name you want to use for git: '
    read git_user_name
    git config --global user.name "$git_user_name"
  
    git config --global core.autocrlf input
  fi
}

setup_ssh() {
  if [ "$ssh_keygen" = true ] && [ ! -f $HOME/.ssh/id_rsa ] && [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    echo -n 'What is the email address for you SSH key: '
    read ssh_email
    ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -b 4096 -C $ssh_email
  fi
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "\t--help\t\t\tDisplay this help menu"
  echo "\t--no-chsh\t\tSkip running chsh for user [DEFAULT=$([ "$chsh" = true ] && echo "false" || echo "true")]"
  echo "\t--no-ssh-keygen\t\tSkip automated SSH key generation"
  echo "\t--no-git-config\t\tSkip interactive Git configuration"
  echo "\t--no-interactive\t\tSkip all interactive steps"
}

update() {
  case $os in
    debian)
      run_as_root apt update
    ;;
    arch)
      run_as_root pacman -Sy
    ;;
    *)
      >&2 echo "Unsupported Distribution: $os"
      exit 1
    ;;
  esac
}

add_repositories() {
  case $ID in
      kali)
        echo 'No additional repositorys will be added for Kali'
        run_as_root apt install --no-install-recommends -y ca-certificates curl apt-transport-https gnupg
      ;;
      ubuntu)
        arch=$(dpkg --print-architecture)
        echo 'Installing minimal packages to add Azure CLI repository'
        run_as_root apt install --no-install-recommends -y ca-certificates curl apt-transport-https gnupg
        echo 'Adding Microsoft signing key'
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | run_as_root tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
        echo 'Adding Microsoft Azure CLI repository'
        echo "deb [arch=${arch}] https://packages.microsoft.com/repos/azure-cli/ ${VERSION_CODENAME} main" | run_as_root tee /etc/apt/sources.list.d/azure-cli.list
      ;;
      debian)
        arch=$(dpkg --print-architecture)
        echo 'Installing minimal packages to add Azure CLI repository'
        run_as_root apt install --no-install-recommends -y ca-certificates curl apt-transport-https gnupg
        echo 'Adding Microsoft signing key'
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | run_as_root tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
        echo 'Adding Microsoft Azure CLI repository'
        echo "deb [arch=${arch}] https://packages.microsoft.com/repos/azure-cli/ ${VERSION_CODENAME} main" | run_as_root tee /etc/apt/sources.list.d/azure-cli.list
      ;;
      arch)
      ;;
      *)
          >&2 echo "Unsupported OS: $NAME"
          exit 1
      ;;
  esac
}

packages() {
  case $ID in
    kali)
      case $VERSION_ID in
        *)
          echo -n 'git python3 python3-pip openssh-client dnsutils vim neofetch zsh tmux azure-cli'
        ;;
      esac
    ;;
    ubuntu)
      case $VERSION_ID in
        18.04)
          echo -n 'git python3 python3-pip openssh-client dnsutils vim neofetch zsh tmux azure-cli'
        ;;
        20.04)
          echo -n 'git python3 python3-pip openssh-client dnsutils vim neofetch zsh tmux azure-cli'
        ;;
        *)
          >&2 echo "Unsupported version of $NAME: $VERSION_ID"
          exit 1;
        ;;
      esac
    ;;
    debian)
      case $VERSION_ID in
        10)
          echo -n 'git python3 python3-pip openssh-client dnsutils vim neofetch zsh tmux azure-cli'
        ;;
        9)
          echo -n 'git python3 python3-pip openssh-client dnsutils vim neofetch zsh tmux azure-cli'
        ;;
        *)
          >&2 echo "Unsupported version of $NAME: $VERSION_ID"
        ;;
      esac
    ;;
    arch)
      echo -n 'git python python-pip openssh bind-tools tmux neofetch zsh'
    ;;
    *)
      >&2 echo "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
}

install() {
  case $os in
    debian)
      run_as_root apt install -y $(packages)
    ;;
    arch)
      run_as_root pacman -S --noconfirm $(packages)
    ;;
    *)
      >&2 echo "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
  if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  if command_exists az; then
    az extension add --name azure-devops --name codespaces
  fi
  if command_exists pip3; then
    pip3 install yq
  fi
}

link_dotfiles() {
  for file in .vimrc .zshenv .zshrc .tmux.conf; do
    ln -sf $DOTFILES/$file $HOME/$file
  done
}

main() {
  if [ ! -t 0 ]; then
    chsh=false
    ssh_keygen=false
    git_config=false
  fi

  # Transform long options to short options
  while [ $# -gt 0 ]; do
    case $1 in
      --help) usage; exit 0 ;;
      --no-chsh) chsh=false ;;
      --no-ssh-keygen) ssh_keygen=false ;;
      --no-git-config) git_config=false ;;
      --no-interactive) chsh=false; ssh_keygen=false; git_config=false ;;
      *) usage >&2; exit 1 ;;
    esac
    shift
  done

  setup_color

  update
  add_repositories
  update
  install
  setup_ssh
  setup_shell
  setup_gitconfig
  clone_dotfiles
  link_dotfiles

  printf "$GREEN"
	cat <<-'EOF'
    ___        _   _                         _                             _   _   _ _      ______      _    __ _ _           
   / _ \      | | | |                       | |                           | | | | (_| )     |  _  \    | |  / _(_) |          
  / /_\ \_ __ | |_| |__   ___  _ __  _   _  | |     __ _ _ __  _ __  _   _| |_| |_ _|/ ___  | | | |___ | |_| |_ _| | ___  ___ 
  |  _  | '_ \| __| '_ \ / _ \| '_ \| | | | | |    / _` | '_ \| '_ \| | | | __| __| | / __| | | | / _ \| __|  _| | |/ _ \/ __|
  | | | | | | | |_| | | | (_) | | | | |_| | | |___| (_| | | | | | | | |_| | |_| |_| | \__ \ | |/ / (_) | |_| | | | |  __/\__ \
  \_| |_/_| |_|\__|_| |_|\___/|_| |_|\__, | \_____/\__,_|_| |_|_| |_|\__,_|\__|\__|_| |___/ |___/ \___/ \__|_| |_|_|\___||___/
                                      __/ |                                                                                   
                                     |___/                 ....are now installed!                                              
	EOF
	printf "$RESET"
}

main "$@"
