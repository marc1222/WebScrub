#!/bin/bash

# PARAMS
#	1 - [required] HOST url
#	2 - [required] Intensity Level
#	3 - [require]d] WorkDir PATH
# 	4 - [optional] Auth_Cookie_String
#	


# FUNCTIONS
function check_requirements { # FILES EXISTENCE & ARGS (except level)
	
	[[ $NUMARGS -lt 3 || $NUMARGS -gt 4 ]] && printError "$Script: Incorrect Arguments"

	[[ -z "$HOST" ]] || printError "$Script: HOST is empty"

	[[ -d "$WORKDIR" ]] || printError "$Script: No such $WORKDIR workdir folder"

	[[ -z $AUTH_STRING ]] && AUTH=0 || AUTH=1
} 

function main {

    check_requirements
	declare_globals
	printInfo "Starting SQLmap process" 0
	printInfo "This is to retrieve injection points from sqlmap tool" 1
	startsqlmapprocess=`date +%s`


	if [[ $AUTH -eq 1 ]]; then
		SQLMAP_AUTH="-H $AUTH_STRING"
	else
		SQLMAP_AUTH=""

    endsqlmapprocess=`date +%s`
	printInfo "Ended SQLmap process" 1
	displaytime `expr $startsqlmapprocess - $endsqlmapprocess`
	printInfo "Execution time of SQLmap process was$timecalc." 0
}

#VARSs
NUMARGS=$# 
Script=$0
HOST=$1
LEVEL=$2
WORKDIR=$3
AUTH_STRING=$4

source "$(dirname "$0")/env.sh" # IMPORT METHODS

main