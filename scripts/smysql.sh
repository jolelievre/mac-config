#!/bin/sh

script=`basename "$0"`

# Display Usage
mysqlVersions=`ls /usr/local/opt/ | grep mysql@ | sed s_mysql@__g`
if [ $# -ne 1 ]; then
    echo "Usage: $script {mysql_version}"
    echo
    echo "Allowed versions:"
    echo $mysqlVersions
    exit 0
fi

# Check asked mysql version
mysqlVersion=$1
matchedVersion=0
for validVersion in $mysqlVersions; do
    if [ $validVersion = $mysqlVersion ]; then
        matchedVersion=1
        break;
    fi
done

if [ $matchedVersion -ne 1 ]; then
    echo "Unsupported mysql version: $mysqlVersion"
    echo "Allowed versions:"
    echo $mysqlVersions
    exit 1
fi

for stoppedMysqlVersion in $mysqlVersions; do
  echo Stopping Mysql $stoppedMysqlVersion
  brew services stop mysql@$stoppedMysqlVersion
  brew unlink mysql@$stoppedMysqlVersion
done

brew link --force --overwrite mysql@$mysqlVersion
brew services start mysql@$mysqlVersion
brew services restart mysql@$mysqlVersion
