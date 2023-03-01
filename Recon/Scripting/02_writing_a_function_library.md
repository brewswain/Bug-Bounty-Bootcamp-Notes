## Writing a Function Library

Codebases naturally get larger and more awkward. So let's make a library file!
for this let's call it `scan.lib`:

```
#!/bin/bash
source ./scan.lib

while getopts "m:" OPTION; do
    case $OPTION in
        m)MODE=$OPTARG
        ;;
        *)echo "error" >&2
            exit 1
    esac
done

for i in "${@:$OPTIND:$#}"
do
    echo "beginning operations for $i."
    DOMAIN=$i
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
done
```

Nice.
