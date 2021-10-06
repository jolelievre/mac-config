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

echo Install node10 and update npm
nvm install 10
nvm use 10
npm i -g npm

echo Install node14 and update npm
nvm install 14
nvm use 14
npm i -g npm

nvm alias default 14
