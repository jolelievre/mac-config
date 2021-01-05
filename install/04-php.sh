#!/bin/sh

# The following steps come from this tutorial
# https://enzo.weknowinc.com/articles/2014/10/17/manage-php-versions-with-phpbrew

BASEDIR=$(dirname "$0")
source $BASEDIR/../tools/tools.sh
source $BASEDIR/../tools/brew.sh

dependencies="automake autoconf curl pcre re2c mhash libtool icu4c gettext libpng jpeg libxml2 mcrypt gmp libevent openssl@1.1 bzip2 zlib libiconv libzip pkg-config oniguruma"
for dependency in $dependencies; do
    if test ! -d /usr/local/Cellar/$dependency; then
        echo Install dependency $dependency
        brew install $dependency
    fi
done

if test ! -f /usr/local/bin/phpbrew; then
    echo Install PHPBrew
    curl -L -O https://github.com/phpbrew/phpbrew/releases/latest/download/phpbrew.phar
    chmod +x phpbrew.phar
    sudo mv phpbrew.phar /usr/local/bin/phpbrew
fi

if test ! -d ~/.phpbrew; then
    echo Init PHPBrew
    phpbrew init
fi

if test -f ~/.phpbrew/bashrc; then
    source ~/.phpbrew/bashrc
fi

echo Self update phpbrew
# phpbrew self-update

echo Update list of known versions
# phpbrew update

echo "Prefer homebrew as source"
# phpbrew lookup-prefix homebrew

if test $# -gt 0; then
    phpVersions=$1
else
    phpVersions="5.6 7.1 7.2 7.3 7.4 8.0"
fi

echo Getting available versions
latestVersions=""
for phpVersion in $phpVersions; do
    knownVersions=`phpbrew known --more --old | grep $phpVersion`
    IFS=', ' read -r -a minorVersions <<< "$knownVersions"
    latestVersion=${minorVersions[1]}
    latestVersions="$latestVersions php-$latestVersion"
done
echo Try to install $latestVersions

installedVersions=`phpbrew list | sed s_\ __g | sed s_\*__g`
echo Already installed: $installedVersions
lastInstalledVersion=''
availableVersion=''
for phpVersion in $latestVersions; do
    matchedVersion=0
    for installedVersion in $installedVersions; do
        if [ $installedVersion = $phpVersion ]; then
            matchedVersion=1
            availableVersion=$phpVersion
            break;
        fi
    done

    if [ $matchedVersion -ne 1 ]; then
        lastInstalledVersion=$phpVersion
        echo Install PHP version $lastInstalledVersion
        # Use the appropriate icu version
        echo "Setting proper icu version"

        # If result is 2 then 7.2.0 is superior to php version
        phpNumVersion=`echo $phpVersion | sed 's/php-//'`
        vercomp 7.2.0 $phpNumVersion

        # Versions >=7.2 need recent icu
        if test $? == 2; then
            echo "Use recent icu4c"
            export PATH="/usr/local/opt/icu4c/bin:$PATH"
            export PATH="/usr/local/opt/icu4c/bin:$PATH"
            export PATH="/usr/local/opt/icu4c@$icuVersion/sbin:$PATH"
            export LDFLAGS=' -L/usr/local/opt/icu4c/lib'
            export CPPFLAGS=' -DU_USING_ICU_NAMESPACE=1 -I/usr/local/opt/icu4c/include'
            export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig"
        else
            # Versions before 7.1 needs older icu
            icuVersion="64.2"
            echo "Switch to icu4c $icuVersion"
            install_old_brew_package icu4c $icuVersion
            export PATH="/usr/local/opt/icu4c@$icuVersion/bin:$PATH"
            export PATH="/usr/local/opt/icu4c@$icuVersion/sbin:$PATH"
            export LDFLAGS=" -L/usr/local/opt/icu4c@$icuVersion/lib"
            export CPPFLAGS=" -DU_USING_ICU_NAMESPACE=1 -I/usr/local/opt/icu4c@$icuVersion/include"
            export PKG_CONFIG_PATH="/usr/local/opt/icu4c@$icuVersion/lib/pkgconfig"
        fi
        # Necessary for PHP 5.6 maybe not for 7+
        export CXXFLAGS=' -std=c++11 -stdlib=libc++'

        # Clean before install in case a previous build is still present
        echo Purge previous build
        phpbrew purge $lastInstalledVersion

        phpbrew install -j 4 $lastInstalledVersion +default +intl +iconv=/usr/local/opt/libiconv +mysql +apxs2 +soap +fileinfo +mbstring +bz2=/usr/local/opt/bzip2 +zlib=/usr/local/opt/zlib
        if test $? -ne 0; then
            echo Error: could not build $lastInstalledVersion
            continue
        fi
        echo Reload zshrc to update path
        source ~/.zshrc
        echo Switch to $lastInstalledVersion
        phpbrew use $lastInstalledVersion
        if [[ $lastInstalledVersion == php-7* ]]; then
            phpbrew ext install xdebug
            phpbrew ext install apcu
        fi
        phpbrew ext install gd \
            -- --with-gd=shared \
            --enable-gd-native-ttf \
            --with-jpeg-dir=/usr/local/opt/libjpg/ \
            --with-png-dir=/usr/local/opt/libpng/ \
            --with-zlib-dir=/usr/local/opt/zlib/

        # Add default PHP config
        phpIniFile="~/.phpbrew/php/$lastInstalledVersion/etc/php.ini"
        phpIniDistFile="$BASEDIR/../php/php.ini.dist"
        echo `pwd` $BASEDIR
        echo "Append $phpIniDistFile to $phpIniFile"
        cat $phpIniDistFile >> $phpIniFile

        # Add default xdebug config
        xdebugIniFile="~/.phpbrew/php/$lastInstalledVersion/var/db/xdebug.ini"
        xdebugIniDistFile="$BASEDIR/../php/xdebug.ini.dist"
        echo "Append $xdebugIniDistFile to $xdebugIniFile"
        cat xdebugIniDistFile >> $xdebugIniFile

        # Clean after build
        phpbrew clean $lastInstalledVersion
    else
        echo "PHP version $phpVersion already installed"
    fi
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
