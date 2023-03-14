#!/bin/sh

BASEDIR=$(dirname "$0")

mysqlVersions="5.7 8.0"
lastInstalledVersion=''
for mysqlVersion in $mysqlVersions; do
    echo Installing Mysql $mysqlVersion
    lastInstalledVersion=$mysqlVersion
    mysqlPath=`brew --prefix mysql@$mysqlVersion`
    if test ! -d $mysqlPath; then
        echo Brew install Mysql $mysqlVersion
        brew install mysql@$mysqlVersion
    fi

    plistPath="$mysqlPath/homebrew.mxcl.mysql@$mysqlVersion.plist"
    echo Updating folder in $plistPath
    cat $plistPath | sed "s_/usr/local/var/mysql</string>_/usr/local/var/mysql${mysqlVersion}</string>_g" > $plistPath.tmp
    mv $plistPath.tmp $plistPath

    mysqlFolder="/usr/local/var/mysql$mysqlVersion"
    if test ! -d $mysqlFolder; then
        echo Create Mysql folder $mysqlFolder
        mkdir $mysqlFolder
    fi
done

if test ! -f ~/dev/scripts/smysql.sh; then
    echo Install sMysql
    mkdir -p ~/dev/scripts
    scriptDir=`cd $BASEDIR/../scripts && pwd`
    ln -s $scriptDir/smysql.sh ~/dev/scripts/smysql.sh
fi

if test "$lastInstalledVersion" != ''; then
    echo Switch to last installed version $lastInstalledVersion
    ~/dev/scripts/smysql.sh $lastInstalledVersion
fi

# Wait a little for mysql to be correctly booted
echo Setting root credentials
sleep 1
mysql -uroot < $BASEDIR/../mysql/install-root.sql
