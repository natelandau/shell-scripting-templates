#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to terminal
#
#
#
# @file
# Defines function: bfl::terminal_update_size().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks the size of the terminal window.  Updates LINES/COLUMNS if necessary.
#
# @example
#   bfl::terminal_update_size
#------------------------------------------------------------------------------
bfl::terminal_update_size() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }              # Verify argument count.
#  $(bfl::is_Terminal) || { bfl::writelog_fail "${FUNCNAME[0]}: no terminal found"; return 1; }  # Do nothing if the output is not a terminal
  bfl::verify_dependencies "shopt" "trap" || { bfl::writelog_fail "${FUNCNAME[0]}: dependency tput not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  shopt -s checkwinsize && (: && :)
  trap 'shopt -s checkwinsize; (:;:)' SIGWINCH
  return 0
  }
