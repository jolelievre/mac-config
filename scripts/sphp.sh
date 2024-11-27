#!/bin/sh

script=`basename "$0"`

# Display Usage
phpVersions=`ls /opt/homebrew/opt/ | grep php@ | sed s_php@__g`
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

if test -h /opt/homebrew/opt/php; then
    echo Remove default php symlink
    rm /opt/homebrew/opt/php
fi

echo "Switching php cli version to $phpVersion"
for validVersion in $phpVersions; do
    brew unlink shivammathur/php/php@$validVersion
    brew unlink php@$validVersion
done
brew unlink php

# Brew uses php to identify the latest stable version (not php@8.3 for example), to dynamically get how brew refers to the targetted
# version we get the package info and extract it from the load module path
loadModule=`brew info shivammathur/php/php@$phpVersion | grep LoadModule | xargs`
brewAliasVersion=`echo $loadModule | sed 's@LoadModule php_module /opt/homebrew/opt/@@' | sed 's@/lib/httpd/modules/libphp.so@@'`

if [ "php" = "$brewAliasVersion" ]; then
    echo Link PHP to default brew php
    brew link --overwrite --force php
else
    echo Link PHP to shivammathur/php/php@$phpVersion
    brew link --overwrite --force shivammathur/php/php@$phpVersion
fi

read -p "Use PHP FPM? [y/N] " useFPM
# Empty value is default value which is develop
if test "$useFPM" = "y"; then
    useFPM=1
else
    useFPM=0
fi

enable_module() {
    echo Enable module $1
    cat /opt/homebrew/etc/httpd/httpd.conf | sed "s+^#LoadModule $1+LoadModule $1+g" > /opt/homebrew/etc/httpd/httpd.conf_switch
    mv /opt/homebrew/etc/httpd/httpd.conf_switch /opt/homebrew/etc/httpd/httpd.conf
}

disable_module() {
    echo Disable module $1
    cat /opt/homebrew/etc/httpd/httpd.conf | sed "s+^LoadModule $1+#LoadModule $1+g" > /opt/homebrew/etc/httpd/httpd.conf_switch
    mv /opt/homebrew/etc/httpd/httpd.conf_switch /opt/homebrew/etc/httpd/httpd.conf
}

stop_all_fpms () {
    echo Stopping all FPM services
    startedFPM=`brew services | grep php@ | grep started | cut -d' ' -f 1`
    for fpmVersion in $startedFPM; do
        brew services stop $fpmVersion
    done
}

stop_all_fpms

cp /opt/homebrew/etc/httpd/httpd.conf /opt/homebrew/etc/httpd/httpd.conf_bac
if test $useFPM = 1; then
    echo Use PHP FPM

    disable_module mpm_prefork_module
    enable_module mpm_event_module
    enable_module proxy_module
    enable_module proxy_fcgi_module

    # Remove all php modules
    cat /opt/homebrew/etc/httpd/httpd.conf | sed '/LoadModule php/d' > /opt/homebrew/etc/httpd/httpd.conf_switch
else
    echo Use PHP module

    enable_module mpm_prefork_module
    disable_module mpm_event_module
    disable_module proxy_module
    disable_module proxy_fcgi_module

    echo "Switching apache module version to $phpVersion"
    loadModule=`brew info shivammathur/php/php@$phpVersion | grep LoadModule | xargs`
    loadModulePath=`echo $loadModule | sed 's/LoadModule php_module//'`
    if [ ! -f $loadModulePath ]; then
        echo Brew PHP module path invalid switching to default value
        loadModule="LoadModule php_module /opt/homebrew/opt/php@$phpVersion/lib/httpd/modules/libphp.so"
    fi
    echo "Add load module $loadModule"

    # Disable all php_module expect the selected one
    cat /opt/homebrew/etc/httpd/httpd.conf | sed '/^LoadModule php/d' | awk "/LoadModule rewrite_module.*/{print;print \"$loadModule\";next}1" > /opt/homebrew/etc/httpd/httpd.conf_switch
fi
mv /opt/homebrew/etc/httpd/httpd.conf_switch /opt/homebrew/etc/httpd/httpd.conf

apachectl configtest
if [ $? -ne 0 ]; then
    echo "Error: invalid apache syntax, restoring backup"
    cp /opt/homebrew/etc/httpd/httpd.conf_bac /opt/homebrew/etc/httpd/httpd.conf
    exit 1
fi

if test $useFPM = 1; then
    brew services start php@$phpVersion
fi

echo "Restarting apache"
sudo brew services restart httpd

echo
echo "You can check the config at http://localhost/info.php"
