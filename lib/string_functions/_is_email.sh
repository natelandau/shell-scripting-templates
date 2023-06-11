#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::is_email().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Validates that input is a valid email address.
#
# @param string $value_to_test
#   The value to be tested.
#
# @return boolean $result
#        0 / 1 (true / false)
#
# @example
#   bfl::is_email "somename+test@gmail.com"
#------------------------------------------------------------------------------
#
bfl::is_email() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  #shellcheck disable=SC2064
  trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
  shopt -s nocasematch                  # Use case-insensitive regex

#               ${regex}
  local -r regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
  [[ "$1" =~ $regex ]] && return 0 || return 1
  }
