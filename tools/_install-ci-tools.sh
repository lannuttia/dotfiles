#!/bin/sh

set -e

if [ -f /etc/os-release ] || [ -f /usr/lib/os-release ] || [ -f /etc/openwrt_release ] || [ -f /etc/lsb_release ]; then
   for file in /etc/os-release /usr/lib/os-release /etc/openwrt_release /etc/lsb_release; do
     [ -f "$file" ] && . "$file" && break
   done
else
  error 'Failed to sniff environment'
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

packages() {
  case $ID in
    kali)
      case $VERSION_ID in
        *) echo -n 'git curl' ;;
      esac
    ;;
    ubuntu|elementary)
      case $VERSION_ID in
        18.04|5.*)
          echo -n 'git curl'
        ;;
        20.04)
          echo -n 'git curl'
        ;;
        *)
          error "Unsupported version of $NAME: $VERSION_ID"
          exit 1;
        ;;
      esac
    ;;
    debian)
      case $VERSION_ID in
        10)
          echo -n 'git curl'
        ;;
        9)
          echo -n 'git curl'
        ;;
        *)
          error "Unsupported version of $NAME: $VERSION_ID"
        ;;
      esac
    ;;
    alpine)
      case $VERSION_ID in
        3\.*)
          echo -n 'git curl'
	      ;;
        *)
          error "Unsupported version of $NAME: $VERSION_ID"
        ;;
      esac;
    ;;
    arch|artix)
      echo -n 'git curl'
    ;;
    *)
      error "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
}

install() {
  case $os in
    debian|ubuntu)
      run_as_root apt install -y $(packages)
    ;;
    arch|artix)
      run_as_root pacman -S --noconfirm $(packages)
    ;;
    alpine)
      run_as_root apk add $(packages)
    ;;
    *)
      error "Unsupported OS: $NAME"
      exit 1
    ;;
  esac
}

update() {
  case $os in
    debian|ubuntu)
      run_as_root apt update
    ;;
    alpine)
      run_as_root apk update
    ;;
    arch|artix)
      run_as_root pacman -Sy
    ;;
    *)
      error "Unsupported Distribution: $os"
      exit 1
    ;;
  esac
}

main() {
  update
  install
}

main
