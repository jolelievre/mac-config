#!/bin/sh

script=`basename "$0"`

# Display Usage
phpVersions=`brew list | grep php | sed s_\ __g | sed s_php@__g`
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

echo "Unlinking all php versions"
for validVersion in $phpVersions; do
    brew unlink php@$validVersion
done
echo "Switching php cli version to $phpVersion"
brew link --overwrite --force php@$phpVersion

echo Updating global php symlink
rm -f /usr/local/opt/php
ln -s /usr/local/opt/php@$phpVersion /usr/local/opt/php

echo "Switching apache module version to $phpVersion"
loadModule=`brew info php@$phpVersion | grep LoadModule | xargs`
echo "Add load module $loadModule"

# Disable all php_module expect the selected one
cp /usr/local/etc/httpd/httpd.conf /usr/local/etc/httpd/httpd.conf_bac
cat /usr/local/etc/httpd/httpd.conf | sed '/^LoadModule php/d' | awk "/LoadModule rewrite_module.*/{print;print \"$loadModule\";next}1" > /usr/local/etc/httpd/httpd.conf_switch
mv /usr/local/etc/httpd/httpd.conf_switch /usr/local/etc/httpd/httpd.conf

apachectl configtest
if [ $? -ne 0 ]; then
    echo "Error: invalid apache syntax, restoring backup"
    cp /usr/local/etc/httpd/httpd.conf_bac /usr/local/etc/httpd/httpd.conf
    exit 1
fi

echo "Restarting apache"
sudo apachectl -k restart
echo "You can check the config at http://localhost/info.php"
echo "Opening new $SHELL instance in order to update the path"
$SHELL
