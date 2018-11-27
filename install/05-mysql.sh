#!/bin/sh

if test ! -f /usr/local/bin/mysqld; then
    echo Install MariaDB
    brew install mariadb
fi

echo Start MariaDB server
brew services start mariadb
brew services restart mariadb
