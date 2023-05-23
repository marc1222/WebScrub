#!/bin/bash
#
# usage ./scan.sh HOST LEVEL FOLDER DEBUG AUTH PORT
#
# PARAMS
# 1 - Host to be scanned -> format [192.168.1.1, localhost, example.com]
# 2 - Scan Intensity level -> format [1, 2]
# 3 - The folder where the output folders are located -> format [ ".", "./myworkdir" ..]
# 4 - Authentication token to be used in the cookies -> format [ "key=value", "PHPSESSID=12341536" ..]
# 5 - [required] Header Authorization VALUE (Bearer|JWT|BasicAuth) -- "Bearer: eY.." OR "Basic base64passwd". Empty string allowed.
# 6 - Port on which to perform HTTP tests, default is 80 -> format [ 80, 443, 8080, ..]
# 7 - Shows info on the execution (DEBUG, OUTPUT, NONE) -> format [ "NONE", "DEBUG", ..]


########### VARIABLES ##############

HOST="$1"
LEVEL="$2"
WORKDIR="$(cd $3; pwd -P)"
COOKIE=$4
AUTHHEADER=$5
PORT="80"
[[ -n $6 ]] && PORT=$6
VERB="$7"

PARENT_FOLDER=$( cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd -P )

source "$PARENT_FOLDER"/scripts/tools.sh
source "$PARENT_FOLDER"/scripts/env.sh
declare_globals $LEVEL

[[ $VERB = "INFO" ]] && echo -e "\nHOST: "$HOST""
[[ $VERB = "INFO" ]] && echo -e "WORKDIR: "$WORKDIR""
[[ $VERB = "INFO" ]] && echo -e "BASE SCRIPT FOLDER: "$PARENT_FOLDER"\n"

########### FUNCTIONS ##############

# check if requirements are met, otherwise exit
function check_requirements () {
  [[ ! -d "$OUTFOLDER" ]] && echo "Output folder "$OUTFOLDER" does not exist." && exit 1
  [[ ! -d "$DEBUGFOLDER" ]] && echo "Debug folder "$DEBUGFOLDER" does not exist." && exit 1
  [[ `is_reachable "$HOST"` == 1  ]] && echo "Host is not reachable, exiting" && exit 1;
  [[ $COOKIE == ' ' ]] && COOKIE=''
  [[ $AUTHHEADER == ' ' ]] && AUTHHEADER=''
  [[ -z $COOKIE && -z $AUTHHEADER ]] && AUTH=0 || AUTH=1
}

#
#check WAF presence and type
function is_there_WAF() {

  printInfo "Checking WAF.." 1
  wafw00f "$HOST" 2>/dev/null | grep "is behind" | sed 's/.*behind \(.*\) WAF./\1/' | awk '{print "WAF: " $0}' > "$OUTFOLDER"/scan_info.out
  [[ $VERB = "OUTPUT" || $VERB = "INFO" ]] && [[ -z $(cat $OUTFOLDER/scan_info.out) ]] && echo "There is no WAF!"
}

# runs nmap scans and outputs them in the indicated folder
function run_nmap() {

  HTTP_TEST_PORT="-p $PORT"

  # initial nmap, simple, fast, scripts+version
  SIMPLE="nmap -T4 -sV -sC $HOST $(nmap_output_args $DEBUGFOLDER nmap-simple-scriptsVersion)"

  # all TCP ports nmap, slow
  FULL_PORT="nmap -v -p- --min-rate 5000 -sV -sC $HOST $(nmap_output_args $DEBUGFOLDER nmap-allPortsTCP)"

  # selected http scripts (enum,auth,auth-finder)
  SELECTION="http-enum,http-auth,http-auth-finder,http-cookie-flags,http-security-headers,http-cors,http-cross-domain-policy,http-dombased-xss,http-stored-xss,http-sql-injection,http-favicon,http-apache-server-status,http-aspnet-debug,http-bigip-cookie,http-comments-displayer,http-devframework,http-errors,http-headers,http-internal-ip-disclosure,http-methods,http-open-redirect,http-passwd,http-vhosts,http-waf-detect"
  SELECTED_HTTP_SCRIPTS="nmap $HTTP_TEST_PORT --script=$SELECTION $HOST $(nmap_output_args $DEBUGFOLDER nmap-selectedHttpScripts)"

  # the rest of http scripts
  UNSELECTION=$(echo $SELECTION | sed 's/,/\|\|/g')
  OTHER_HTTP_SCRIPTS="nmap $HTTP_TEST_PORT --script='http-* and not ($UNSELECTION||brute||dos)' $HOST $(nmap_output_args $DEBUGFOLDER nmap-otherHttpScripts)"

  # ssl scan
  SSL_SCAN="nmap -sV --script 'ssl-* and not brute and not dos' -p443 $HOST $(nmap_output_args $DEBUGFOLDER nmap-sslscan)"

  printInfo "Starting nmap scanning process" 1
  printInfo "Executing initial nmap.." 2
  [[ $VERB = "INFO" ]] && echo -e "Executing simple nmap\n[ $SIMPLE ]\n"
  echo $SIMPLE | bash
  printInfo "Executing selected nmap HTTP scripts.." 2
  [[ $VERB = "INFO" ]] && echo -e "Executing selected http nmap scripts..\n[ $SELECTED_HTTP_SCRIPTS ]\n"
  echo $SELECTED_HTTP_SCRIPTS | bash
  printInfo "Executing nmap SSL scripts.." 2
  [[ $VERB = "INFO" ]] && echo -e "Executing nmap ssl scan.. \n[ $SSL_SCAN ]\n"
  echo $SSL_SCAN | bash

  if [ $LEVEL = "2" ]; then
    echo -e "Executing a full port scan..\n[ $FULL_PORT ]\n"
    echo $FULL_PORT | bash
    echo -e "Executing a bazillion http nmap scripts.. \n[ $OTHER_HTTP_SCRIPTS ]\n"
    echo $OTHER_HTTP_SCRIPTS | bash
  fi

  [[ $VERB = "OUTPUT" || $VERB = "INFO" ]] && parse_xml_nmap_ports
}

