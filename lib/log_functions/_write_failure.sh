#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Write data to specified log.
#
# @param Array     BASH_LINENO aray
#   Array.
#
# @param Integer   BASH_LINENO
#   No of bash script line.
#
# @param String    FUNCNAME
#   Function name.
#
# @param Integer   ErrCode
#   Error code.
#
# @param String    BASH_COMMAND
#   Bash command.
#
# @param String    LogFile
#   Log file.
#
# @example
#   bfl::write_failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND" "$HOME/.faults"
#------------------------------------------------------------------------------
bfl::write_failure() {
  bfl::verify_arg_count "$#" 6 6 || exit 1  # Verify argument count.

  local lineno_fns=${1% 0}
  local lineno="$2"
  [[ "$lineno_fns" -ne 0 ]] && lineno+="$lineno_fns"  #      fn  lineno        local exitstatus msg
  local str="$(date '+%Y-%m-%d %H:%M:%S') ${BASH_SOURCE[-1]}:$3[$lineno] Failed with status $4: $5"
  echo "$str" >> $6
  echo "Written log message to $6: $str"

  return 0
  }
