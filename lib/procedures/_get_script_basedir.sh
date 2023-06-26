#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_script_basedir().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Locates the real directory of the script being run. Similar to GNU readlink -n.
#
# @return String $result
#   Script real directory.
#
# @example
#   baseDir="$(bfl::get_script_basedir)"
#   cp "$(bfl::get_script_basedir "somefile.txt")" "other_file.txt"
#------------------------------------------------------------------------------
bfl::get_script_basedir() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Is file sourced?
  [[ ${_} != "$0" ]] && local -r -i i=1 || local -r -i i=0
  local _source="${BASH_SOURCE[$i]}"

  local _dir
  while [[ -h "${_source}" ]]; do # Resolve $SOURCE until the file is no longer a symlink
      #             $(dirname "${_source}")
      _dir="$(cd -P "${_source%/*}" && pwd)"
      _source="$(readlink "${_source}")"
      [[ ${_source} == /* ]] || _source="${_dir}/${_source}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done

  printf "%s\n" "$(cd -P "${_source%/*}" && pwd)"

  return 0
  }
