. ${HOME}/.xprofile

xrdb ${HOME}/.Xresources

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

ssh-agent dwm
