#!/bin/bash
echo "Creating directory $1_recon." 1
mkdir $1_recon 2
nmap $1 > $1_recon/nmap 3
echo "The results of nmap scan are stored in $1_recon/nmap."
dirsearch -u $1 -e php 4 --simple-report=$1_recon/dirsearch
echo "The results of dirsearch scan are stored in $1_recon/dirsearch."