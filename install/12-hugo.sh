#!/bin/sh

BASEDIR=$(dirname "$0")
source $BASEDIR/../tools/brew.sh

# We use version 0.82 (for now) for PrestaShop doc
install_old_brew_package hugo 0.82
