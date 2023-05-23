#!/bin/bash

# Usage: declare_globals (no parameters)
# Other scripts import this one, thus, this env.sh must be in the same folder as invoking scripts (source "$(dirname "$0")/env.sh")

function declare_globals {

# TOOL DIRS PATH

  PARENT_FOLDER=$( cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd -P )
  #PARENT_FOLDER=$( dirname "$(dirname "$0")")
  DICTFOLDER="$PARENT_FOLDER/dicts"
  OUTFOLDER="$WORKDIR/output"
  DEBUGFOLDER="$WORKDIR/debug"
  RESULTSFOLDER="$WORKDIR/docs"


  [[ -d "$DEBUGFOLDER"  ]] || mkdir $DEBUGFOLDER
  [[ -d "$OUTFOLDER"  ]] || mkdir $OUTFOLDER
  [[ -d "$RESULTSFOLDER"  ]] || mkdir $RESULTSFOLDER

  FUZZINGFOLDER="$WORKDIR/fuzz"

  case $LEVEL in
     # DICT FILENAMES MUST NOT CONTAIN BLANK SPACES AND MUST END WITH .TXT
    1)
      DICTS=("http_common.txt" "common.txt" "my-small-dict.txt" "without-slash/dict-small-without-slash.txt")
      ;;

    2)
      DICTS=("http_common.txt" "my-medium-dict.txt" "without-slash/dict-medium-without-slash.txt")
      ;;
    3)
      DICTS=("http_common.txt" "my-medium-dict.txt" "without-slash/dict-medium-without-slash.txt" "raft-medium-words.txt")
      ;;
    "TEST")
      DICTS=("common.txt")
      ;;
    *)
      echo -n "[!] A VALID LEVEL MUST BE PROVIDED"
      exit 1
      ;;
  esac

}

function printError {
  echo -e "[!] $1"
  exit 1
}

function printInfo {
  echo -en "\e[32m[+]"
  [ -z "$2" ] || for p in $(seq "$2"); do echo -n " ----"; done
  echo -e " $1\e[0m"
}

function displaytime {
	local T=$1
	local D=$((T/60/60/24))
	local H=$((T/60/60%24))
	local M=$((T/60%60))
	local S=$((T%60))
	timecalc=""
	(( $D > 0 )) && stringreturn="$timecalc $D days "
	(( $H > 0 )) && stringreturn="$timecalc $H hours "
	(( $M > 0 )) && timecalc="$timecalc $M minutes "
	timecalc="$timecalc $S seconds"
}
