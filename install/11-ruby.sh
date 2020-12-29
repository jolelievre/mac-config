#!/bin/sh

if test ! -f /usr/local/opt/ruby/bin/ruby; then
    echo Install ruby
    brew install ruby
    brew link ruby --force
fi
