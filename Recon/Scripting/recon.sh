#!/bin/bash

DOMAIN=$1
DATE=$(date +"%Y-%m-%d")
DIRECTORY=${DOMAIN}_recon
DIRSEARCH_DIRECTORY=$DIRECTORY/dirsearch
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DIRECTORY."
mkdir -p $DIRECTORY
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"
nmap $DOMAIN > $DIRECTORY/nmap
echo "The results of nmap scan are stored in $DIRECTORY/nmap."
dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."