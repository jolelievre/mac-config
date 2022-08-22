#!/bin/sh

if test ! -f /usr/local/opt/python/bin/python3; then
    echo Install python
    brew install python
fi
