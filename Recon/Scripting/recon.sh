#!/bin/bash
source ./scan.lib

while getopts "m:i" OPTION; do
    case $OPTION in
        m)
            MODE=$OPTARG
        ;;
        i)
            INTERACTIVE=true
        ;;
        *)echo "error" >&2
            exit 1
    esac
done

scan_domain()
{
    DOMAIN=$1
    DATE=$(date +"%Y-%m-%d")
    # DATE=$(date +"%Y-%m-%d_%H-%M-%S")
    DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
    OUTPUT_FILE=${DOMAIN}_${DATE}.txt
    
    echo "Creating directory $DOMAIN."
    mkdir -p $DOMAIN
    echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
    mkdir -p $DIRSEARCH_DIRECTORY
    touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
    
    case $MODE in
        nmap-only)
            nmap_scan``
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
}

report_domain()
{
    DOMAIN=$1
    DATE=$(date +"%Y-%m-%d")
    
    echo "Generating Recon report from output file(s)."
    echo "This scan was created on $DATE > $DOMAIN/report."
    if [ -f $DOMAIN/nmap ]; then
        echo "Results for Nmap:" >> $DOMAIN/report
        grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DOMAIN/nmap >> $DOMAIN/report
    fi
    
    if [ -s $DOMAIN/dirsearch/$OUTPUT_FILE ]; then
        echo "Results for Dirsearch:" >> $DOMAIN/report
        cat $DOMAIN/dirsearch/$OUTPUT_FILE >> $DOMAIN/report
    fi
    
    if [ -f $DOMAIN/crt ]; then
        echo "Results for crt.sh:" >> $DOMAIN/report
        jq -r ".[] | .name_value" $DOMAIN/crt >> $DOMAIN/report
    fi
}

if [ $INTERACTIVE ];then
    INPUT="BLANK"
    while [ $INPUT != "quit" ];do
        echo "Please enter a domain!"
        read INPUT
        if [ $INPUT != "quit" ];then
            scan_domain $INPUT
            report_domain $INPUT
        fi
    done
else
    for i in "${@:$OPTIND:$#}";do
        scan_domain $i
        report_domain $i
        
    done
fi