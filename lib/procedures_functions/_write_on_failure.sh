#!/usr/bin/env bash

# ----------- https://github.com/jmooring/bash-function-library.git -----------
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
  local lineno_fns=${1% 0}
  local lineno=$2; local str fn=$3
  [[ "$lineno_fns" != "0" ]] && lineno="${lineno} ${lineno_fns}"
#                                                  local exitstatus=$4; local msg=$5
  str="$(date '+%Y-%m-%d %H:%M:%S') ${BASH_SOURCE[-1]}:${fn}[${lineno}] Failed with status $4: $5"
  echo "$str" >> $6

  echo "$str"
  return 0
}
