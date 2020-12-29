#!/bin/sh

# The following steps come from this tutorial
# https://getgrav.org/blog/macos-mojave-apache-multiple-php-versions

if test ! -d /usr/local/Cellar/openldap; then
    echo Install openldap dependency
    brew install openldap
fi

if test ! -d /usr/local/Cellar/libiconv; then
    echo Install libiconv dependency
    brew install libiconv
fi

echo Uninstall pre installed apache
sudo apachectl stop
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist

if test ! -f /usr/local/bin/httpd; then
    echo Install Apache with brew
    brew install httpd
fi

echo Prepare server directory and files
mkdir -p ~/www/var/logs
cat >~/www/index.html <<EOL
<html>
    <head>
        <title>$USER local server</title>
    </head>
    <body>
        <h1>$USER local server</h1>
        <h2>Local directory $HOME/www</h2>
    </body>
</html>
EOL

cat >~/www/info.php <<EOL
<?php
    phpinfo();

EOL

# Stop apache service after installation with brew
sudo brew services stop httpd

BASEDIR=$(dirname "$0")
USERNAME=$(users)

echo Prepare Apache default config
sed "s+{USERNAME}+$USERNAME+" $BASEDIR/../apache/httpd.conf > /usr/local/etc/httpd/httpd.conf
if test ! -d /usr/local/etc/httpd/extra/sites-available; then
    mkdir -p /usr/local/etc/httpd/extra/sites-available
fi
if test ! -d /usr/local/etc/httpd/extra/sites-enabled; then
    mkdir -p /usr/local/etc/httpd/extra/sites-enabled
fi

echo Prepare Apache default Vhost
sed "s+{USERNAME}+$USERNAME+" $BASEDIR/../apache/extra/httpd-vhosts.conf > /usr/local/etc/httpd/extra/httpd-vhosts.conf

echo Test config
apachectl -t || exit 1

echo Set Apache to start automatically
# This one to set automatic boot of apache
sudo brew services start httpd
# This one to make sure it restarts and works fine
sudo brew services restart httpd

echo Apache is running you can access it through the address:
echo http://localhost
echo
