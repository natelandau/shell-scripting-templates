#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  local str=`dirname $(which perl)`
  [[ (! -n $str) || ($str == $'/') ]] && str='' || str=`dirname $str`
  echo "$str"
  return 0
}
