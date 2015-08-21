#!/bin/bash

# Script to automate the setup of a new WP project
# Author: Troy McGinnis
# Updated: August 21, 2015
# URL: troymcginnis.com
# Usage: wp_init.sh [-scrdbwtvo] project-name

# TODO: Automate setting up Sage Theme:
#           - change Sage title
#           - activate Sage

install_wp ()
{
    printf "Installing WP...\n"

    # Move into directory
    cd $PROJECT

    if $DEBUG
        then
            ~/install-updated.sh
        else
            ~/install-updated.sh &> /dev/null
        if [ ! $? -eq 0 ]
            then
                printf '\nFailed to install WP!\n' ; exit 1;
        fi
    fi
}

wp_config ()
{
    printf "Editing WP config...\n"

    # Let's edit that wp-config file
    perl -pi -e "s/database_name_here/${DB_NAME}_wp/g" wp-config.php
    perl -pi -e "s/username_here/root/g" wp-config.php
    perl -pi -e "s/password_here/root/g" wp-config.php

    echo "define('WP_ENV', 'development');" >> wp-config.php
}

create_database()
{
    printf "Create database...\n"
    if $DEBUG
        then
            /Applications/MAMP/Library/bin/mysql --host=localhost -uroot -proot -e "create database ${DB_NAME}_wp"
        else
            /Applications/MAMP/Library/bin/mysql --host=localhost -uroot -proot -e "create database ${DB_NAME}_wp" &> /dev/null
    fi

    if [ $? -ne 0 ]
        then
            printf "\nFailed to create database. Chances are that the database exists.\n"
    fi
}

sage_theme ()
{
    printf "Installing Sage Theme...\n"

    THEME_DIR=wp-content/themes/
    FILE="master.zip"
    EXTRACTED_DIR="sage-master"

    if [ ! -d $THEME_DIR ]
        then
            echo "Directory does not exist."
            exit
    fi

    cd $THEME_DIR

    if $DEBUG
        then
            wget -P $TEMP_DIR https://github.com/roots/sage/archive/$FILE
        else
            wget -P $TEMP_DIR https://github.com/roots/sage/archive/$FILE &> /dev/null
    fi
    if [ $? -ne 0 ]
        then
           echo "ERROR: wget Failed!"
           exit
    fi
    if [ ! -f ${TEMP_DIR}${FILE} ]
        then
        echo "ERROR: wget Failed! No file found."
        exit
    fi

    if $DEBUG
        then
            unzip ${TEMP_DIR}${FILE}
        else
            unzip ${TEMP_DIR}${FILE} &> /dev/null
    fi

    mv $EXTRACTED_DIR $PROJECT

    # Do some Sage specific stuff
    cd $PROJECT

    # Install Bower requirements
    printf "Installing bower requirements...\n"
    if $DEBUG
        then
            bower install
        else
            bower install &> /dev/null
    fi

    # Install npm requirements
    printf "Installing npm requirements...\n"
    if $DEBUG
        then
            npm install
        else
            npm install &> /dev/null
    fi

    # Try installing npm again incase it failed
    printf "Double checking...\n"
    if $DEBUG
        then
            npm install
        else
            npm install &> /dev/null
    fi

    # Compile all the gulp files
    printf "Compile da files...\n"
    if $DEBUG
        then
            gulp
        else
            gulp &> /dev/null
    fi

    # Change the manifest for BrowserSync (change this to what you use in your dev environment)
    printf "Changing the manifest.json...\n"
    perl -pi -e "s/example.dev/localhost:8888/g" /assets/manifest.json

    clear_tmp
}

soil ()
{
    FILE="master.zip"

    if $DEBUG
        then
            wget -P $TEMP_DIR https://github.com/roots/soil/archive/$FILE
        else
            wget -P $TEMP_DIR https://github.com/roots/soil/archive/$FILE &> /dev/null
    fi

    cd ${WP_ROOT_DIR}/wp-content/plugins

    if $DEBUG
        then
            unzip ${TEMP_DIR}${FILE}
        else
            unzip ${TEMP_DIR}${FILE} &> /dev/null
    fi

    clear_tmp
}

clear_tmp ()
{
    rm -rf ${TEMP_DIR}/*
}

# Create Bit Bucket repo and init
create_bitbucket ()
{
    printf "Creating Git repo...\n"
    if $DEBUG
        then
            RESPONSE=$(bitbucket_init $PROJECT)
            echo $RESPONSE
        else
            RESPONSE=$(bitbucket_init $PROJECT) &> /dev/null
        if [ ! $? -eq 0 ]
            then
                printf '\nFailed to create Git repo!\n' ; exit 1;
        fi
        if echo "$RESPONSE" | grep -q '{"error":'
            then
                printf '\nFailed to create Git repo!\n' ; exit 1;
        fi
    fi
}

# ------ DO STUFF ------ #

source ~/.bash_profile

PROJECT=$2
WP_ROOT_DIR=$(pwd)/${PROJECT}
DB_NAME=$(echo $PROJECT | tr - _)
TEMP_DIR="/tmp/sage-tmp/"

while getopts "scrdbwtvo" arg
do
    case $arg in
        r)
            SAGE=true
           ;;
        s)
            SAGE=true
	       ;;
    	v)
    	    DEBUG=true
    	    ;;
    	d)
    	    create_database
    	    exit
    	    ;;
    	b)
    	    create_bitbucket
    	    exit
    	    ;;
    	w)
    	    install_wp
    	    exit
    	    ;;
    	c)
    	    wp_config
    	    exit
    	    ;;
    	t)
    	    sage_theme
    	    exit
    	    ;;
        o)
            soil
            exit
            ;;
    esac
done

shift $(($OPTIND - 1))

PROJECT=$1
DB_NAME=$(echo $PROJECT | tr - _)
SAGE=${SAGE:-false}
DEBUG=${DEBUG:-false}

# Check for project name
if [ -z $PROJECT ]
    then
        echo "Please provide a project name."
        exit
fi

# Feedback
printf "\nCreating new WP project for $1:\n\n"

# Create Bit Bucket
create_bitbucket

# Install latest version of WP
install_wp

# Edit wp-config
wp_config

# Create Database
create_database

# Install Roots Theme
if $SAGE
    then
	sage_theme
    soil
fi
