#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to the Debian
#
# @file
# Defines function: bfl::is_debian_pkg_installed().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Simple function to check if a given debian package is installed.
#
# @param string $PKG_NAME
#   Debian package name.
#
#
# @return boolean $exists
#        0 / 1 (true/false)
#
# @example
#   bfl::is_debian_pkg_installed "gcc1"
#------------------------------------------------------------------------------
bfl::is_debian_pkg_installed() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.
  bfl::verify_dependencies "dpkg"           # Verify dependencies.

  local str
  str=$(dpkg --status "$1" 2>/dev/null | sed -n '/^Status:/p')
  [[ "$str" == 'Status: install ok installed' ]] && return 0

  return 1
  }
