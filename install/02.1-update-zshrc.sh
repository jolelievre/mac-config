#!/bin/sh

BASEDIR=$(dirname "$0")

echo "Forcing zsh config"
cp $BASEDIR/../zsh/.zshrc ~/.zshrc
