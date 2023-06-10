#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to terminal and file logging
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::writelog_warn().
#------------------------------------------------------------------------------

# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #
# source "$(dirname $BASH_FUNCTION_LIBRARY)"/lib/log_functions/_write_log.sh

#------------------------------------------------------------------------------
# @function
# Prints passed Message on Log-Level warning to stdout.
#
# @param string $MESSAGE
#   Message to log.
#
# @example
#   bfl::writelog_warn "some string"
#------------------------------------------------------------------------------
#
bfl::writelog_warn() {
  bfl::verify_arg_count "$#" 1 1 || exit 1 # Нельзя bfl::die Verify argument count.

  local -r msg="${1:-}"
  bfl::write_log $LOG_LVL_WRN "${CLR_WARN}WARNING:${CLR_NORMAL} $msg"

  return 0
  }
