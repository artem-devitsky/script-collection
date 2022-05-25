#!/usr/bin/env bash
#Created by Artsiom Dziavitski
#################SCRIPT_TEMPLATE################

#Env block#
LOCKFILE="/tmp/"$0".lock"

#COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

#ALIAS
shopt -s expand_aliases
alias echo="echo -e"
alias red_echo="echo '${RED}'"
alias green_echo="echo '${GREEN}'"
alias blue_echo="echo '${BLUE}'"
###########

#Func block#
#
func_create_lock_file () {
local path="$1"

lockfile "${path}"
if [ $? -gt "0" ]
then {
	red_echo "Lockfile ${path} not created. May be script already started"
	exit 1001
	}
fi
}
func_check_lock_file () {
#execution: func_check_lock_file ${LOCKFILE}

local path="$1"

if [ -f ${path} ]
then {
	red_echo "Lockfile already exist."
	exit 100
	}
else {
	green_echo "Creating lockfile."
	func_create_lock_file ${LOCKFILE}
	#ls -al ${path}
	}
fi
}

func_delete_lock_file () {
#execution: func_delete_lock_file ${LOCKFILE}

local path="$1"

if [ -f "${path}" ]
then {
	rm "${path}"
	#ls -al ${path}
}
else {
	red_echo "Lockfile ${path} not found."
	exit 102
}
fi
}
#
#

func_hello () {
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Place for usage guide!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
blue_echo "My ECHO is blue."
}

############

func_check_lock_file ${LOCKFILE}
####BEGIN####

echo "${BLUE} Ambassador: This is MADNESS!!!! ${NC} O_o"
echo "${RED} Leonidas:    NO! THIS IS SPARDAAAAAAAA!!!!!!! ${NC} ^_^"

#####END#####
func_delete_lock_file ${LOCKFILE}
exit 0