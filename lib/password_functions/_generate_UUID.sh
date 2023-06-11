#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::generate_UUID().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Generates an UUID.
#
# @return String $uuid
#   A random UUID.
#
# @example
#   bfl::generate_UUID
#------------------------------------------------------------------------------
bfl::generate_UUID() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return 1; }   # Verify argument count.

  local c="89ab"
  local b n

  for ((n=0; n < 16; ++n)); do
      b="$((RANDOM % 256))"

      case "$n" in
          6) printf '4%x' "$((b % 16))" ;;
          8) printf '%c%x' "${c:${RANDOM}%${#c}:1}" "$((b % 16))" ;;
          3 | 5 | 7 | 9)
              printf '%02x-' "$b" ;;
          *)
              printf '%02x' "$b" ;;
      esac
  done

  printf '\n'
  }