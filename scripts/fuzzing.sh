#!/bin/bash

# PARAMS
#	1 - [required] File w url(s) to fuzz (LINE: <PROTOCOL>:<url/host> -- http://10.10.19.168 -- https://examplesite.com)
#	2 - [required] Intensity Level
#	3 - [required] WorkDir PATH
# 	4 - [required] Cookie(s) -- "PHPSESSID=123,PHPTOKEN=345". Empty string allowed.
#	5 - [required] Header Authorization VALUE (Bearer|JWT|BasicAuth) -- "Bearer: eY.." OR "Basic base64passwd". Empty string allowed.

# FUNCTIONS
function check_requirements { # FILES EXISTENCE & ARGS (except level)

	[[ ! $NUMARGS -eq 5 ]] && printError "$Script: Incorrect Arguments"

	[[ -f "$URLFILE" ]] || printError "$Script: No such $URLFILE url file"

	[[ -d "$WORKDIR" ]] || printError "$Script: No such $WORKDIR workdir folder"

	[[ -z $COOKIE && -z $AUTHHEADER ]] && AUTH=0 || AUTH=1
} 

function fuzzingscan {

	check_requirements
	declare_globals
	printInfo "Starting fuzzing process" 0
	printInfo "This is to retrieve new paths from URLs found by scanning/discovery process" 1
	startwfuzzprocess=`date +%s`


    if [ -d "$FUZZINGFOLDER" ]; then
        rm -rf $FUZZINGFOLDER
        mkdir $FUZZINGFOLDER
    else
        mkdir $FUZZINGFOLDER
    fi

	if [[ $AUTH -eq 1 ]]; then
		if [[ (! -z $COOKIE) && (! -z $AUTHHEADER) ]]; then
			FUZZ_AUTH=(-H "Cookie:'$AUTHHEADER'" -H "Authorization:'$AUTHHEADER'")
		elif [[ ! -z $COOKIE ]]; then
			FUZZ_AUTH=(-H "Cookie:'$COOKIE'")
		elif [[ ! -z $AUTHHEADER ]]; then
			FUZZ_AUTH=(-H "Authorization:'$AUTHHEADER'")
		fi
	else
		FUZZ_AUTH=()
	fi

	for dict in "${DICTS[@]}"; do
		for i in $(cat $URLFILE|grep $*/); do
			printInfo "Executing WFUZZ | url: $i | dict: $dict" 2
			wfuzz ${FUZZ_AUTH[@]} --conn-delay 10 --req-delay 10 --efield url -t 50 --filter "$FUZZFILTER" -w "$DICTFOLDER/$dict" --zE urlencode -f $FUZZINGFOLDER/$(echo $i | sed 's/\//-/g' | sed 's/:/-/g')-$dict -L $i"FUZZ{asdfnottherexxxasdf}" &>> "$DEBUGFOLDER/wfuzz-output-$dict"
			
			totalreq=$(cat $FUZZINGFOLDER/$(echo $i | sed 's/\//-/g' | sed 's/:/-/g')-$dict | grep "Total requests:" | awk -F":" '{print $2}' | sed 's/^ //g')
			processedreq=$(cat $FUZZINGFOLDER/$(echo $i | sed 's/\//-/g' | sed 's/:/-/g')-$dict | grep "Processed Requests:" | awk -F":" '{print $2}' | sed 's/^ //g')
			if [[ `expr $(expr $totalreq + 1) - $processedreq` -gt 0  ]]; then 
				echo -e "\e[33m[WARNING] - Found an error in $i URL. Review debug folder to see the error\e[0m"
			fi
		done
	done

	cat $FUZZINGFOLDER/*.txt | grep http | sed 's/.* C=//g' | sed 's/ .*|//g' | sed 's/"$//g' | grep -v "^Target: " | grep -v 404 |  sort -u | uniq -u > $OUTFOLDER/fuzzing-results.txt


	endwfuzzprocess=`date +%s`
	printInfo "Ended wfuzz process" 1
	displaytime `expr $endwfuzzprocess - $startwfuzzprocess`
	printInfo "Execution time of wfuzz process was$timecalc." 0
}


# VARS

NUMARGS=$# 
Script=$0
URLFILE=$1
LEVEL=$2
WORKDIR=$3
COOKIE=$4
AUTHHEADER=$5
FUZZFILTER="not (c=BBB and l=BBB and w=BBB)"

source "$(dirname "$0")/env.sh" # IMPORT METHODS

fuzzingscan