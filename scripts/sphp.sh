#!/bin/sh

source ~/.phpbrew/bashrc
script=`basename "$0"`

# Display Usage
phpVersions=`phpbrew list | sed s_\ __g | sed s_\*__g`
if [ $# -ne 1 ]; then
    echo "Usage: $script {php_version}"
    echo
    echo "Allowed versions:"
    echo $phpVersions
    exit 0
fi

# Check asked php version
phpVersion=$1
matchedVersion=0
for validVersion in $phpVersions; do
    if [ $validVersion = $phpVersion ]; then
        matchedVersion=1
        break;
    fi
done

if [ $matchedVersion -ne 1 ]; then
    echo "Unsupported php version: $phpVersion"
    echo "Allowed versions:"
    echo $phpVersions
    exit 1
fi

versionNumber=`echo $phpVersion | sed "s/php-//"`
regexpVersion=`echo $versionNumber | sed "s/\./\\\\\./g"`
echo "Switching php cli version to $versionNumber"
phpbrew switch $phpVersion
which php

echo "Switching apache module version to $versionNumber"
cp /usr/local/etc/httpd/httpd.conf /usr/local/etc/httpd/httpd.conf_bac
# Disable all php_module expect the selected one
cat /usr/local/etc/httpd/httpd.conf | sed "s/^LoadModule\ php/#LoadModule\ php/g" | sed "s/^#LoadModule\(.*\)$regexpVersion/LoadModule\1$regexpVersion/g" > /usr/local/etc/httpd/httpd.conf_switch
mv /usr/local/etc/httpd/httpd.conf_switch /usr/local/etc/httpd/httpd.conf

apachectl configtest
if [ $? -ne 0 ]; then
    echo "Error: invalid apache syntax, restoring backup"
    cp /usr/local/etc/httpd/httpd.conf_bac /usr/local/etc/httpd/httpd.conf
    exit 1
fi

echo "Restarting apache"
sudo apachectl -k restart
echo "Opening new $SHELL instance in order to update the path"
$SHELL
