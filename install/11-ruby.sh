#!/bin/sh

if test ! -f /opt/homebrew/opt/ruby/bin/ruby; then
    echo Install ruby
    brew install ruby
    brew link ruby --force
fi
