#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my bash scripts.
#
# HISTORY
# * 2015-01-02 - Initial creation
#
# ##################################################

# scriptPath
# ------------------------------------------------------
# This function will populate the variable SOURCEPATH with the
# full path of the script being run.
# Note: The function must be run within the script before using
# the variable
# ------------------------------------------------------
function scriptPath() {
  SCRIPTPATH=$( cd "$( dirname "$0" )" && pwd )
}

# readFile
# ------------------------------------------------------
# Function to read a line from a file.
#
# Most often used to read the config files saved in my etc directory.
# Outputs each line in a variable named $result
# ------------------------------------------------------
function readFile() {
  unset ${result}
  while read result
  do
    echo ${result}
  done < "$1"
}

# needSudo
# ------------------------------------------------------
# If a script needs sudo access, call this function which
# requests sudo access and then keeps it alive.
# ------------------------------------------------------
function needSudo() {
  # Update existing sudo time stamp if set, otherwise do nothing.
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# die
# ------------------------------------------------------
# "die function" - used to denote a failed action in a script.
# usage:  cd some/path || die "cd failed"
# ------------------------------------------------------
die() {
  e_error "FATAL ERROR: $* (status $?)" 1>&2
  exit 1
}

# convertsecs
# ------------------------------------------------------
# Convert Seconds to human readable time
#
# To use this, pass a number (seconds) into the function as this:
# print "$(convertsecs $TOTALTIME)"
#
# To compute the time it takes a script to run use tag the start and end times with
#   STARTTIME=$(date +"%s")
#   ENDTIME=$(date +"%s")
#   TOTALTIME=$(($ENDTIME-$STARTTIME))
# ------------------------------------------------------
function convertsecs() {
  ((h=${1}/3600))
  ((m=(${1}%3600)/60))
  ((s=${1}%60))
  printf "%02d:%02d:%02d\n" $h $m $s
}

# pushover
# ------------------------------------------------------
# Sends notifications view Pushover
# Requires a file named 'pushover.cfg' be placed in '../etc/'
#
# Usage: pushover "Title Goes Here" "Message Goes Here"
#
# Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html
# ------------------------------------------------------
function pushover() {
  # Check for config file containing API Keys
  if [ ! -f "../etc/pushover.cfg" ]; then
   e_error "Please locate the pushover.cfg to send notifications to Pushover."
  else
    # Grab variables from the config file
    source "../etc/pushover.cfg"

    # Send to Pushover
    PUSHOVERURL="https://api.pushover.net/1/messages.json"
    API_KEY="${PUSHOVER_API_KEY}"
    USER_KEY="${PUSHOVER_USER_KEY}"
    DEVICE=""
    TITLE="${1}"
    MESSAGE="${2}"
    curl \
    -F "token=${API_KEY}" \
    -F "user=${USER_KEY}" \
    -F "device=${DEVICE}" \
    -F "title=${TITLE}" \
    -F "message=${MESSAGE}" \
    "${PUSHOVERURL}" > /dev/null 2>&1
  fi
}

# File Checks
# ------------------------------------------------------
# A series of functions which make checks against the filesystem. For
# use in if/then statements.
#
# Usage:
#    if is_file; then
#       ...
#    fi
# ------------------------------------------------------

function is_exists() {
  if [[ -e "$1" ]]; then
    return 0
  fi
  return 1
}

function is_not_exists() {
  if [[ ! -e "$1" ]]; then
    return 0
  fi
  return 1
}

function is_file() {
  if [[ -f "$1" ]]; then
    return 0
  fi
  return 1
}

function is_not_file() {
  if [[ ! -f "$1" ]]; then
    return 0
  fi
  return 1
}

function is_dir() {
  if [[ -d "$1" ]]; then
    return 0
  fi
  return 1
}

function is_not_dir() {
  if [[ ! -d "$1" ]]; then
    return 0
  fi
  return 1
}

function is_symlink() {
  if [[ -L "$1" ]]; then
    return 0
  fi
  return 1
}

function is_not_symlink() {
  if [[ ! -L "$1" ]]; then
    return 0
  fi
  return 1
}

function is_empty() {
  if [[ -z "$1" ]]; then
    return 0
  fi
  return 1
}

function is_not_empty() {
  if [[ -n "$1" ]]; then
    return 0
  fi
  return 1
}

# Test whether a command exists
# ------------------------------------------------------
# Usage:
#    if type_exists 'git'; then
#      some action
#    else
#      some other action
#    fi
# ------------------------------------------------------

function type_exists() {
  if [ $(type -P "$1") ]; then
    return 0
  fi
  return 1
}

function type_not_exists() {
  if [ ! $(type -P "$1") ]; then
    return 0
  fi
  return 1
}

# Test which OS the user runs
# $1 = OS to test
# Usage: if is_os 'darwin'; then

function is_os() {
  if [[ "${OSTYPE}" == $1* ]]; then
    return 0
  fi
  return 1
}


# SEEKING CONFIRMATION
# ------------------------------------------------------
# Asks questions of a user and then does something with the answer.
# y/n are the only possible answers.
#
# USAGE:
# seek_confirmation "Ask a question"
# if is_confirmed; then
#   some action
# else
#   some other action
# fi
#
# Credt: https://github.com/kevva/dotfiles
# ------------------------------------------------------

# Ask the question
function seek_confirmation() {
  echo ""
  e_bold "$@"
  read -p " (y/n) " -n 1
  echo ""
}

# same as above but underlined
function seek_confirmation_head() {
  echo ""
  e_underline "$@"
  read -p " (y/n) " -n 1
  echo ""
}

# Test whether the result of an 'ask' is a confirmation
function is_confirmed() {
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

function is_not_confirmed() {
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    return 0
  fi
  return 1
}

# Skip something
# ------------------------------------------------------
# Offer the user a chance to skip something.
# Credit: https://github.com/cowboy/dotfiles
# ------------------------------------------------------
function skip() {
  REPLY=noskip
  read -t 5 -n 1 -s -p "${bold}To skip, press ${underline}X${reset}${bold} within 5 seconds.${reset}"
  if [[ "$REPLY" =~ ^[Xx]$ ]]; then
    echo "  Skipping!"
    return 0
  else
    echo "  Continuing..."
    return 1
  fi
}

# unmountDrive
# ------------------------------------------------------
# If an AFP drive is mounted as part of a script, this
# will unmount the volume.
# ------------------------------------------------------
function unmountDrive() {
  if [ -d "$1" ]; then
    diskutil unmount "$1"
  fi
}

# help
# ------------------------------------------------------
# Prints help for a script when invoked from the command
# line.  Typically via '-h'.  If additional flags or help
# text is available in the script they will be printed
# in the '$usage' variable.
# ------------------------------------------------------

function help () {
  echo "" 1>&2
  e_bold "   ${@}" 1>&2
  if [ -n "${usage}" ]; then # print usage information if available
    echo "   ${usage}" 1>&2
  fi
  echo "" 1>&2
  exit 1
}