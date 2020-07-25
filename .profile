if [ -x "$(command -v vim)" ]; then
  EDITOR=vim
elif [ -x "$(command -v vi)" ]; then
  EDITOR=vi
elif [ -x "$(command -v nano)" ]; then
  EDITOR=nano
fi
export EDITOR

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

if [ "$(tty)" = /dev/tty1 ]; then
  startx
fi

