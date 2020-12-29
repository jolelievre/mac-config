#!/bin/sh

BASEDIR=$(dirname "$0")

#brew tap blackfireio/homebrew-blackfire
if test ! -d /usr/local/Cellar/blackfire-agent; then
    brew install blackfire-agent
fi

# This is the equivalent to sudo blackfire-agent -register
cp $BASEDIR/../blackfire/agent /usr/local/etc/blackfire/agent

# Copy services config and load for the first time
ln -sfv /usr/local/opt/blackfire-agent/*.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.blackfire-agent.plist

# Init client
cp $BASEDIR/../blackfire/.blackfire.ini ~

phpVersions="56 71 72 73"
for phpVersion in $phpVersions; do
    blackfireDir="/usr/local/Cellar/blackfire-php$phpVersion"
    if test ! -d $blackfireDir; then
        brew install blackfire-php$phpVersion
    fi
    
    blackfireVersions=`ls $blackfireDir`
    libLink=$blackfireDir/blackfire.so
    for blackfireVersion in $blackfireVersions; do
        if test -d $blackfireDir/$blackfireVersion; then
            rm -f $libLink
            ln -s $blackfireDir/$blackfireVersion/blackfire.so $libLink
        fi
    done

    installedPhpVersions=`ls ~/.phpbrew/php`
    for installedPhpVersion in $installedPhpVersions; do
        versionNumber=`echo $installedPhpVersion | sed "s/php-//"`
        minimalVersion=`echo $versionNumber | sed "s/\.//g" | cut -c 1-2`
        if test $minimalVersion -eq $phpVersion; then
            iniPath="~/.phpbrew/php/$installedPhpVersion/etc/php.ini"
            if test -f $iniPath; then
                cat $iniPath | grep blackfire.so > /dev/null
                hasBlackfire=$?
                if test $hasBlackfire -ne 0; then
                    echo "Install Blackfire lib $libLink in $iniPath"
                    echo "" >> $iniPath
                    echo "extension=$libLink" >> $iniPath
                fi
            fi
        fi
    done
done
