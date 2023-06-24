#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# --------------- https://github.com/ralish/bash-script-template --------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::execute().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Executes commands while respecting global DRYRUN, VERBOSE, LOGGING, and BASH_INTERACTIVE flags.
#   If $DRYRUN=true, no commands are executed and the command that would have been executed
#   is printed to STDOUT using dryrun level alerting
#   If $VERBOSE=true, the command's native output is printed to stdout. This can be forced
#   with '_execute_ -v'
#
# @option String -v, -n, -p, -e, -s, -q
#     -v    Always print output from the execute function to STDOUT
#     -n    Use NOTICE level alerting (default is INFO)
#     -p    Pass a failed command with 'return 0'.  This effectively bypasses set -e.
#     -e    Bypass _alert_ functions and use 'printf RESULT'
#     -s    Use '_alert_ success' for successful output. (default is 'info')
#     -q    Do not print output (QUIET mode)
#
# @param String $command
#   The command to be executed.  Quotation marks MUST be escaped.
#
# @param String $str (Optional)
#   String to display after command is executed.
#
# @return Boolean $result
#   0 / 1   true / false
#   Configurable output.
#
# @example
#   bfl::execute_ "cp -R \"~/dir/somefile.txt\" \"someNewFile.txt\"" "Optional message"
#   bfl::execute_ -sv "mkdir \"some/dir\""
#------------------------------------------------------------------------------
bfl::execute() {
  bfl::verify_arg_count "$#" 1 8 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 8]"; return 1; }   # Verify argument count.

  local _localVerbose=false
  local _passFailures=false
  local _echoResult=false
  local _echoSuccessResult=false
  local _quietMode=false
  local _echoNoticeResult=false
  local opt

  local OPTIND=1
  while getopts ":vVpPeEsSqQnN" opt; do
      case ${opt,,} in
          v ) _localVerbose=true ;;
          p ) _passFailures=true ;;
          e ) _echoResult=true ;;
          s ) _echoSuccessResult=true ;;
          q ) _quietMode=true ;;
          n ) _echoNoticeResult=true ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  local _command="${1}"
  local _executeMessage="${2:-$1}"

  local _saveVerbose=${VERBOSE}
  ${_localVerbose} && VERBOSE=true

  if ${DRYRUN:-}; then
      if "${_quietMode}"; then
          VERBOSE=${_saveVerbose}
          return 0
      fi
      if [[ -n "${2:-}" ]]; then
          dryrun "${1} (${2})" "$(caller)"
      else
          dryrun "${1}" "$(caller)"
      fi
  elif ${VERBOSE:-}; then
      if eval "${_command}"; then
          if "${_quietMode}"; then
              VERBOSE=${_saveVerbose}
          elif "${_echoResult}"; then
              printf "%s\n" "${_executeMessage}"
          elif "${_echoSuccessResult}"; then
              success "${_executeMessage}"
          elif "${_echoNoticeResult}"; then
              notice "${_executeMessage}"
          else
              info "${_executeMessage}"
          fi
      else
          if ${_quietMode}; then
              VERBOSE=${_saveVerbose}
          elif "${_echoResult}"; then
              printf "%s\n" "warning: ${_executeMessage}"
          else
              warning "${_executeMessage}"
          fi
          VERBOSE=${_saveVerbose}
          "${_passFailures}" && return 0 || return 1
      fi
  else
      if eval "${_command}" >/dev/null 2>&1; then
          if "${_quietMode}"; then
              VERBOSE=${_saveVerbose}
          elif "${_echoResult}"; then
              printf "%s\n" "${_executeMessage}"
          elif ${_echoSuccessResult}; then
              success "${_executeMessage}"
          elif "${_echoNoticeResult}"; then
              notice "${_executeMessage}"
          else
              info "${_executeMessage}"
          fi
      else
          if ${_quietMode}; then
              VERBOSE=${_saveVerbose}
          elif "${_echoResult}"; then
              printf "%s\n" "error: ${_executeMessage}"
          else
              warning "${_executeMessage}"
          fi
          VERBOSE=${_saveVerbose}
          "${_passFailures}" && return 0 || return 1
      fi
  fi
  VERBOSE=${_saveVerbose}
  return 0
  }
