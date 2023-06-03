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
# Defines function: bfl::writelog_fail().
#------------------------------------------------------------------------------

# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #
! [[ $_GUARD_BFL_log_functions_write_log -eq 1 ]] && source "$(dirname $BASH_FUNCTION_LIBRARY)"/lib/log_functions/_write_log.sh

#------------------------------------------------------------------------------
# @function
# Prints passed Message with an 'fail' at the end of the line to stdout.
#
# @param string $MESSAGE
#   Message to log.
#
# @example
#   bfl::writelog_fail "Some string ...."
#------------------------------------------------------------------------------
#
bfl::writelog_fail() {
#  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  local -r msg="${1:-}"
  bfl::write_log $LOG_LVL_ERR "$msg" "${CLR_BRACKET}[${CLR_BAD} fail ${CLR_BRACKET}]${CLR_NORMAL}"

  return 0
  }
