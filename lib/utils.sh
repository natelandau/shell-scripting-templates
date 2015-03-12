#!/usr/bin/env bash

# ##################################################
# Bash scripting Utilities.
#
# VERSION 1.0.0
#
# This script sources my collection of scripting utilities making
# it possible to source this one script and gain access to a
# complete collection of functions, variables, and other options.
#
# HISTORY
#
# * 2015-01-02 - v1.0.0  - First Creation
#
# ##################################################

# Logging and Colors
# ------------------------------------------------------
# Here we set the colors for our script feedback.
# Example usage: success "sometext"
#------------------------------------------------------

# Set Colors
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

function _alert() { #my function
  if [ "${1}" = "emergency" ]; then
    local color="${bold}${red}"
  fi
  if [ "${1}" = "error" ] || [ "${1}" = "warning" ]; then
    local color="${red}"
  fi
  if [ "${1}" = "success" ]; then
    local color="${green}"
  fi
  if [ "${1}" = "debug" ]; then
    local color="${purple}"
  fi
  if [ "${1}" = "header" ]; then
    local color="${bold}""${tan}"
  fi
  if [ "${1}" = "input" ]; then
    local color="${bold}"
    savedvar="${printLog}" # Don't print user questions to $logFile
    printLog="0"
  fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then
    local color="" # Us terminal default color
  fi
  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
    color=""; reset=""
  fi

  # Print to $logFile
  if [ "${printLog}" == "1" ]; then
    echo -e "$(date +"%m-%d-%Y %r") $(printf "[%9s]" ${1}) "${_message}"" >> $logFile;
  fi

  # Print to console when script is not 'quiet'
  ((quiet)) && return || echo -e "$(date +"%r") ${color}$(printf "[%9s]" ${1}) "${_message}"${reset}";

}

function die ()       { local _message="${@} Exiting."; echo "$(_alert emergency)"; safeExit;}
function error ()     { local _message="${@}"; echo "$(_alert error)"; }
function warning ()   { local _message="${@}"; echo "$(_alert warning)"; }
function notice ()    { local _message="${@}"; echo "$(_alert notice)"; }
function info ()      { local _message="${@}"; echo "$(_alert info)"; }
function debug ()     { local _message="${@}"; echo "$(_alert debug)"; }
function success ()   { local _message="${@}"; echo "$(_alert success)"; }
function input()      { local _message="${@}"; echo "$(_alert input)"; printLog="${savedvar}"; }
function header()     { local _message="========== ${@} ==========  "; echo "$(_alert header)"; }

# Log messages when verbose is set to "1"
verbose() {
  if [ "${verbose}" == "1" ]; then
    debug "$@"
  fi
}


# Source additional files
# ------------------------------------------------------
# The list of additional utility files to be sourced
# ------------------------------------------------------

# First we locate this script and populate the $SCRIPTPATH variable
# Doing so allows us to source additional files from this utils file.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve ${SOURCE} until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if ${SOURCE} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCEPATH="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

# Write the list of utility files to be sourced
FILES="
  sharedVariables.sh
  sharedFunctions.sh
  setupScriptFunctions.sh
"

# Source the Utility Files
for file in $FILES
do
  if [ -f "${SOURCEPATH}/${file}" ]; then
    source "${SOURCEPATH}/${file}"
  else
    die "${file} does not exist."
  fi
done


# Notes to self
# ####################
# This is how you create a variable with multiple lines
# read -d '' String <<"EOF"
#   one
#   two
#   three
#   four
# EOF
# echo ${String}
#
#   # How to get a script name
# scriptLocation="${0}"
# scriptFile="${scriptLocation##*/}"
# scriptName="${scriptFile%.*}"
# echo "${scriptName}"
