#!/bin/sh

OPTS=`getopt -o f --long force -n 'parse-options' -- "$@"`
force=0
eval set -- "$OPTS"
while true; do
    case "$1" in
        -f|--force ) force=1; shift;;
        -- ) shift; break;;
        * ) break;;
    esac
done

if test ! -d ~/dev/ps-install-tools; then
    echo Clone PrestaShop Install tools
    git clone git@github.com:jolelievre/ps-install-tools.git ~/dev/ps-install-tools
else
    echo PrestaShop Install tools already installed
fi
