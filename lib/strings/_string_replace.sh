#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::string_replace().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Replace substring in string
#
# Bash StrReplace analog
#
# @param String $main_string
#   String where replacement executes.
#
# @param String $search_string
#   The sequence of char values to be replaced.
#
# @param String $new_string
#   The replacement sequence of char values.
#
# @return String $result
#   String with escaped special characters.
#
# @example
#   bfl::string_replace "/home/alexei/.local/lib/site-packages" "/home/alexei/.local" "/usr"
#------------------------------------------------------------------------------
bfl::string_replace() {
  bfl::verify_arg_count "$#" 3 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 3"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ -z "$2" ]] && { echo "$1"; return 0; }

  local srch="${1:-}"; #local substr=$2; local rplce=$3
  # Escaping special characters in TARGET and REPLACEMENT
  local -r TARGET="$( sed -e 's/[]\/$*.^|[]/\\&/g' <<<"${2:-}" )"      # echo $substr
  local -r REPLACEMENT="$( sed -e 's/[\/&]/\\&/g' <<<"${3:-}" )"

# Is true when either TARGET or REPLACEMENT are not specified (-> the call only has one or two parameters)
  while [[ "$srch" =~ "${TARGET}" ]]; do
      srch=$(echo "$srch" | sed "s/${TARGET}/${REPLACEMENT}/g")   # s|$str|$rplce|g
  done

  echo "$srch"
  return 0
  }
