#!/bin/sh

sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
sudo xcode-select -switch /Library/Developer/CommandLineTools
xcodebuild -runFirstLaunch
