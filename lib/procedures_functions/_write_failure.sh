#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
# @file
# Defines function: bfl::write_failure().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints the passed message to specified log depending on its log-level to stdout.
#
# @param Integer   ErrCode
#   Error code.
#
# @param String $bash_lineno_array
#   ${BASH_LINENO[*]}
#
# @param String $lineno
#   $LINENO
#
# @param String    FUNCNAME
#   Function name.
#
# @param String     $source
#   bash source from calling script.
#
# @param String    BASH_COMMAND
#   Bash command.
#
# @param String    $parameters
#   Command parameters.
#
# @param String    LogFile (optional)
#   Log file.
#
# @example
#   trap 'bfl::write_failure "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$0" "$BASH_COMMAND" "$*" "$HOME/.faults"' ERR
#------------------------------------------------------------------------------
bfl::write_failure() {
  bfl::verify_arg_count "$#" 7 8 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [7..8]" && return 1 # Verify argument count.

  local -r lineno_fns=${2% 0}
  [[ "$lineno_fns" -ne 0 ]] && local -r lineno="$2${lineno_fns}" || local -r lineno="$3"
  local -r fn="${4:-script}"
#          command
  local msg="Bash command: $6\n$5\nFunction: $fn, parameters: $7\n$fn failed with code $1 at line $lineno"
  local -r logfile="${8:-$BASH_FUNCTION_LOG}"

  bfl::writelog_fail "$msg" "$fn" "$logfile" && return 0 || return 1
  }
