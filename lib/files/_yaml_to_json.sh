#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::yaml_to_json().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Converts a YAML file to JSON.
#
# @param String $file
#   Input YAML file.
#
# @return String $JSON
#   JSON.
#
# @example
#
#------------------------------------------------------------------------------
bfl::yaml_to_json() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' <"$1"
  return 0
  }
