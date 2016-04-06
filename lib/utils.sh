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
# * 2016-02-10 - v1.1.1  - Minor changes to satisfy Shellcheck
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

function _alert() {
  if [ "${1}" = "emergency" ]; then
    local color="${bold}${red}"
  fi
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${red}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "debug" ]; then local color="${purple}"; fi
  if [ "${1}" = "header" ]; then local color="${bold}""${tan}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}"; printLog="false"; fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color=""; fi
  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then color=""; reset=""; fi

  # Print to $logFile
  if [[ ${printLog} = "true" ]] || [ "${printLog}" == "1" ]; then
    echo -e "$(date +"%m-%d-%Y %r") $(printf "[%9s]" "${1}") ${_message}" >> "${logFile}";
  fi

  # Print to console when script is not 'quiet'
  if [[ "${quiet}" = "true" ]] || [ "${quiet}" == "1" ]; then
   return
  else
   echo -e "$(date +"%r") ${color}$(printf "[%9s]" "${1}") ${_message}${reset}";
  fi

}

function die ()       { local _message="${*} Exiting."; echo "$(_alert emergency)"; safeExit;}
function error ()     { local _message="${*}"; echo "$(_alert error)"; }
function warning ()   { local _message="${*}"; echo "$(_alert warning)"; }
function notice ()    { local _message="${*}"; echo "$(_alert notice)"; }
function info ()      { local _message="${*}"; echo "$(_alert info)"; }
function debug ()     { local _message="${*}"; echo "$(_alert debug)"; }
function success ()   { local _message="${*}"; echo "$(_alert success)"; }
function input()      { local _message="${*}"; echo -n "$(_alert input)"; }
function header()     { local _message="========== ${*} ==========  "; echo "$(_alert header)"; }

# Log messages when verbose is set to "true"
verbose() {
  if [[ "${verbose}" = "true" ]] || [ "${verbose}" == "1" ]; then
    debug "$@"
  fi
}


# Source additional /lib files
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

if [ ! -d "${SOURCEPATH}" ]
then
  die "Failed to find library files expected in: ${SOURCEPATH}"
fi
for utility_file in "${SOURCEPATH}"/*.sh
do
  if [ -e "${utility_file}" ]; then
    # Don't source self
    if [[ "${utility_file}" == *"utils.sh"* ]]; then
      continue
    fi
    source "$utility_file"
  fi
done
