GPG_TTY=$(tty)
export GPG_TTY

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# mutt background fix
COLORFGBG="default;default"

if [ "$(tty)" = /dev/tty1 ]; then
  startx
fi

if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -f "${HOME}/.cargo/env" ]; then
  fi
. "$HOME/.cargo/env"
