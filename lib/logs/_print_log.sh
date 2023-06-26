#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to terminal and file logging
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::print_log().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints the passed message depending on its log-level to stdout.
#
# @param String $msg
#   Message to log.
#
# @param Integer $LEVEL (Optional)
#   Log level of the message.
#
# @param String $STATUS (Optional)
#   Short status string, that will be displayed right aligned in the log line.
#
# @example
#   bfl::print_log "some string"
#------------------------------------------------------------------------------
bfl::print_log() {
  [[ $BASH_INTERACTIVE == true ]] || return 0
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 3 || { # Нельзя bfl::die
      printf "${FUNCNAME[0]}: error $*\n" > /dev/tty
      return 1
      }
  [[ ${_BFL_HAS_TPUT} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency tput not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify arguments
  bfl::is_blank "$1" && { # Нельзя bfl::die
      printf "${FUNCNAME[0]}: parameter 1 is blank!\n" > /dev/tty
      return 1
      }

  local msg="${1:-}"
  local -r LEVEL=${2:-$LOG_LVL_DEBUG}
  local -r STATUS=${3:-}


  if [[ ${LOG_LEVEL} -ge ${LEVEL} ]]; then
      [[ ${LOG_SHOW_TIMESTAMP} = true ]] && msg="$(date) - ${msg}"

      # To display a right aligned status we have to take some extra efforts
      if [[ -z "$STATUS" ]]; then
          echo "$msg"
      else
          # Filter formatting sequences from the STATUS string to get its displayed length
          # https://stackoverflow.com/a/52781213/10495078
          local -r STATUS_filtered="$( sed -E -e "s/\x1B(\[[0-9;]*[JKmsu]|\(B)//g" <<< "$STATUS" )"
          let message_width=$(tput cols)-${#STATUS_filtered}

          printf "\r%-*s%s\n" ${message_width} "$msg" "$STATUS"
      fi
  fi

  return 0
  }
