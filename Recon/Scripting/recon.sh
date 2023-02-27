#!/bin/bash

DOMAIN=$1
DIRECTORY=${DOMAIN}_recon


echo "Creating directory $DIRECTORY."
mkdir $DIRECTORY
nmap $DOMAIN > $DIRECTORY/nmap
echo "The results of nmap scan are stored in $DIRECTORY/nmap."
dirsearch -u $DOMAIN -e php -–simple-report=$DIRECTORY/dirsearch
echo "The results of dirsearch scan are stored in $DIRECTORY/dirsearch."