function run_hakrawler () {

  if [[ $AUTH -eq 1 ]]; then
    if [[ ( -n $COOKIE ) && ( -n $AUTHHEADER ) ]]; then
      HAKRAWLER_AUTH="-h 'Cookie: $COOKIE \n Authorization: $AUTHHEADER'"
    elif [[ -n $COOKIE ]]; then
      HAKRAWLER_AUTH="-h 'Cookie: $COOKIE'"
    elif [[ -n $AUTHHEADER ]]; then
      HAKRAWLER_AUTH="-h 'Authorization: $AUTHHEADER'"
    fi
  else
    HAKRAWLER_AUTH=""
  fi

 # HAKRAWLER_RUN_HTTP_NOAUTH="echo http://$HOST | hakrawler -u -i -d 1 > $DEBUGFOLDER/hakrawler.out"
 #HAKRAWLER_RUN_HTTPS_NOAUTH="echo https://$HOST | hakrawler -u -i -d 1 >> $DEBUGFOLDER/hakrawler.out"
  HAKRAWLER_RUN_HTTP="echo http://$HOST | hakrawler -u -i -d 1 $HAKRAWLER_AUTH > $DEBUGFOLDER/hakrawler.out"
  HAKRAWLER_RUN_HTTPS="echo https://$HOST | hakrawler -u -i -d 1 $HAKRAWLER_AUTH >> $DEBUGFOLDER/hakrawler.out"

  printInfo "Executing Hakrawler.." 1
 # [[ $VERB = "INFO" ]] && echo -e "\nHakrawler execution for HTTP without auth..\n[ "$HAKRAWLER_RUN_HTTPS" ] \n"
 # echo "$HAKRAWLER_RUN_HTTP_NOAUTH" | bash
#  [[ $VERB = "INFO" ]] && echo -e "\nHakrawler execution for HTTPS without auth..\n[ "$HAKRAWLER_RUN_HTTPS" ] \n"
 # echo "$HAKRAWLER_RUN_HTTPS_NOAUTH" | bash
  [[ $VERB = "INFO" ]] && echo -e "\nHakrawler execution for HTTP..\n[ \"$HAKRAWLER_RUN_HTTP\" ] \n"
  echo "$HAKRAWLER_RUN_HTTP" | bash
  [[ $VERB = "INFO" ]] && echo -e "\nHakrawler execution for HTTPS..\n[ \"$HAKRAWLER_RUN_HTTPS\" ] \n"
  echo "$HAKRAWLER_RUN_HTTPS" | bash

}


parse_xml_nmap_ports(){
  xmlstarlet sel -t -m "//port" -v "concat(@portid,'|',@protocol,'|',state/@state,'|',service/@name)" -nl nmap-simple-scriptsVersion.out
}

# prints all paths parsed from an XML generated output from running nmap with the http-enum script
parse_xml_nmap_urls() {
    xmlstarlet sel -t -m '//script[@id="http-enum"]' -v '@output' $DEBUGFOLDER/nmap-selectedHttpScripts.out | tr ":" " " | sed '/^$/d' | awk -v host="$HOST" -v port="$PORT" '{print "http://" host ":" port $1}'
}


# currently merges output from nmap, dirhunt and dirsearch into one file with all URLs, in the future it will be a JSON file
generate_urls_file() {
    printInfo "Generating URLs file in $OUTFOLDER.." 1
    #echo -e "\nGenerating URLs file in $OUTPUTFOLDER..\n"
    # code for the JSON version of the function, WIP
    # echo '{"files": [], "folders": []}' > $3/urls.json
    # jq '.files += ["test22"]' urls.json > urls.tmp && mv urls.tmp urls.json

    #adding dirhunt output to URLs file, only folders are added
    #sed '/\/$/!d' $2/dirhunt.out > $3/urlstmp.txt
    sed '/\/$/!d' $DEBUGFOLDER/hakrawler.out > $DEBUGFOLDER/urlstmp.txt


    #adding nmap output to URLs file
    parse_xml_nmap_urls >> $DEBUGFOLDER/urlstmp.txt

    cat $DEBUGFOLDER/urlstmp.txt | sort | uniq > $OUTFOLDER/urls.txt

    RESULT=$(cat $OUTFOLDER/urls.txt)
    [[ ! $RESULT ]] && printError "No URLs were found for processing!"
    printInfo "Found URLs for further processing:\n\n$RESULT" 1
}

########### MAIN ##############

check_requirements
is_there_WAF
run_nmap
run_hakrawler
generate_urls_file $HOST $DEBUGFOLDER $OUTFOLDER
