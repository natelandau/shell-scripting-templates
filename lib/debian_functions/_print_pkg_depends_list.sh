#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::print_pkg_depends_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Print required packages list for Debian package.
#
# @param string $pkg
#   Debian package.
#
# @example
#   bfl::print_pkg_depends_list "libapr1"
#------------------------------------------------------------------------------
bfl::print_pkg_depends_list() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  local str state arr t
  str=$(bfl::get_pkg_depends_list "$1")

  arr=($str) # массив автоматом делит строку по пробелам
  for t in ${arr[@]}; do
      str=`dpkg --status "$t" | sed -n '/^Status:/p' | sed 's/^Status: install //'` #Status: install
      [[ "$str" == 'ok installed' ]] && state="${Green}$str${NC}" || state="${Red}not installed${NC}"
      [[ $BASH_INTERACTIVE == true ]] && printf '%-25s %s\n' "$t" "Status: $state" > /dev/tty
  done

  return 0
  }
