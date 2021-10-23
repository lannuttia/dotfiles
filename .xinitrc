. ${HOME}/.xprofile

xrdb ${HOME}/.Xresources

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

dbus-launch --sh-syntax --exit-with-session ssh-agent bspwm
