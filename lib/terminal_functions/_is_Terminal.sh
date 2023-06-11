#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::is_Terminal.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Check is script is run in an interactive terminal.
#
# @return Boolean $result
#   0 / 1   true / false
#
# @example
#   bfl::is_Terminal
#------------------------------------------------------------------------------
bfl::is_Terminal() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return 1; } # Verify argument count.

  [[ -t 1 || -z "$TERM" ]] && return 0 || return 1
  }
