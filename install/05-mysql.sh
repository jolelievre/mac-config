#!/bin/sh

BASEDIR=$(dirname "$0")

if test ! -f /usr/local/bin/mysqld; then
    echo Install MariaDB
    brew install mariadb
fi

echo "Secure installation"
mariadb-secure-installation

echo Start MariaDB server
brew services start mariadb
brew services restart mariadb
