#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  A. River
#
# @file
# Defines function: bfl::json_tidy().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Reads input ?
#
# @param String $path (optional)
#   Directory to search broken symlinks. (Default current directory)
#
# @return String $result
#   Files list.
#
# @example
#   bfl::json_tidy /path
#------------------------------------------------------------------------------
bfl::json_tidy() {
#  bfl::verify_arg_count "$#" 0 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  bfl::verify_dependencies "python" || { bfl::writelog_fail "${FUNCNAME[0]}: dependency find not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  python -c "import sys;import json;print(json.dumps(json.loads(sys.stdin.read()), ensure_ascii=1, sort_keys=1, indent=2, separators=(',',': ')));sys.exit(0)"
  }
