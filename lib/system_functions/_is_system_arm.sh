#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh
# @file
# Defines function: bfl::is_system_arm().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines arm architecture
#
# @return Boolean   $value
#    if getconf is available, it will return the arch of the OS, as desired
#   0 / 1   (true / false)
#
# @example
#   bfl::is_system_aarch64
#------------------------------------------------------------------------------
bfl::is_system_arm() {
  bfl::verify_arg_count "$#" 0 0 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 0"  # Verify argument count.

  [[ "$(bfl::get_system_architecture)" = 'arm' ]]
  }
