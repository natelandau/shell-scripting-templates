#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my bash scripts.
#
# VERSION 1.0.0
#
# HISTORY
#
# * 2015-01-02 - v1.0.0   - First Creation
# * 2015-04-16 - v1.2.0   - Added 'checkDependencies' and 'pauseScript'
#
# ##################################################


# Traps
# ------------------------------------------------------
# These functions are for use with different trap scenarios
# ------------------------------------------------------

# Non destructive exit for when script exits naturally.
# Usage: Add this function at the end of every script
function safeExit() {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit
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

# Escape a string
# ------------------------------------------------------
# usage: var=$(escape "String")
# ------------------------------------------------------
escape() { echo "${@}" | sed 's/[]\.|$(){}?+*^]/\\&/g'; }

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
  if [ ! -f "${SOURCEPATH}/../etc/pushover.cfg" ]; then
   error "Please locate the pushover.cfg to send notifications to Pushover."
  else
    # Grab variables from the config file
    source "${SOURCEPATH}/../etc/pushover.cfg"

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
#    if is_file "file"; then
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
  input "$@"
  if [[ "${force}" == "1" ]]; then
    notice "Forcing confirmation with '--force' flag set"
  else
    read -p " (y/n) " -n 1
    echo ""
  fi
}

# Test whether the result of an 'ask' is a confirmation
function is_confirmed() {
  if [[ "${force}" == "1" ]]; then
    return 0
  else
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      return 0
    fi
    return 1
  fi
}

function is_not_confirmed() {
  if [[ "${force}" == "1" ]]; then
    return 1
  else
    if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
      return 0
    fi
    return 1
  fi
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
    notice "  Skipping!"
    return 0
  else
    notice "  Continuing..."
    return 1
  fi
}

# unmountDrive
# ------------------------------------------------------
# If an AFP drive is mounted as part of a script, this
# will unmount the volume.  This will only work on Macs.
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
  input "   ${@}" 1>&2
  if [ -n "${usage}" ]; then # print usage information if available
    echo "   ${usage}" 1>&2
  fi
  echo "" 1>&2
  exit 1
}

# Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.
# Usage in script:  $ homebrewDependencies=(package1 package2)
# -----------------------------------

function checkDependencies() {
  saveIFS=$IFS
  IFS=$' \n\t'
  if [ -n "${homebrewDependencies}" ]; then
    LISTINSTALLED="brew list"
    INSTALLCOMMAND="brew install"
    RECIPES=("${homebrewDependencies[@]}")
    # Invoke functions from setupScriptFunctions.sh
    hasHomebrew
    doInstall
  fi
  if [ -n "$caskDependencies" ]; then
    LISTINSTALLED="brew cask list"
    INSTALLCOMMAND="brew cask install --appdir=/Applications"
    RECIPES=("${caskDependencies[@]}")

    # Invoke functions from setupScriptFunctions.sh
    hasHomebrew
    hasCasks
    doInstall
  fi
  if [ -n "$gemDependencies" ]; then
    LISTINSTALLED="gem list | awk '{print $1}'"
    INSTALLCOMMAND="gem install"
    RECIPES=("${gemDependencies[@]}")
    # Invoke functions from setupScriptFunctions.sh
    doInstall
  fi
  IFS=$saveIFS
}

# pauseScript
# -----------------------------------
# A simple function used to pause a script at any point and
# only continue on user input
# -----------------------------------

function pauseScript() {
  seek_confirmation "Ready to continue?"
  if is_confirmed; then
    info "Continuing"
  else
    warning "Exiting Script."
    safeExit
  fi
}

function in_array() {
    # Determine if a value is in an array.
    # Usage: in_array [VALUE] [ARRAY]
    local value=$1; shift
    for item in "$@"; do
        [[ $item == $value ]] && return 0
    done
    return 1
}

# Text Transformations
# -----------------------------------
# Transform text using these functions.
# Adapted from https://github.com/jmcantrell/bashful
# -----------------------------------

