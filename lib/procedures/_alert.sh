#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::alert().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Controls all printing of messages to log files and stdout.
#
# @param String $alertType
#   The type of alert to print
#   (success, header, notice, dryrun, debug, warning, error, fatal, info, input)
#
# @param String $msg
#   The message to be printed to stdout and/or a log file.
#
# @param String $line (optional)
#   Pass '${LINENO}' to print the line number where the bfl::alert was triggered.
#
# @return String $result
#   Prints [function]:[file]:[line]. Does not print functions from the alert class.
#   The colors of each alert type are set in this function.
#   For specified alert types, the funcstac will be printed.
#   stdout: The message is printed to stdout.   log file: The message is printed to a log file.
#
# @example
#   bfl::alert "${alertType}" "${MESSAGE}" "${LINENO}"
#------------------------------------------------------------------------------
bfl::alert() {
  bfl::verify_arg_count "$#" 2 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _alertType="$1"
  local _msg="$2"
  local _line="${3:-}" # Optional line number

  if [[ -n ${_line} && ${_alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "bfl::trap_cleanup" ]]; then
      _msg="${_msg} ${Gray}(line: ${_line}) $(bfl::print_function_stack)"
  elif [[ -n ${_line} && ${FUNCNAME[2]} != "bfl::trap_cleanup" ]]; then
      _msg="${_msg} ${Gray}(line: ${_line})"
  elif [[ -z "${_line}" && "${_alertType}" =~ ^(fatal|error) && "${FUNCNAME[2]}" != "bfl::trap_cleanup" ]]; then
      _msg="${_msg} ${Gray}$(bfl::print_function_stack)"
  fi

  local _color
  if [[ "${_alertType}" =~ ^(error|fatal) ]]; then
      _color="${CLR_BAD}"   # ${FMT_BOLD}${CLR_BAD}
  elif [[ "${_alertType}" == "info" ]]; then
      _color="${CLR_INFORM}"
  elif [[ "${_alertType}" == "warning" ]]; then
      _color="${CLR_WARN}"
  elif [[ "${_alertType}" == "success" ]]; then
      _color="${CLR_GOOD}"
  elif [[ "${_alertType}" == "debug" ]]; then
      _color="${CLR_DEBUG}"
  elif [[ "${_alertType}" == "header" ]]; then
      _color="${FMT_BOLD}${White}${FMT_UNDERLINE}"
  elif [[ "${_alertType}" == "notice" ]]; then
      _color="${FMT_BOLD}"
  elif [[ "${_alertType}" == "input" ]]; then
      _color="${FMT_BOLD}${FMT_UNDERLINE}"
  elif [[ "${_alertType}" == "dryrun" ]]; then
      _color="${Blue}"
  else
      _color=""
  fi


  # Write specified log level data to logfile
  local s="${LOGLEVEL:-ERROR}"
  case "${s,,}" in
      all)
          bfl::write_log ${LOG_LVL_OFF} "${_msg}" "${_alertType}" ;;
      debug)
          bfl::writelog_debug "${_msg}" "${_alertType}" ;;
      info|notice)
          bfl::writelog_info "${_msg}" "${_alertType}" ;;
      success)
          bfl::writelog_success "${_msg}" "${_alertType}" ;;
      skipped)
          bfl::writelog_skipped "${_msg}" "${_alertType}" ;;
      warn)
          bfl::writelog_warn "${_msg}" "${_alertType}" ;;
      error|fatal)
          bfl::writelog_fail "${_msg}" "${_alertType}" ;;
      off) return 0 ;;
      *)  bfl::write_log ${LOG_LVL_OFF} "${_msg}" "${_alertType}" ;;
  esac

}

error()   { bfl::alert error "$1" "${2:-}"; return 1; }
warning() { bfl::alert warning "$1" "${2:-}"; }
notice()  { bfl::alert notice "$1" "${2:-}"; }
info()    { bfl::alert info "$1" "${2:-}"; }
success() { bfl::alert success "$1" "${2:-}"; }
dryrun()  { bfl::alert dryrun "$1" "${2:-}"; }
input()   { bfl::alert input "$1" "${2:-}"; }
header()  { bfl::alert header "$1" "${2:-}"; }
debug()   { bfl::alert debug "$1" "${2:-}"; }
fatal()   { bfl::alert fatal "$1" "${2:-}"; return 1; }
#
