#!/bin/sh

BASEDIR=$(dirname "$0")

brew tap blackfireio/homebrew-blackfire
if test ! -d /opt/homebrew/Cellar/blackfire; then
    brew install blackfire
fi

# Register agent config
if [ -f /opt/homebrew/etc/blackfire/agent ]; then
  echo Blackfire agent config already present, to reconfigure it please run: blackfire agent:config
else
  blackfire agent:config
fi

# Start the service
echo Starting blackfire service
brew services start blackfire

# Init client config
if [ -f ~/.blackfire.ini ]; then
  echo Blackfire client config already present, to reconfigure it please run: blackfire client:config
else
  blackfire client:config
fi

# phpVersions="56 71 72 73 74 80 81 82"
phpVersions="74 80 81 82"
for phpVersion in $phpVersions; do
    blackfireDir="/opt/homebrew/Cellar/blackfire-php$phpVersion"
    if test ! -d $blackfireDir; then
        brew install blackfire-php$phpVersion
    fi

# Previous manual install of the lib, commented for now
#    blackfireVersions=`ls $blackfireDir`
#    libLink=$blackfireDir/blackfire.so
#    for blackfireVersion in $blackfireVersions; do
#        if test -d $blackfireDir/$blackfireVersion; then
#            rm -f $libLink
#            ln -s $blackfireDir/$blackfireVersion/blackfire.so $libLink
#        fi
#    done

#    installedPhpVersions=`brew list | grep php | sed s_\ __g | sed s_php@__g`
#    for versionNumber in $installedPhpVersions; do
#        minimalVersion=`echo $versionNumber | sed "s/\.//g" | cut -c 1-2`
#        if test $minimalVersion -eq $phpVersion; then
#            iniPath="/opt/homebrew/etc/php/$versionNumber/php.ini"
#            if test -f $iniPath; then
#                cat $iniPath | grep blackfire.so > /dev/null
#                hasBlackfire=$?
#                if test $hasBlackfire -ne 0; then
#                    echo "Install Blackfire lib $libLink in $iniPath"
#                    echo "" >> $iniPath
#                    echo "extension=$libLink" >> $iniPath
#                fi
#            fi
#        fi
#    done
done

echo Restart apache
sudo brew services restart httpd
