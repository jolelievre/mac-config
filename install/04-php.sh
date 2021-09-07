#!/bin/sh

# The following steps come from this tutorial
# https://getgrav.org/blog/macos-bigsur-apache-multiple-php-versions

BASEDIR=$(dirname "$0")
source $BASEDIR/../tools/tools.sh
source $BASEDIR/../tools/brew.sh

echo "Update brew"
brew update
echo "Upgrade brew"
brew upgrade
echo "Cleanup brew"
brew cleanup

echo "Add tap shivammathur/php"
brew tap shivammathur/php

dependencies="automake autoconf curl pcre re2c mhash libtool freetype icu4c gettext libpng jpeg libxml2 mcrypt gmp libevent openssl bzip2 zlib libiconv libzip pkg-config oniguruma gd libxpm"
for dependency in $dependencies; do
    if test ! -d /usr/local/Cellar/$dependency; then
        echo Install dependency $dependency
        brew install $dependency
    fi
done

if test $# -gt 0; then
    phpVersions=$1
else
    phpVersions="5.6 7.0 7.1 7.2 7.3 7.4 8.0"
fi

lastInstalledVersion=''
availableVersion=''
for phpVersion in $phpVersions; do
    lastInstalledVersion=$phpVersion
    echo Install PHP version $lastInstalledVersion

    brew install shivammathur/php/php@$lastInstalledVersion
    if test $? -ne 0; then
        echo Error: could not build $lastInstalledVersion
        continue
    fi

    echo "Set default config"
    iniFile=/usr/local/etc/php/$lastInstalledVersion/php.ini
    switchFile=/usr/local/etc/php/$lastInstalledVersion/php.ini_switch
    cat $iniFile | sed "s/^memory_limit\(.*\)$/memory_limit\ =\ 512M/g" > $switchFile
    mv $switchFile $iniFile

    echo Switch to $lastInstalledVersion
    brew unlink php@$lastInstalledVersion
    brew link --overwrite --force php@$lastInstalledVersion

    # Set default xdebug config
    xdebugIniFile="/usr/local/etc/php/$lastInstalledVersion/conf.d/xdebug.ini"
    xdebugIniDistFile="$BASEDIR/../php/xdebug.ini.dist"
    echo "Set default xdebug config from $xdebugIniDistFile"
    cat $xdebugIniDistFile > $xdebugIniFile
done

if test ! -f ~/dev/scripts/sphp.sh; then
    echo Install sPHP
    mkdir -p ~/dev/scripts
    cp $BASEDIR/../scripts/sphp.sh ~/dev/scripts/sphp.sh
fi

if test ! -f /usr/local/bin/composer; then
    echo Install composer
    brew install composer
    composer config --global process-timeout 2000
fi

echo "Don't forget to check your PHP install by visiting:"
echo http://localhost/info.php
echo

if test "$lastInstalledVersion" != ''; then
    echo Switch to last installed version $lastInstalledVersion
    ~/dev/scripts/sphp.sh $lastInstalledVersion
else
    echo Switch to available version $availableVersion
    ~/dev/scripts/sphp.sh $availableVersion
fi
