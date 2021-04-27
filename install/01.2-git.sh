#!/bin/sh

BASEDIR=$(dirname "$0")
cp $BASEDIR/../git/.gitconfig ~
cp $BASEDIR/../git/.gitignore ~

brew install gh
brew install hub
