#!/bin/sh

if test ! -f /usr/local/bin/node; then
    echo Install node 10
    brew install node@10
    brew link node@10 --force
fi
if test ! -f /usr/local/bin/gulp; then
    echo Install gulp
    npm install gulp -g
fi
