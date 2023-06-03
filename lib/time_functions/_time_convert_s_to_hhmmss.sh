#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://github.com/jmooring/bash-function-library.git -----------
# @file
# Defines function: bfl::time_convert_s_to_hhmmss().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Converts seconds to the hh:mm:ss format.
#
# @param int $seconds
#   The number of seconds to convert.
#
# @return string $hhmmss
#   The number of seconds in hh:mm:ss format.
#
# @example
#   bfl::time_convert_s_to_hhmmss "3661"
#------------------------------------------------------------------------------
bfl::time_convert_s_to_hhmmss() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  bfl::is_positive_integer "$seconds" || bfl::die "Expected positive integer, received $seconds."

  declare -r seconds="$1"
  declare hhmmss

  hhmmss=$(printf '%02d:%02d:%02d\n' $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))) \
    || bfl::die "Unable to convert $seconds to hh:mm:ss format."

  printf "%s" "$hhmmss"
  }
