#!/bin/sh
basename=$(dirname $(readlink -f $0))
$basename/install.sh --no-interactive