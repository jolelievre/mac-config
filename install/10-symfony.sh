#!/bin/sh

if test ! -f /usr/local/bin/symfony; then
    echo "Installing Symfony installer command"
    curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
    chmod a+x /usr/local/bin/symfony
fi
