#!/bin/bash

# PARAMS
#	1 - [required] HOST url
#	2 - [required] Intensity Level
#	3 - [require]d] WorkDir PATH
# 	4 - [required] Cookie(s) -- "PHPSESSID=123,PHPTOKEN=345". Empty string allowed.
#	5 - [required] Header Authorization VALUE (Bearer|JWT|BasicAuth) -- "Bearer: eY.." OR "Basic base64passwd". Empty string allowed.
#	

# VARS


NUMARGS=$# 
Script=$0
HOST=$1
LEVEL=$2
WORKDIR=$3
COOKIE=$4
AUTHHEADER=$5

source "$(dirname "$0")/env.sh" # IMPORT METHODS


# FUNCTIONS
function check_requirements { # FILES EXISTENCE & ARGS (except level)
	
	[[ ! $NUMARGS -eq 5 ]] && printError "$Script: Incorrect Arguments"

	[[ -z "$HOST" ]] && printError "$Script: HOST is empty"

	[[ -d "$WORKDIR" ]] || printError "$Script: No such $WORKDIR workdir folder"

	[[ -z $COOKIE && -z $AUTHHEADER ]] && AUTH=0 || AUTH=1
}

function run_sqlmap {
	#TODO: include proxy option / CSRF token

    check_requirements
	declare_globals
	printInfo "Starting SQLmap process" 0
	printInfo "This will crawl the website and try SQL injection over discovered endpoints..." 1
	startsqlmapprocess=`date +%s`


	if [[ $AUTH -eq 1 ]]; then
		if [[ (! -z $COOKIE) && (! -z $AUTHHEADER) ]]; then
			SQLMAP_AUTH=(--cookie=$COOKIE -H "Authorization:'$AUTHHEADER'")
		elif [[ ! -z $COOKIE ]]; then
			SQLMAP_AUTH=(--cookie=$COOKIE)
		elif [[ ! -z $AUTHHEADER ]]; then
			SQLMAP_AUTH=(-H "Authorization:'$AUTHHEADER'")
		fi
	else
		SQLMAP_AUTH=()
	fi

	if [[ $LEVEL -gt 1 ]]; then
		SQLMAP_LEVEL=(--level=4 --risk 3)
	else
		SQLMAP_LEVEL=(--level=3 --risk 2)
	fi

	SQLMAPFOLDER="$OUTFOLDER/sqlmap"
	if [ -d "$SQLMAPFOLDER" ]; then
        rm -rf $SQLMAPFOLDER
        mkdir $SQLMAPFOLDER
    else
        mkdir $SQLMAPFOLDER
    fi

	SQLMAP_CRAWL=(--crawl=10 --crawl-exclude="logout|signoff" --forms)
    SQLMAP_ARGS=(--batch --random-agent --flush-session --threads=10 -answers="crawling=Y,sitemap=Y")
	SQLMAP_OUTPUT=(--output-dir="$SQLMAPFOLDER")

	printInfo "Executing... sqlmap -u $HOST ${SQLMAP_ARGS[*]} ${SQLMAP_CRAWL[*]} ${SQLMAP_LEVEL[*]}" 2
	sqlmap -u "$HOST" ${SQLMAP_AUTH[@]} ${SQLMAP_LEVEL[@]} ${SQLMAP_CRAWL[@]} ${SQLMAP_ARGS[@]} ${SQLMAP_OUTPUT[@]} > $SQLMAPFOLDER/sqlmap.out

	endsqlmapprocess=`date +%s`
	printInfo "Ended SQLmap process" 1
	displaytime `expr $endsqlmapprocess - $startsqlmapprocess`
	printInfo "Execution time of SQLmap process was$timecalc." 0
}


run_sqlmap