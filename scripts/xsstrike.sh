#!/bin/bash
#
# usage ./injections.sh HOST LEVEL FOLDER DEBUG AUTH PORT
#
# PARAMS
# 1 - Host to be scanned -> format [192.168.1.1, localhost, example.com]
# 2 - Scan Intensity level -> format [1, 2]
# 3 - The folder where the output folders are located -> format [ ".", "./myworkdir" ..]
# 4 - [required] Cookie(s) -- "PHPSESSID=123,PHPTOKEN=345". Empty string allowed.
#	5 - [required] Header Authorization VALUE (Bearer|JWT|BasicAuth) -- "Bearer: eY.." OR "Basic base64passwd". Empty string allowed.
# 6 - Port on which to perform HTTP tests, default is 80 -> format [ 80, 443, 8080, ..]
# 7 - Shows info on the execution (DEBUG, OUTPUT, NONE) -> format [ "NONE", "DEBUG", ..]
########## VARIABLES AND PREPARATION #############

Script=$0
HOST=$1
LEVEL=$2
WORKDIR="$(cd $3; pwd -P)"
COOKIE=$4
AUTHHEADER=$5
PORT="80"
[[ -n "$6" ]] && PORT="$6"
VERB="$7"

PARENT_FOLDER=$( cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd -P )

source "$PARENT_FOLDER"/scripts/tools.sh
source "$PARENT_FOLDER"/scripts/env.sh
declare_globals $LEVEL

[[ -z "$HOST" ]] && printError "$Script: HOST is empty"

[[ -d "$WORKDIR" ]] || printError "$Script: No such $WORKDIR workdir folder"

[[ $COOKIE == ' ' ]] && COOKIE=''
[[ $AUTHHEADER == ' ' ]] && AUTHHEADER=''
[[ -z $COOKIE && -z $AUTHHEADER ]] && AUTH=0 || AUTH=1


[[ $VERB = "INFO" ]] && echo -e "\nHOST: "$HOST""
[[ $VERB = "INFO" ]] && echo -e "WORKDIR: "$WORKDIR""
[[ $VERB = "INFO" ]] && echo -e "BASE SCRIPT FOLDER: "$PARENT_FOLDER"\n"

########### FUNCTIONS ##############

# tests for XSS injections by crawling parameters and testing them
# usage xss_scan URLS_FILE OUTPUT_FOLDER DEBUG_FOLDER
function xsstrike {

  printInfo "Starting XSStrike process" 0
  printInfo "This will crawl the website and try XSS injection over discovered endpoints..." 1
  startxsstrikeprocess=`date +%s`


	if [[ $AUTH -eq 1 ]]; then
		if [[ ( ! -z $COOKIE ) && ( ! -z $AUTHHEADER ) ]]; then
			SQLMAP_AUTH=(--cookie="$COOKIE" --header="Authorization:\'$AUTHHEADER\'")
            XSSTRIKE_AUTH=(--headers="Authorization: $AUTHHEADER\n Cookie: $COOKIE")
		elif [[ ! -z $COOKIE ]]; then
			SQLMAP_AUTH=(--cookie="$COOKIE")
            XSSTRIKE_AUTH=(--headers="Cookie: $COOKIE")
		elif [[ ! -z $AUTHHEADER ]]; then
			SQLMAP_AUTH=(--header="Authorization: '$AUTHHEADER'")
            XSSTRIKE_AUTH=(--headers="Authorization: $AUTHHEADER")
		fi
	else
        SQLMAP_AUTH=()
        XSSTRIKE_AUTH=()
	fi

  XSSTRIKEFOLDER="$OUTFOLDER/xsstrike"
  if [ -d "$XSSTRIKEFOLDER" ]; then
    rm -rf $XSSTRIKEFOLDER
    mkdir $XSSTRIKEFOLDER
  else
    mkdir $XSSTRIKEFOLDER
  fi

  printInfo "Crawling website..." 2
  SQLMAP_FORMS=($SQLMAP_AUTH --forms --crawl=5 --crawl-exclude=\"logout\|signoff\" --batch --random-agent --flush-session --answers="crawling=Y,sitemap=Y,test=N,Set-Cookie=n,store=n")
  SQLMAP_CRAWL=($SQLMAP_AUTH --crawl=5 --crawl-exclude=\"logout\|signoff\" --batch --random-agent --flush-session --answers="crawling=Y,sitemap=Y,test=N,Set-Cookie=n,store=n")
  [[ $VERB = "INFO" ]] && echo -e "Running command [ sqlmap -u "$HOST" "${SQLMAP_FORMS[@]}"  &> "$XSSTRIKEFOLDER"/sqlmapRaw.out ]"
  sqlmap -u "$HOST" ${SQLMAP_FORMS[@]}  &> $XSSTRIKEFOLDER/sqlmapRaw.out
  [[ $VERB = "INFO" ]] && echo -e "Running command [ sqlmap -u "$HOST" "${SQLMAP_CRAWL[@]}"  &>> "$XSSTRIKEFOLDER"/sqlmapRaw.out ]"
  sqlmap -u "$HOST" ${SQLMAP_CRAWL[@]}  &>> $XSSTRIKEFOLDER/sqlmapRaw.out


  # FILTER GREP
  cat $XSSTRIKEFOLDER/sqlmapRaw.out | grep -v WARN | grep GET | grep http | sort | uniq | cut -d ' ' -f2 > $XSSTRIKEFOLDER/geturls.txt
  # FILTER POST / POST DATA
  GET_RESULTS="$(cat $XSSTRIKEFOLDER/geturls.txt)"
  [[ -z "$GET_RESULTS" ]] && printError "No XSS GET testable URLs were found with sqlmap"
  # "\nThe following will be scanned (for now only GET is used, next versions will use POST urls):"
  printInfo "Executing xsstrike" 2
  XSSTRIKE_RUN="xsstrike $XSSTRIKE_AUTH --seeds $XSSTRIKEFOLDER/geturls.txt --threads 10 -l 1 --console-log-level GOOD &> $XSSTRIKEFOLDER/xssVulnsRaw.txt"
  [[ $VERB = "INFO" ]] && echo -e "Running [ $XSSTRIKE_RUN ]"
  echo $XSSTRIKE_RUN | bash
  cat $XSSTRIKEFOLDER/xssVulnsRaw.txt | grep -v "!!" > $XSSTRIKEFOLDER/xsstrikeVulns.txt

 # POST_RESULTS="$(cat $XSSTRIKEFOLDER/posturls.txt)"

  endxsstrikeprocess=`date +%s`
  printInfo "Ended XSStrike process" 1
  displaytime `expr $endxsstrikeprocess - $startxsstrikeprocess`
  printInfo "Execution time of XSStrike process was $timecalc." 0
}


########### MAIN ##############

xsstrike
