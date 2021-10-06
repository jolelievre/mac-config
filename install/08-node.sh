#!/bin/sh

if test ! -f /usr/local/opt/nvm; then
    echo Install nvm
    brew install nvm
fi

if test ! -d ~/.nvm; then
    echo Create nvm folder
    mkdir ~/.nvm
fi

echo Reload zshrc to load nvm config
source ~/.zshrc

nvm install 10
nvm install 14

nvm use 14
nvm alias default 14
