#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Bash Strings
#
#
#
# @file
# Defines function: bfl::trimR().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Removes leading and trailing symbols (or evem substrings), from the end of string only.
#   The string ONLY single line
#
# @param String $str
#   The string to be trimmed.
#
# @param String $str (optional)
#   The symbols (or strings) to be removed.
#
# @return String $str_trimmed
#   The trimmed string.
#
# @example
#   bfl::trimR " foo "
#------------------------------------------------------------------------------
bfl::trimR() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}:${NC} no parameters"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local s="$1"
  local ptrn=' '  # space by default
  if [[ $# -gt 1 ]]; then
      local d
      shift
      for d in "$@"; do
          ptrn="$ptrn$d"
      done
  fi

  if [[ "$ptrn" =~ '"' ]]; then
      s=`echo "$s" | sed 's/^\(.*\)['"$ptrn"']*$/\1/'`
  else
      s=`echo "$s" | sed "s/^\(.*\)[$ptrn]*$/\1/"`
  fi

# ---------- https://github.com/natelandau/shell-scripting-templates ----------
    # ARGS:   $1 (Optional) - Character to trim. Defaults to [:space:]
    # USAGE:  text=$(_rtrim_ <<<"$1")
    #         printf "STRING" | _rtrim_
#    local _char=${1:-[:space:]}
#    sed "s%[${_char//%/\\%}]*$%%"

  echo "$s"
  return 0
  }
