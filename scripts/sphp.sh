#!/bin/sh

script=`basename "$0"`

# Display Usage
phpVersions=`ls /usr/local/opt/ | grep php@ | sed s_php@__g`
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

if test -h /usr/local/opt/php; then
    echo Remove default php symlink
    rm /usr/local/opt/php
fi

echo "Switching php cli version to $phpVersion"
brew link --overwrite --force shivammathur/php/php@$phpVersion

read -p "Use PHP FPM? [y/N] " useFPM
# Empty value is default value which is develop
if test "$useFPM" = "y"; then
    useFPM=1
else
    useFPM=0
fi

enable_module() {
    echo Enable module $1
    cat /usr/local/etc/httpd/httpd.conf | sed "s+^#LoadModule $1+LoadModule $1+g" > /usr/local/etc/httpd/httpd.conf_switch
    mv /usr/local/etc/httpd/httpd.conf_switch /usr/local/etc/httpd/httpd.conf
}

disable_module() {
    echo Disable module $1
    cat /usr/local/etc/httpd/httpd.conf | sed "s+^LoadModule $1+#LoadModule $1+g" > /usr/local/etc/httpd/httpd.conf_switch
    mv /usr/local/etc/httpd/httpd.conf_switch /usr/local/etc/httpd/httpd.conf
}

stop_all_fpms () {
    echo Stopping all FPM services
    startedFPM=`brew services | grep php@ | grep started | cut -d' ' -f 1`
    for fpmVersion in $startedFPM; do
        brew services stop $fpmVersion
    done
}

stop_all_fpms

cp /usr/local/etc/httpd/httpd.conf /usr/local/etc/httpd/httpd.conf_bac
if test $useFPM = 1; then
    echo Use PHP FPM

    disable_module mpm_prefork_module
    enable_module mpm_event_module
    enable_module proxy_module
    enable_module proxy_fcgi_module

    # Remove all php modules
    cat /usr/local/etc/httpd/httpd.conf | sed '/LoadModule php/d' > /usr/local/etc/httpd/httpd.conf_switch
else
    echo Use PHP module

    enable_module mpm_prefork_module
    disable_module mpm_event_module
    disable_module proxy_module
    disable_module proxy_fcgi_module

    echo "Switching apache module version to $phpVersion"
    loadModule=`brew info php@$phpVersion | grep LoadModule | xargs`
    echo "Add load module $loadModule"

    # Disable all php_module expect the selected one
    cat /usr/local/etc/httpd/httpd.conf | sed '/^LoadModule php/d' | awk "/LoadModule rewrite_module.*/{print;print \"$loadModule\";next}1" > /usr/local/etc/httpd/httpd.conf_switch
fi
mv /usr/local/etc/httpd/httpd.conf_switch /usr/local/etc/httpd/httpd.conf

apachectl configtest
if [ $? -ne 0 ]; then
    echo "Error: invalid apache syntax, restoring backup"
    cp /usr/local/etc/httpd/httpd.conf_bac /usr/local/etc/httpd/httpd.conf
    exit 1
fi

if test $useFPM = 1; then
    brew services start php@$phpVersion
fi

echo "Restarting apache"
sudo apachectl -k stop
sleep 1
sudo apachectl -k start

echo
echo "You can check the config at http://localhost/info.php"
