#!/bin/bash

# PARAMS
#	1 - [required] HOST url
#	2 - [required] Intensity Level
#	3 - [require]d] WorkDir PATH
# 	4 - [optional] Auth_Cookie_String
#	

function execute_nikto {
	# hosturl
	# outfolder
	# auth
	rm -f $OUTFOLDER/nikto-results.txt &> /dev/null
	printInfo "Executing -- nikto -host $HOSTURL -o 'nikto-results.txt' -Tuning 0,1,3,5,7,8,a,b,c" 2
	nikto -host $HOSTURL -o "$OUTFOLDER/nikto-results.txt" ${NIKTO_AUTH[@]} -Tuning 0,1,3,5,7,8,a,b,c > $OUTFOLDER/nikto-results.out
}

function execute_cmseek {
	# host
	# workdir
	
	CMSEEKFOLDER="$OUTFOLDER/cmseek"
	if [ -d "$CMSEEKFOLDER" ]; then
        rm -rf $CMSEEKFOLDER
        mkdir $CMSEEKFOLDER
    else
        mkdir $CMSEEKFOLDER
    fi

	printInfo "Executing -- cmseek -u $HOSTURL --skip-scanned --follow-redirect --batch -r" 2
	savepath=`pwd -P`
	cd $CMSEEKFOLDER && cmseek -u $HOSTURL --skip-scanned --follow-redirect --batch -r > "$CMSEEKFOLDER/cmseek.out"
	cd $savepath
}

function execute_xsrfprobe {
	# hosturl
	# workdir
	# auth
	
	XSRFPROBE="$OUTFOLDER/xsrfprobe.txt"

	printInfo "Executing -- xsrfprobe -u $HOSTURL -o "xsrfprobe.txt" --crawl --random-agent" 2
	xsrfprobe -u $HOSTURL -o "$OUTFOLDER/xsrfprobe.txt" --crawl --random-agent ${COOKIE_AUTH[@]} > "$OUTFOLDER/xsrfprobe.out"
}

function execute_httpx {
	# hosturl
	# workdir
	
	printInfo "Executing -- httpx -u $HOSTURL -server -td -websocket -ip -asn -cdn -json" 2
	httpx -u $HOSTURL -server -td -websocket -ip -asn -cdn -json -o "$OUTFOLDER/httpx.json" ${COOKIE_AUTH[@]} > "$OUTFOLDER/httpx.out"
}

function execute_jsvulnerabilities {
	# hosturl
	# workdir
	
	JSVULNERABILITIES_OUTPUT='output/js_vulns.json'

	printInfo "Executing -- is-website-vulnerable $HOSTURL --json --js-lib -o 'JSvulns.json'" 2
	
	docker ps &> /dev/null || printError "No docker available"
	docker run --rm lirantal/is-website-vulnerable:latest $HOSTURL --json --js-lib ${COOKIE_AUTH[@]} > "$OUTFOLDER/JSvulns.json"
}

function correct_base64 {
	# base64
	base64=$1
	
	len=$((${#base64} % 4))
	
	if [ $len -eq 2 ]; then result="$base64"'=='
    elif [ $len -eq 3 ]; then result="$base64"'=' 
    fi

	echo "$base64" | tr '_-' '/+' | openssl enc -d -base64
}

function decode_jwt {
	# cookie
	COOKIE=$1
	
	jwt=$(echo $COOKIE | cut -d "=" -f 2-)
	
	header=$(correct_base64 $(echo -n $jwt | cut -d "." -f -1))
	body=$(correct_base64 $(echo -n $jwt | cut -d "." -f 2))
	
	echo -e "Header:  $heade\nBody:  $bodyr" > $OUTDIR/
	echo -e 
}


function check_requirements { # FILES EXISTENCE & ARGS (except level)
	
	[[ ! $NUMARGS -eq 5 ]] && printError "$Script: Incorrect Arguments"

	[[ -z "$HOSTURL" ]] && printError "$Script: HOST is empty"

	[[ -d "$WORKDIR" ]] || printError "$Script: No such $WORKDIR workdir folder"

	[[ -z $AUTH_STRING ]] && AUTH=0 || AUTH=1
}

function standalone_execution {

	check_requirements
	declare_globals

	if [[ $AUTH -eq 1 ]]; then
		NIKTO_AUTH=(-O STATIC-COOKIE="$AUTH_STRING")
		COOKIE_AUTH=(-H "Cookie: $AUTH_STRING")
		JS_COOKIE=(--cookie $AUTH_STRING)
	else
		NIKTO_AUTH=()
		COOKIE_AUTH=()
		JS_COOKIE=()
	fi

#	if [[ $LEVEL -gt 1 ]]; then
		
#	else
		
#	fi

	printInfo "Starting standalone tools execution process" 0
	printInfo "This will run NIKTO, CMSEEK, XSRFPROBE, HTTPX, JSVULNS..." 1
	startstandprocess=`date +%s`

	execute_nikto
	execute_cmseek
	execute_xsrfprobe
	execute_httpx
	execute_jsvulnerabilities

	endstandprocess=`date +%s`
	printInfo "Ended tools execution process" 1		
	displaytime `expr $endstandprocess - $endstandprocess`
	printInfo "Execution time of standalone tools process was$timecalc." 0
}

# VARS
NUMARGS=$# 
Script=$0
HOSTURL=$1
LEVEL=$2
WORKDIR=$3
AUTH_STRING=$4

source "$(dirname "$0")/env.sh" # IMPORT METHODS
standalone_execution


