#!/bin/bash

# PARAMS
#	1 - [required] Domain
#	2 - [required] Intensity Level
#	


 

# VARS

DNSFOLDER="./dns"
Script=$0
DOMAIN=$1
LEVEL=$2
COOKIE=$3

source "$(dirname "$0")/env.sh" # IMPORT METHODS
declare_globals	$LEVEL		 	# DECLARE GLOBAL VARS	  

function check_requirements () { # FILES EXISTENCE & ARGS (except level)
	
	if [[ $# -ne 2 ]]; then
    	print_error("$Script: Incorrect Arguments")
	fi

} 

function dnsscan() {
	echo -e "\e[32m--------- Starting dns scan process\e[0m"
	echo "This is to retrieve dns related version and information"
	startdnsprocess=`date +%s`
	dnshosts=$(cat $INTERSERVICESFOLDER/*-service.txt | grep ",53," | awk -F',' '{print $1}' | sort -u)
	cd $INTERINITFOLDER 
	if [[ "$dnshosts" != "" ]]; then
		for dnshost in $(echo $dnshosts)
		do 
			smb445hosts=$(cat $INTERSERVICESFOLDER/tcp-*-service.txt | grep $dnshost | grep ",445," | awk -F',' '{print $1}' | sort -u)
			ldap389=$(cat $INTERSERVICESFOLDER/tcp-*-service.txt | grep $dnshost | grep ",389," | awk -F',' '{print $1}' | sort -u)
			dnsnames=$(echo $(dig -x $dnshost @$dnshost | grep PTR | awk -F 'PTR' '{print $2}' | tr -d '     ' | sed 's/\.$//g' | grep [a-zA-Z0-9])","$(host $dnshost | grep -v "not found" | awk -F ' ' '{print $5}' | sed 's/\.$//g' | grep [a-zA-Z0-9]))
			if [[ "$smb445hosts" != "" ]]; then 
				dnsnames=$(echo $(crackmapexec smb $dnshost | sed -e s/.*name://g -e s/\).*\(domain:/,/g -e s/\).*//g)","$(crackmapexec smb $dnshost | sed -e s/.*name://g -e s/\).*\(domain:/./g -e s/\).*//g)","$dnsname)
			fi
			if [[ "$ldap389" != "" ]]; then
                                dnsnames=$(echo $(crackmapexec smb $dnshost | sed -e s/.*name://g -e s/\).*\(domain:/,/g -e s/\).*//g)","$(crackmapexec smb $dnshost | sed -e s/.*name://g -e s/\).*\(domain:/./g -e s/\).*//g)","$dnsnames)
			fi
			dnsnames=$(echo $dnsnames | sed 's/,/\n/g' | grep [a-zA-Z0-9] | grep -v "NXDOMAIN" | sort -u)
			if [[ "$dnsnames" != "" ]]; then
				for dnsname in $dnsnames
				do
					dnsrecon -d $dnsname -t axfr -n $dnshost > $INTERDNSFOLDER/dnsrecon/$dnshost-$dnsname-dnsrecon.txt
				done &> $INTERDEBUGFOLDER/dnsrecon-output.txt
			fi
		done
	fi
	cd ..
	enddnsprocess=`date +%s`
	echo -e "\e[32m--------- Ended dns scan process\e[0m"
        displaytime `expr $enddnsprocess - $startdnsprocess`
	echo "Execution time of dns recon process was$timecalc."
}