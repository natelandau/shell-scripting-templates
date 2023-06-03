#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::write_on_failure().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Writes error description to user log.
#
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
#
# @param string $bash_lineno_array
#   ${BASH_LINENO[*]}
#
# @param string $lineno
#   $LINENO
#
# @param string $function_name
#   $LINENO
#
# @param string $error_code
#   The error code
#
# @param string $command
#   Bash command
#
# @param string $logfile_name
#   Name of log file
#
# @example
#   trap 'bfl::write_on_failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND" "$HOME/.faults"' ERR
#------------------------------------------------------------------------------
bfl::write_on_failure() {
#  On error thre is no time to check arguments
#  bfl::verify_arg_count "$#" 6 16 || exit 1  # Verify argument count.

  local -r lineno_fns="${1% 0}"
  local lineno="$2"
  local -r fn="$3"
  [[ "$lineno_fns" != "0" ]] && lineno="$lineno $lineno_fns"

  local str
#                                                  local exitstatus=$4; local msg=$5
  str="$(date '+%Y-%m-%d %H:%M:%S') ${BASH_SOURCE[-1]}:$fn[$lineno] Failed with status $4: $5"
  echo "$str" >> $6

  echo "$str"
  return 0
  }
