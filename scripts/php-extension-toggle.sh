#!/bin/sh

script=`basename "$0"`

if [ $# -lt 2 ]; then
  echo Missing arguments: $script on/off php-extension
  exit 1
fi

phpExtension=$2


phpConfFolder=`php --ini | grep 'Scan for additional .ini files in: ' | sed 's_.*in: __'`

extensionFile=$phpConfFolder/$phpExtension.ini
extensionBackupFile=$phpConfFolder/$phpExtension.ini.bac

if [ "$1" = 'on' ]; then
  echo Enable php extension $phpExtension
  if [ -f $extensionFile ]; then
    echo $phpExtension already enabled
  elif [ -f $extensionBackupFile ]; then
    mv $extensionBackupFile $extensionFile
    echo $phpExtension was turned on back again
    sudo apachectl restart
  else
    echo No $phpExtension config was found
  fi 
else
  echo Disable php extension $phpExtension
  if [ ! -f $extensionFile ]; then
    echo $phpExtension already disabled
  elif [ -f $extensionFile ]; then
    mv $extensionFile $extensionBackupFile
    echo $phpExtension was turned off, config is saved at $extensionBackupFile
    sudo apachectl restart
  else
    echo No $phpExtension config was found
  fi
fi
