#!/usr/bin/env bash


echo  "
__        ______    ____                 _     _                       
\ \      / /  _ \  |  _ \ _ __ _____   _(_)___(_) ___  _ __   ___ _ __ 
 \ \ /\ / /| |_) | | |_) | '__/ _ \ \ / / / __| |/ _ \| '_ \ / _ \ '__|
  \ V  V / |  __/  |  __/| | | (_) \ V /| \__ \ | (_) | | | |  __/ |   
   \_/\_/  |_|     |_|   |_|  \___/ \_/ |_|___/_|\___/|_| |_|\___|_| 
"



read -p "Enter Domain Name for your DEV environment: " DOMAIN
echo " "

if test "$DOMAIN" == ""; then
	echo "$0: Domain is required " >&2
	exit 1;
fi



read -p "Enter repository URL (Enter for none) " REPO
echo " "

if test "$REPO" != ""; then
	echo "Cloning Project Repository"
	git clone --recursive $REPO document_root
else
	mkdir document_root
fi

echo "Installing latest version of wordpress"
git clone --depth=1 git@github.com:WordPress/WordPress.git document_root/wp

read -p "Enter Database Name: " DBNAME
echo " "

read -p "Enter Database User: " DBUSER
echo " "

read -p "Enter Database Password: " DBPASS
echo " "

cat <<EOF | tee config.sh
BOX_IP="192.168.50.6"
DOMAIN="$DOMAIN"
MYSQL_ROOT_PASS="root"
DATABASE_NAME="$DBNAME"
DATABASE_USER="$DBUSER"
DATABASE_PASSWORD="$DBPASS"
EOF

cat <<EOF | tee document_root/local-config.php
<?php

@define('WP_DEBUG', false);

//@define('CFCT_DEBUG', true);

/** Support for subdirectory installation */

@define('WP_SITEURL', 'http://$DOMAIN/wp');
@define('WP_HOME', 'http://$DOMAIN');

@define('WP_CONTENT_URL', WP_HOME.'/wp-content');
@define('WP_CONTENT_DIR', dirname(__FILE__).'/wp-content');
 
@define('WP_MEMORY_LIMIT', '128M');
@define('WP_POST_RFEVISIONS', 50);

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
@define('DB_NAME', '$DBNAME');

/** MySQL database username */
@define('DB_USER', '$DBUSER');

/** MySQL database password */
@define('DB_PASSWORD', '$DBPASS');

/** MySQL hostname */
@define('DB_HOST', 'localhost');
EOF

echo "Creating data directory."
mkdir data
echo "
---------------------------------------------------------------------------------
|                                                                               |
|   Remember to place a database_dump.sql file in data/ for a development DB    |
|                                                                               |
---------------------------------------------------------------------------------
"

