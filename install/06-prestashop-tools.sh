#!/bin/sh

if test ! -d ~/dev/ps-install-tools; then
    echo Clone PrestaShop Install tools
    git clone git@github.com:jolelievre/ps-install-tools.git ~/dev/ps-install-tools
fi

if test ! -f ~/dev/scripts/ps_install.sh; then
    echo Install ps_install
    cp ~/dev/ps-install-tools/legacy/ps_install.sh ~/dev/scripts/ps_install.sh
fi

if test ! -f ~/dev/scripts/ps_uninstall.sh; then
    echo Install ps_uninstall
    cp ~/dev/ps-install-tools/legacy/ps_uninstall.sh ~/dev/scripts/ps_uninstall.sh
fi
