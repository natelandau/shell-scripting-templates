#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to screen and pictures.
#
# @author  A. River
#
# @file
# Defines function: bfl::grab2clip().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Captures screen to file.
#
# @param String $path
#   Directory to save capture.
#
# @param String $file_mask (optional)
#   File mask to save picture
#
# @example
#   bfl::grab2clip
#------------------------------------------------------------------------------
bfl::grab2file() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SCREENCAPTURE} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'screencapture' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]] || install -v -d "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed install -v -d '$1'"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: cannot create directory '$1'"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r file_mask=${2:-grab2file}
  local -r f="$1/${file_mask}_$(date '+%Y-%m-%d_%H-%M-%S').png"

  [[ $BASH_INTERACTIVE == true ]] && printf '\n# Interactive capture to ( %s )\n\n' "$f"
  screencapture -io "$f" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed screencapture -io '$f'"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  echo "$f"
  return 0
  }
