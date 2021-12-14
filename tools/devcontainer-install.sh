#!/usr/bin/env bash

scriptpath="$(dirname $(realpath "${0}"))"
. "${scriptpath}/install.sh --no-chsh --no-ssh-keygen --no-gpg-keygen --no-git-config --no-gui --no-interactive"