lower() {
  # Convert stdin to lowercase.
  # usage:  text=$(lower <<<"$1")
  #         echo "MAKETHISLOWERCASE" | lower
  tr '[:upper:]' '[:lower:]'
}

upper() {
  # Convert stdin to uppercase.
  # usage:  text=$(upper <<<"$1")
  #         echo "MAKETHISUPPERCASE" | upper
  tr '[:lower:]' '[:upper:]'
}

ltrim() {
  # Removes all leading whitespace (from the left).
  local char=${1:-[:space:]}
    sed "s%^[${char//%/\\%}]*%%"
}

rtrim() {
  # Removes all trailing whitespace (from the right).
  local char=${1:-[:space:]}
  sed "s%[${char//%/\\%}]*$%%"
}

trim() {
  # Removes all leading/trailing whitespace
  # Usage examples:
  #     echo "  foo  bar baz " | trim  #==> "foo  bar baz"
  ltrim "$1" | rtrim "$1"
}

squeeze() {
  # Removes leading/trailing whitespace and condenses all other consecutive
  # whitespace into a single space.
  #
  # Usage examples:
  #     echo "  foo  bar   baz  " | squeeze  #==> "foo bar baz"

  local char=${1:-[[:space:]]}
  sed "s%\(${char//%/\\%}\)\+%\1%g" | trim "$char"
}

squeeze_lines() {
    # <doc:squeeze_lines> {{{
    #
    # Removes all leading/trailing blank lines and condenses all other
    # consecutive blank lines into a single blank line.
    #
    # </doc:squeeze_lines> }}}

    sed '/^[[:space:]]\+$/s/.*//g' | cat -s | trim_lines
}

# progressBar
# -----------------------------------
# Prints a progress bar within a for/while loop.
# To use this function you must pass the total number of
# times the loop will run to the function.
#
# usage:
#   for number in $(seq 0 100); do
#     sleep 1
#     progressBar 100
#   done
# -----------------------------------

progressBar() {
  if [[ ${quiet} = "true" ]] || [ ${quiet} == "1" ]; then
    return
  fi

  local width
  width=30
  bar_char="#"

  # Don't run this function when scripts are running in verbose mode
  if ${verbose}; then return; fi

  # Reset the count
  if [ -z ${progressBarProgress} ]; then
    progressBarProgress=0
  fi

  # Do nothing if the output is not a terminal
  if [ ! -t 1 ]; then
      echo "Output is not a terminal" 1>&2
      return
  fi
  # Hide the cursor
    tput civis
    trap 'tput cnorm; exit 1' SIGINT

  if [ ! ${progressBarProgress} -eq $(( $1 - 1 )) ]; then
    # Compute the percentage.
    perc=$(( ${progressBarProgress} * 100 / $1 ))
    # Compute the number of blocks to represent the percentage.
    num=$(( ${progressBarProgress} * $width / $1 ))
    # Create the progress bar string.
    bar=
    if [ ${num} -gt 0 ]; then
        bar=$(printf "%0.s${bar_char}" $(seq 1 ${num}))
    fi
    # Print the progress bar.
    line=$(printf "%s [%-${width}s] (%d%%)" "Running Process" "${bar}" "${perc}")
    echo -en "${line}\r"
    progressBarProgress=$[${progressBarProgress}+1]
  else
    # Clear the progress bar when complete
    echo -ne "${width}%\033[0K\r"
    unset progressBarProgress
  fi

  tput cnorm
}

htmlDecode() {
  # Decode HTML characters with sed
  # Usage: htmlDecode <string>
  echo "${1}" | sed -f "${SOURCEPATH}/htmlDecode.sed"
}

htmlEncode() {
  # Encode HTML characters with sed
  # Usage: htmlEncode <string>
  echo "${1}" | sed -f "${SOURCEPATH}/htmlEncode.sed"
}


urlencode() {
  # URL encoding/decoding from: https://gist.github.com/cdown/1163649
  # Usage: urlencode <string>

  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
      local c="${1:i:1}"
      case $c in
          [a-zA-Z0-9.~_-]) printf "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
}

urldecode() {
    # Usage: urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\x}"
}