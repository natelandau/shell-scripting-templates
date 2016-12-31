#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my bash scripts.
#
# VERSION 1.4.0
#
# HISTORY
#
# * 2015-01-02 - v1.0.0   - First Creation
# * 2015-04-16 - v1.2.0   - Added 'checkDependencies' and 'pauseScript'
# * 2016-01-10 - v1.3.0   - Added 'join' function
# * 2016-01-11 - v1.4.9   - Added 'httpStatus' function
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
  unset "${result}"
  while read result
  do
    echo "${result}"
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

function pushover() {
  # pushover
  # ------------------------------------------------------
  # Sends notifications view Pushover
  # Requires a file named 'pushover.cfg' be placed in '../etc/'
  #
  # Usage: pushover "Title Goes Here" "Message Goes Here"
  #
  # Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html
  # ------------------------------------------------------

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

# Join
# ----------------------------------------------
# This function joins items together with a user specified separator
# Taken whole cloth from: http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
#
# Usage:
#   join , a "b c" d #a,b c,d
#   join / var local tmp #var/local/tmp
#   join , "${FOO[@]}" #a,b,c
# ----------------------------------------------
function join() { local IFS="${1}"; shift; echo "${*}"; }

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
  if [ "$(type -P "$1")" ]; then
    return 0
  fi
  return 1
}

function type_not_exists() {
  if [ ! "$(type -P "$1")" ]; then
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
  # echo ""
  input "$@"
  if "${force}"; then
    notice "Forcing confirmation with '--force' flag set"
  else
    read -p " (y/n) " -n 1
    echo ""
  fi
}

# Test whether the result of an 'ask' is a confirmation
function is_confirmed() {
  if "${force}"; then
    return 0
  else
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      return 0
    fi
    return 1
  fi
}

