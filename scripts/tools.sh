#!/bin/bash

# whenever a ping or curl is successful returns 0
# usage: is_reachable <host>
is_reachable() {
    count=0
    while [ $count -lt 2 ]
    do
        # if it exits with non 1 status, return, there is connectivity
        ping -c1 $1 &>/dev/null && echo 0 && return 0
        curl --connect-timeout 5 -q $1 &>/dev/null && echo 0 && return 0
        (( count++ ))
    done
    #print 1 signaling error
    echo 1
}

# run dirsearch
function run_dirsearch () {
  echo -e "\nDirsearch execution.. \n[ dirsearch -u $HOST -q 1>$DEBUGFOLDER/dirsearch.out 2>$DEBUGFOLDER/dirsearch.err ] \n"
  dirsearch -u $HOST -q 1>$DEBUGFOLDER/dirsearch.out 2>$DEBUGFOLDER/dirsearch.err
}

# returns output arguments for nmap
# usage: nmap_output_args OUTPUT_FOLDER FILENAME
nmap_output_args() {
    echo "-oX $1/$2.out 2>$1/$2.err 1>/dev/null"
}

#usage: parse_dirsearch <input_folder>
parse_dirsearch () {
    grep "200\|301" $1/dirsearch.out | awk '{print $NF}'
    #adding dirsearch output to URLs file
    #parse_dirsearch $2 | sed '/\/$/!d' >> $3/urls.txt
}

# tests for XSS injections by crawling parameters and testing them
# usage xss_scan URL OUTPUT_FOLDER DEBUG_FOLDER
single_xss_scan () {
  sqlmap -u $1 --forms --batch --answers="test=n","cookie=n" > $2/sqlmapFormsRaw.out

  sqlmap -u $1 --crawl=3 --batch --answers="test=n","cookie=n" > $2/sqlmapCrawlRaw.out

  grep GET $2/sqlmapCrawlRaw.out | cut -w -f2 > $2/xssParamsGET.out
  grep POST $2/sqlmapCrawlRaw.out | cut -w -f2 > $2/xssParamsPOST.out

  grep GET $2/sqlmapFormsRaw.out | cut -w -f2 >> $2/xssParamsGET.out
  grep POST $2/sqlmapFormsRaw.out | cut -w -f2 >> $2/xssParamsPOST.out

  echo -e "\n Running XSStrike to get vulns \n[ xsstrike --seeds $2/xssParamsGET.out | tee $2/xssVulns.out ]\n"
  xsstrike --seeds $2/xssParamsGET.out | tee $2/xssVulns.out
}


# dirhunt funct 
# it collects only responses with 200 HTTP code, for the moment
# usage: run_dirhunt
function run_dirhunt () {
  DIRHUNT_RUN_HTTP="dirhunt --not-follow-subdomains --stdout-flags 200 http://"$HOST":"$PORT" | tee | awk '(NR>1)' > $DEBUGFOLDER/dirhunt.out"
  DIRHUNT_RUN_HTTPS="dirhunt --not-follow-subdomains --stdout-flags 200 https://"$HOST":443 | tee | awk '(NR>1)' >> $DEBUGFOLDER/dirhunt.out"
  echo -e "\nDirhunt execution for HTTP..\n[ "$DIRHUNT_RUN_HTTP" ] \n"
  echo "$DIRHUNT_RUN_HTTP" | bash
  echo -e "\nDirhunt execution for HTTPS..\n[ "$DIRHUNT_RUN_HTTPS" ] \n"
  echo "$DIRHUNT_RUN_HTTPS" | bash
}
