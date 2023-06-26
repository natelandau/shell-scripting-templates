#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
#
#
# @file
# Defines function: bfl::trap_cleanup().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints the passed message to specified log depending on its log-level to stdout.
#   Log errors and cleanup from script when an error is trapped.  Called by 'trap'.
#
# @param Integer   ErrCode
#   Error code.
#
# @param String $FunclineNo
#   Line number in function. ${BASH_LINENO[*]}
#
# @param String $lineNo
#   Line number where error was trapped.
#
# @param String $FuncStack
#   Names of all shell functions currently in the execution call stack.
#
# @param String $cmnd
#   Command executing at the time of the trap.
#
# @param String $source
#   bash source from calling script.
#
# @param Boolean $sourced
#       true / false.
#
# @param String $BASH_SOURCE
#   BASH_SOURCE.
#
# @param String    $parameters
#   Command parameters.
#
# @param String    LogFile (optional)
#   Log file.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   trap 'bfl::trap_cleanup "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]}" "$BASH_COMMAND" "$0" "${BASH_SOURCE[0]}" "$*" "$HOME/.faults"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
#------------------------------------------------------------------------------
bfl::trap_cleanup() {
  bfl::verify_arg_count "$#" 8 9 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [8..9]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r lineno_fns="${2% 0}"
  if [[ "${lineno_fns}" == "0" ]]; then
      local -r _line="$3" # LINENO
  else
      local -r _line="$2${lineno_fns}"  # local -r _linecallfunc=${2:-}
  fi
  local _funcstack="${4:-script}"   #    ????
  _funcstack="'$(printf "%s" "${_funcstack}" | sed -E 's/ / < /g')'"

  local -r _command="${5:-}"
  local -r  _script="${6:-}"
  local -r _sourced="${7:-}"
#                     command script
  local msg="Bash command: ${_command}\n${_script}\nFunction: ${_funcstack}, parameters: $8\n${_funcstack} failed with code $1 at line ${_line}"
  if [[ "${_script##*/}" == "${_sourced##*/}" ]]; then
      msg="$msg
[func: $(bfl::print_function_stack)]"
  fi
  local -r logfile="${9:-$BASH_FUNCTION_LOG}"

  # Replace the cursor in-case 'tput civis' has been used
  [[ ${_BFL_HAS_TPUT} -eq 1 ]] && tput cnorm

  bfl::writelog_fail "$msg" "${_funcstack}" "$logfile" && return 0

#----------- https://github.com/natelandau/shell-scripting-templates ----------
#  if declare -f "fatal" &>/dev/null && declare -f "bfl::print_function_stack" &>/dev/null; then
#      _funcstack="'$(printf "%s" "${_funcstack}" | sed -E 's/ / < /g')'"
#
#      if [[ ${_script##*/} == "${_sourced##*/}" ]]; then
#          bfl::writelog_fail "${8:-} command: '${_command}' failed with code '$1' (line: ${_line}) [func: $(bfl::print_function_stack)]"
#      else
#          bfl::writelog_fail "${8:-} command: '${_command}' failed with code '$1' (func: ${_funcstack} called at line ${_linecallfunc} of '${_script##*/}') (line: ${_line} of '${_sourced##*/}') "
#      fi
#  else
#      printf "%s\n" "Fatal error trapped. Exiting..."
#  fi

#  if declare -f 'bfl::script_lock_release' &>/dev/null; then
#      return 1
#  else
#      return 1
#  fi

  return 1
  }
