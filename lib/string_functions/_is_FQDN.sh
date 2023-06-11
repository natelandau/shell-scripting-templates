#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::is_FQDN().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if a given input is a fully qualified domain name.
#
# @param String $str
#   String to validate.
#
# @return boolean $result
#     0 / 1 (true / false)
#
# @example
#   bfl::is_FQDN "some.domain.com"
#------------------------------------------------------------------------------
#
bfl::is_FQDN() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  if printf "%s" "$1" | grep -Pq '(?=^.{4,253}$)(^(?:[a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+([a-zA-Z]{2,}|xn--[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])$)'; then
      return 0
  else
      return 1
  fi
  }
