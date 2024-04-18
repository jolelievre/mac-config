#!/bin/sh

if test ! -f /opt/homebrew/bin/symfony; then
    echo "Installing Symfony installer command"
    wget https://get.symfony.com/cli/installer -O - | bash
fi