function is_not_confirmed() {
  if "${force}"; then
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
  input "   $@" 1>&2
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


function pauseScript() {
  # A simple function used to pause a script at any point and
  # only continue on user input
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
    # Usage: if in_array "VALUE" "${ARRAY[@]}"; then ...
    local value="$1"; shift
    for arrayItem in "$@"; do
        [[ "${arrayItem}" == "${value}" ]] && return 0
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

progressBar() {
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
  if [[ "${quiet}" = "true" ]] || [ "${quiet}" == "1" ]; then
    return
  fi

  local width
  width=30
  bar_char="#"

  # Don't run this function when scripts are running in verbose mode
  if ${verbose}; then return; fi

  # Reset the count
  if [ -z "${progressBarProgress}" ]; then
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

  if [ ! "${progressBarProgress}" -eq $(( $1 - 1 )) ]; then
    # Compute the percentage.
    perc=$(( progressBarProgress * 100 / $1 ))
    # Compute the number of blocks to represent the percentage.
    num=$(( progressBarProgress * width / $1 ))
    # Create the progress bar string.
    bar=
    if [ ${num} -gt 0 ]; then
        bar=$(printf "%0.s${bar_char}" $(seq 1 ${num}))
    fi
    # Print the progress bar.
    progressBarLine=$(printf "%s [%-${width}s] (%d%%)" "Running Process" "${bar}" "${perc}")
    echo -en "${progressBarLine}\r"
    progressBarProgress=$(( progressBarProgress + 1 ))
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
          [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
}

urldecode() {
    # Usage: urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\x}"
}

parse_yaml() {
  # Function to parse YAML files and add values to variables. Send it to a temp file and source it
  # https://gist.github.com/DinoChiesa/3e3c3866b51290f31243 which is derived from
  # https://gist.github.com/epiloque/8cf512c6d64641bde388
  #
  # Usage:
  #     $ parse_yaml sample.yml > /some/tempfile
  #
  # parse_yaml accepts a prefix argument so that imported settings all have a common prefix
  # (which will reduce the risk of name-space collisions).
  #
  #     $ parse_yaml sample.yml "CONF_"

    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
      indent = length($1)/2;
      if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
              vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
              printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
      }
    }' | sed 's/_=/+=/g'
}

httpStatus() {
  # -----------------------------------
  # Shamelessly taken from: https://gist.github.com/rsvp/1171304
  #
  # Usage:  httpStatus URL [timeout] [--code or --status] [see 4.]
  #                                             ^message with code (default)
  #                                     ^code (numeric only)
  #                           ^in secs (default: 3)
  #                   ^URL without "http://" prefix works fine.
  #
  #  4. curl options: e.g. use -L to follow redirects.
  #
  #  Dependencies: curl
  #
  #         Example:  $ httpStatus bit.ly
  #                   301 Redirection: Moved Permanently
  #
  #         Example: $ httpStatus www.google.com 100 -c
  #                  200
  #
  # -----------------------------------
  local curlops
  local arg4
  local arg5
  local arg6
  local arg7
  local flag
  local timeout
  local url

  saveIFS=${IFS}
  IFS=$' \n\t'

  url=${1}
  timeout=${2:-'3'}
  #            ^in seconds
  flag=${3:-'--status'}
  #    curl options, e.g. -L to follow redirects
  arg4=${4:-''}
  arg5=${5:-''}
  arg6=${6:-''}
  arg7=${7:-''}
  curlops="${arg4} ${arg5} ${arg6} ${arg7}"

  #      __________ get the CODE which is numeric:
  code=`echo $(curl --write-out %{http_code} --silent --connect-timeout ${timeout} \
                  --no-keepalive ${curlops} --output /dev/null  ${url})`

  #      __________ get the STATUS (from code) which is human interpretable:
  case $code in
       000) status="Not responding within ${timeout} seconds" ;;
       100) status="Informational: Continue" ;;
       101) status="Informational: Switching Protocols" ;;
       200) status="Successful: OK within ${timeout} seconds" ;;
       201) status="Successful: Created" ;;
       202) status="Successful: Accepted" ;;
       203) status="Successful: Non-Authoritative Information" ;;
       204) status="Successful: No Content" ;;
       205) status="Successful: Reset Content" ;;
       206) status="Successful: Partial Content" ;;
       300) status="Redirection: Multiple Choices" ;;
       301) status="Redirection: Moved Permanently" ;;
       302) status="Redirection: Found residing temporarily under different URI" ;;
       303) status="Redirection: See Other" ;;
       304) status="Redirection: Not Modified" ;;
       305) status="Redirection: Use Proxy" ;;
       306) status="Redirection: status not defined" ;;
       307) status="Redirection: Temporary Redirect" ;;
       400) status="Client Error: Bad Request" ;;
       401) status="Client Error: Unauthorized" ;;
       402) status="Client Error: Payment Required" ;;
       403) status="Client Error: Forbidden" ;;
       404) status="Client Error: Not Found" ;;
       405) status="Client Error: Method Not Allowed" ;;
       406) status="Client Error: Not Acceptable" ;;
       407) status="Client Error: Proxy Authentication Required" ;;
       408) status="Client Error: Request Timeout within ${timeout} seconds" ;;
       409) status="Client Error: Conflict" ;;
       410) status="Client Error: Gone" ;;
       411) status="Client Error: Length Required" ;;
       412) status="Client Error: Precondition Failed" ;;
       413) status="Client Error: Request Entity Too Large" ;;
       414) status="Client Error: Request-URI Too Long" ;;
       415) status="Client Error: Unsupported Media Type" ;;
       416) status="Client Error: Requested Range Not Satisfiable" ;;
       417) status="Client Error: Expectation Failed" ;;
       500) status="Server Error: Internal Server Error" ;;
       501) status="Server Error: Not Implemented" ;;
       502) status="Server Error: Bad Gateway" ;;
       503) status="Server Error: Service Unavailable" ;;
       504) status="Server Error: Gateway Timeout within ${timeout} seconds" ;;
       505) status="Server Error: HTTP Version Not Supported" ;;
       *)   echo " !!  httpstatus: status not defined." && safeExit ;;
  esac


  # _______________ MAIN
  case ${flag} in
       --status) echo "${code} ${status}" ;;
       -s)       echo "${code} ${status}" ;;
       --code)   echo "${code}"         ;;
       -c)       echo "${code}"         ;;
       *)        echo " !!  httpstatus: bad flag" && safeExit;;
  esac

  IFS="${saveIFS}"
}

function makeCSV() {
  # Creates a new CSV file if one does not already exist.
  # Takes passed arguments and writes them as a header line to the CSV
  # Usage 'makeCSV column1 column2 column3'

  # Set the location and name of the CSV File
  if [ -z "${csvLocation}" ]; then
    csvLocation="${HOME}/Desktop"
  fi
  if [ -z "${csvName}" ]; then
    csvName="$(LC_ALL=C date +%Y-%m-%d)-${FUNCNAME[1]}.csv"
  fi
  csvFile="${csvLocation}/${csvName}"

  # Overwrite existing file? If not overwritten, new content is added
  # to the bottom of the existing file
  if [ -f "${csvFile}" ]; then
    seek_confirmation "${csvFile} already exists. Overwrite?"
    if is_confirmed; then
      rm "${csvFile}"
      writeCSV "$@"
    fi
  fi
}

function writeCSV() {
  # Takes passed arguments and writes them as a comma separated line
  # Usage 'writeCSV column1 column2 column3'

  csvInput=($@)
  saveIFS=$IFS
  IFS=','
  echo "${csvInput[*]}" >> "${csvFile}"
  IFS=$saveIFS

}

function json2yaml() {
  # convert json files to yaml using python and PyYAML
  python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' < "$1"
}

function yaml2json() {
  # convert yaml files to json using python and PyYAML
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < "$1"
}