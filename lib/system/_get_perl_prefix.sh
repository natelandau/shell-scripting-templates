#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::get_perl_prefix().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets directory path of perl
#
# @return String $perl_prefix
#   The Perl library prefix.
#
# @example
#   bfl::get_perl_prefix
#------------------------------------------------------------------------------
bfl::get_perl_prefix() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_PERL} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'perl' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local str
  str=$(which perl)
  str="${str%/*}"

  [[ ( -z "$str") || ("$str" == $'/') ]] && str="" || str="${str%/*}"   # str=$(dirname "$str")
  echo "$str"
  return 0
  }
