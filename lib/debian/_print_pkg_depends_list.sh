#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to the Debian
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::print_pkg_depends_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints required packages list for Debian package.
#
# @param String $pkg
#   Debian package.
#
# @example
#   bfl::print_pkg_depends_list "libapr1"
#------------------------------------------------------------------------------
bfl::print_pkg_depends_list() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1";       return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_DPKG} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'dpkg' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  local str state t
  str=$(bfl::get_pkg_depends_list "$1")
  bfl::is_blank "$str" && { bfl::writelog_fail "${FUNCNAME[0]}: Failed bfl::get_pkg_depends_list '$1'"; return 1; }

  local -a arr=($str) # массив автоматом делит строку по пробелам
  for t in ${arr[@]}; do
      str=`dpkg --status "$t" | sed -n '/^Status:/p' | sed 's/^Status: install //'` #Status: install
      [[ "$str" == 'ok installed' ]] && state="${Green}$str${NC}" || state="${Red}not installed${NC}"
      [[ $BASH_INTERACTIVE == true ]] && printf '%-25s %s\n' "$t" "Status: $state" > /dev/tty
  done

  return 0
  }
