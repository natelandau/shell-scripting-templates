#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Firefox
#
# @author  A. River
#
# @file
# Defines function: bfl::firefox_places_sqlite3().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs curl with Mozilla header.
#
# @param String $firefox_profiles
#   Firefox profiles directory.
#
# @param String $args
#   sqlite3 arguments. Remainder of arguments can be pretty much anything you would otherwise provide to sqlite3.
#
# @example
#   bfl::firefox_places_sqlite3 "$HOME/Library/Application Support/Firefox/Profiles" ...
#------------------------------------------------------------------------------
bfl::firefox_places_sqlite3() {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]";   return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SQLITE3} -eq 1 ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sqlite3' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: Firefox profiles folder is required.";         return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: Firefox profiles folder '$1' doesn't exist!";  return ${BFL_ErrCode_Not_verified_arg_values}; }
  ff_profile_dir="$1"; shift

  local ent opt_done places ff_profile_dir
  declare -a sqls=()
  declare -a opts=()
  places="$( ls -1rt "${ff_profile_dir}"/*/places.sqlite | tail -1 )"
  opt_done=0
  for ent in "${@}"; do
      if [[ "${ent}" == '--' ]]; then
          opt_done=1
          continue
      fi
      if [[ "${opt_done}" -gt 0 ]]; then
          sqls[${#sqls[@]}]="${ent}"
      else
          opts[${#opts[@]}]="${ent}"
      fi
  done
  sqlite3 "${opts[@]}" "${places}" "${sqls[@]}"

  return 0
  }
