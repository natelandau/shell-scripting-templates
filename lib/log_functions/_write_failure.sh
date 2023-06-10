#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints the passed message to specified log depending on its log-level to stdout.
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
# @param String    LogFile (optional)
#   Log file.
#
# @example
#   bfl::write_failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND" "$HOME/.faults"
#------------------------------------------------------------------------------
bfl::write_failure() {
  bfl::verify_arg_count "$#" 5 7 || {   # Verify argument count.
      [[ $BASH_INTERACTIVE == true ]] && echo 'bfl::write_failure args count error'
      exit 1
      }

  local -r lineno_fns=${1% 0}
  [[ "$lineno_fns" -ne 0 ]] && local -r lineno="$2${lineno_fns}" || local -r lineno="$2"
  local -r fn="${3:-script}"
#          command
  local msg="$5 failed with code $4: ${BASH_SOURCE[-1]}:$fn[$lineno]"
  local -r logfile="${6:-$BASH_FUNCTION_LOG}"

  bfl::write_log $LOG_LVL_ERR "$msg" "$fn" "$logfile" || {
      [[ $BASH_INTERACTIVE == true ]] && echo "Error write_log $msg"
      return 1
      }

  if [[ $BASH_INTERACTIVE == true ]]; then
      echo "$msg"
      echo "Written log message to $logfile"
  fi

  return 0
  }
