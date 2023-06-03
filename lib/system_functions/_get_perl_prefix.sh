#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_perl_prefix().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets directory path of perl
#
# @return string $perl_prefix
#   The Perl library prefix.
#
# @example
#   bfl::get_perl_prefix
#------------------------------------------------------------------------------
bfl::get_perl_prefix() {
  bfl::verify_arg_count "$#" 0 0 || exit 1  # Verify argument count.

  local str=$(dirname $(which perl))
  [[ (! -n $str) || ($str == $'/') ]] && str='' || str=`dirname $str`
  echo "$str"
  return 0
  }
