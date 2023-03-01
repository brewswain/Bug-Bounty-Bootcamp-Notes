#!/bin/bash
DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
CRT_DIRECTORY=$DOMAIN/crt
MASTER_REPORT_DIRECTORY=$DOMAIN/report
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"
echo "Creating Master Report subdirectory"
mkdir $MASTER_REPORT_DIRECTORY

nmap_scan()
{
    nmap $DOMAIN > $DOMAIN/nmap
    echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}
dirsearch_scan()
{
    
    dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
    echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
}
crt_scan()
{
    curl "https://crt.sh/?q=$DOMAIN&output=json" -o $CRT_DIRECTORY
    echo "The results of cert parsing is stored in $CRT_DIRECTORY."
}

case $2 in
    nmap-only)
        nmap_scan
    ;;
    dirsearch-only)
        dirsearch_scan
    ;;
    crt-only)
        crt_scan
    ;;
    *)
        nmap_scan
        dirsearch_scan
        crt_scan
    ;;
esac

echo "Generating Recon report from output file(s)."
echo "This scan was created on $DATE > $DIRECTORY/report."
echo "Results for Nmap:" >> $DIRECTORY/report
grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
echo "Results for Dirsearch:" >> $DIRECTORY/report
cat $DIRECTORY/dirsearch >> $DIRECTORY/report
echo "Results for crt.sh:" >> $DIRECTORY/report
jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report