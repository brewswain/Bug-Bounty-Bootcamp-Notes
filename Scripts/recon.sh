#!/bin/bash

DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
CRT_DIRECTORY=$DOMAIN/crt
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"

case $2 in
    nmap-only)
        nmap $DOMAIN > $DOMAIN/nmap
        echo "The results of nmap scan are stored in $DIRECTORY/nmap."
    ;;
    dirsearch-only)
        dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
        echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
    ;;
    crt-only)
    ;;
    *)
        nmap $DOMAIN > $DOMAIN/nmap
        echo "The results of nmap scan are stored in $DIRECTORY/nmap."
        dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
        echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
        curl "https://crt.sh/?q=$DOMAIN&output=json" -o $CRT_DIRECTORY
        echo "The results of cert parsing is stored in $CRT_DIRECTORY."
    ;;
esac