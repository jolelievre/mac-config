#!/bin/sh

script=`basename "$0"`
phpConfFolder=`php --ini | grep 'Scan for additional .ini files in: ' | sed 's_.*in: __'`
xdebugFile=$phpConfFolder/xdebug.ini
xdebugBackupFile=$phpConfFolder/xdebug.ini.bac

if [ "$1" = 'on' ]; then
  echo Enable Xdebug
  if [ -f $xdebugFile ]; then
    echo Xdebug already enabled
  elif [ -f $xdebugBackupFile ]; then
    mv $xdebugBackupFile $xdebugFile
    echo Xdebug was turned on back again
    sudo apachectl restart
  else
    echo No xdebug config was found
  fi 
else
  echo Disable Xdebug
  if [ ! -f $xdebugFile ]; then
    echo Xdebug already disabled
  elif [ -f $xdebugFile ]; then
    mv $xdebugFile $xdebugBackupFile
    echo Xdebug was turned off, config is saved at $xdebugBackupFile
    sudo apachectl restart
  else
    echo No xdebug config was found
  fi
fi
