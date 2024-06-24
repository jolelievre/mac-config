#!/bin/sh

if test ! -f /opt/homebrew/opt/python/bin/python3; then
    echo Install python
    brew install python
fi
