#!/bin/zsh

BASEDIR=$(dirname "$0")

echo "Forcing zsh config"
cp $BASEDIR/../zsh/.zshrc ~/.zshrc

echo "Forcing aliases"
cp $BASEDIR/../zsh/.oh-my-zsh/custom/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh

source ~/.zshrc
