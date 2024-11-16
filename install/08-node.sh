#!/bin/zsh

echo Install dependencies
brew install pkg-config cairo pango libpng jpeg giflib librsvg pixman python-setuptools

if test ! -f /opt/homebrew/opt/nvm; then
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

echo Install node16 and update npm
nvm install 16
nvm use 16
npm i -g npm

echo Install node20 and update npm
nvm install 20
nvm use 20
npm i -g npm

echo Use node 20 by default
nvm alias default 20

echo Install ni tools
npm i -g @antfu/ni

echo Reload zshrc to load nvm config
source ~/.zshrc
