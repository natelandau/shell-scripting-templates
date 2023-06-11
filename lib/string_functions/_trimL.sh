#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::trimL().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes leading and trailing symbols (or evem substrings), from the beginning of string only.
#
# The string ONLY single line
#
# @param string $str
#   The string to be trimmed.
#
# @param string $str (optional)
#   The symbols (or strings) to be removed.
#
# @return string $str_trimmed
#   The trimmed string.
#
# @example
#   bfl::trimL " foo "
#------------------------------------------------------------------------------
bfl::trimL() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return 1; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}:${NC} no parameters" && return 1

  local s="$1"
  local ptrn=' '  # space by default
  if [[ $# -gt 1 ]]; then
      local d
      shift
      for d in "$@"; do
          ptrn="$ptrn$d"
      done
  fi

  [[ "$ptrn" =~ '"' ]] && s=`echo "$s" | sed 's/^['"$ptrn"']*\(.*\)$/\1/'` || s=`echo "$s" | sed "s/^[$ptrn]*\(.*\)$/\1/"`
  echo "$s"
  return 0
  }