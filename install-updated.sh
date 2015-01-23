#!/bin/bash

#
# Script to download and install the latest version of WordPress
#
# Author: Troy McGinnis
# Updated: Oct 11, 2013
# URL: troymcginnis.com  
#

DIRECTORY='/tmp/wordpress-tmp/'
FILE='latest.zip'

if [ ! -d $DIRECTORY ]
  then
    mkdir $DIRECTORY
fi

if [ -f ${DIRECTORY}${FILE} ]
  then
    rm -rf ${DIRECTORY}${FILE}
fi

wget -P $DIRECTORY http://wordpress.org/$FILE
if [ $? -ne 0 ]
  then
    echo "ERROR: wget Failed!"
    exit
fi
if [ ! -f ${DIRECTORY}${FILE} ]
  then
    echo "ERROR: wget Failed! No file found."
    exit
fi

unzip ${DIRECTORY}${FILE}
if [ $? -ne 0 ]
  then
    echo "ERROR: unzip Failed!"
    exit
fi

mv ./wordpress/* .
rmdir ./wordpress

mv wp-config-sample.php wp-config.php
if [ $? -ne 0 ]
  then
    echo "WARNING: Failed to rename configuration file. Please try manually."
fi

echo "SUCCESS: Done!"
echo "Just edit wp-config.php to include database info. BAM."
exit

echo "ERROR: Install Failed!"
