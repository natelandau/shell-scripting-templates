
# Colors
if tput setaf 1 &>/dev/null; then
  bold=$(tput bold)
  white=$(tput setaf 7)
  reset=$(tput sgr0)
  purple=$(tput setaf 171)
  red=$(tput setaf 1)
  green=$(tput setaf 76)
  tan=$(tput setaf 3)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 38)
  underline=$(tput sgr 0 1)
else
  bold="\033[4;37m"
  white="\033[0;37m"
  reset="\033[0m"
  purple="\033[0;35m"
  red="\033[0;31m"
  green="\033[1;32m"
  tan="\033[0;33m"
  yellow="\033[0;33m"
  blue="\033[0;34m"
  underline="\033[4;37m"
fi

_alert_() {
  # DESC:   Controls all printing of messages to log files and stdout.
  # ARGS:   $1 (required) - The type of alert to print
  #                         (success, header, notice, dryrun, debug, warning, error,
  #                         fatal, info, input)
  #         $2 (required) - The message to be printed to stdout and/or a log file
  #         $3 (optional) - Pass '$LINENO' to print the line number where the _alert_ was triggered
  # OUTS:   None
  # USAGE:  [ALERTTYPE] "[MESSAGE]" "$LINENO"
  # NOTES:  - Requires the variable LOGFILE to be set prior to
  #           calling this function.
  #         - The colors of each alert type are set in this function
  #         - For specified alert types, the funcstac will be printed

  local scriptName logLocation logName function_name color
  local alertType="${1}"
  local message="${2}"
  local line="${3-}"

  [ -z "${LOGFILE-}" ] && fatal "\$LOGFILE must be set"
  [ ! -d "$(dirname "${LOGFILE}")" ] && mkdir -p "$(dirname "${LOGFILE}")"

  if [ -z "${line}" ]; then
    [[ "$1" =~ ^(fatal|error|debug|warning) && "${FUNCNAME[2]}" != "_trapCleanup_" ]] \
      && message="${message} $(_functionStack_)"
  else
    [[ "$1" =~ ^(fatal|error|debug) && "${FUNCNAME[2]}" != "_trapCleanup_" ]] \
      && message="${message} (line: $line) $(_functionStack_)"
  fi

  if [ -n "${line}" ]; then
    [[ "$1" =~ ^(warning|info|notice|dryrun) && "${FUNCNAME[2]}" != "_trapCleanup_" ]] \
      && message="${message} (line: $line)"
  fi

  if [[ "${alertType}" =~ ^(error|fatal) ]]; then
    color="${bold}${red}"
  elif [ "${alertType}" = "warning" ]; then
    color="${red}"
  elif [ "${alertType}" = "success" ]; then
    color="${green}"
  elif [ "${alertType}" = "debug" ]; then
    color="${purple}"
  elif [ "${alertType}" = "header" ]; then
    color="${bold}${tan}"
  elif [[ "${alertType}" =~ ^(input|notice) ]]; then
    color="${bold}"
  elif [ "${alertType}" = "dryrun" ]; then
    color="${blue}"
  else
    color=""
  fi

  _writeToScreen_() {

    ("${QUIET}") && return 0  # Print to console when script is not 'quiet'
    [[ ${VERBOSE} == false && "${alertType}" =~ ^(debug|verbose) ]] && return 0

    if ! [[ -t 1 ]]; then  # Don't use colors on non-recognized terminals
      color=""
      reset=""
    fi

    echo -e "$(date +"%r") ${color}$(printf "[%7s]" "${alertType}") ${message}${reset}"
  }
  _writeToScreen_

  _writeToLog_() {
 [[ "${alertType}" == "input" ]] && return 0
    [[ "${LOGLEVEL}" =~ (off|OFF|Off) ]] && return 0
    [[ ! -f "${LOGFILE}" ]] && touch "${LOGFILE}"

    # Don't use colors in logs
    if command -v gsed &>/dev/null; then
      local cleanmessage="$(echo "${message}" | gsed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
    else
      local cleanmessage="$(echo "${message}" | sed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
    fi
    echo -e "$(date +"%b %d %R:%S") $(printf "[%7s]" "${alertType}") [$(/bin/hostname)] ${cleanmessage}" >>"${LOGFILE}"
  }

# Write specified log level data to LOGFILE
case "${LOGLEVEL:-ERROR}" in
  ALL|all|All)
    _writeToLog_
    ;;
  DEBUG|debug|Debug)
    _writeToLog_
    ;;
  INFO|info|Info)
    if [[ "${alertType}" =~ ^(die|error|fatal|warning|info|notice|success) ]]; then
      _writeToLog_
    fi
    ;;
  WARN|warn|Warn)
    if [[ "${alertType}" =~ ^(die|error|fatal|warning) ]]; then
      _writeToLog_
    fi
    ;;
  ERROR|error|Error)
    if [[ "${alertType}" =~ ^(die|error|fatal) ]]; then
      _writeToLog_
    fi
    ;;
  FATAL|fatal|Fatal)
    if [[ "${alertType}" =~ ^(die|fatal) ]]; then
      _writeToLog_
    fi
   ;;
  OFF|off)
    return 0
  ;;
  *)
    if [[ "${alertType}" =~ ^(die|error|fatal) ]]; then
      _writeToLog_
    fi
    ;;
esac

} # /_alert_

error() { _alert_ error "${1}" "${2-}"; }
warning() { _alert_ warning "${1}" "${2-}"; }
notice() { _alert_ notice "${1}" "${2-}"; }
info() { _alert_ info "${1}" "${2-}"; }
success() { _alert_ success "${1}" "${2-}"; }
dryrun() { _alert_ dryrun "${1}" "${2-}"; }
input() { _alert_ input "${1}" "${2-}"; }
header() { _alert_ header "== ${1} ==" "${2-}"; }
die() { _alert_ fatal "${1}" "${2-}"; _safeExit_ "1" ; }
fatal() { _alert_ fatal "${1}" "${2-}"; _safeExit_ "1" ; }
debug() { _alert_ debug "${1}" "${2-}"; }
verbose() { _alert_ debug "${1}" "${2-}"; }
