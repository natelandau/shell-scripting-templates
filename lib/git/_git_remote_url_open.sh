#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Git commands
#
# @author  A. River
#
# @file
# Defines function: bfl::git_remote_url_open().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @param String $branch_type
#   First argument must be number of loop iterations to run.
#
# @param String $paths
#   Path list.
#
# @example
#   bfl::git_remote_url_open origin ...
#   bfl::git_remote_url_open upstream ...
#------------------------------------------------------------------------------
bfl::git_remote_url_open() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found";   return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: no branch_type defined!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r typ="${1}"; shift

  declare vars=(d src url)
  declare ${vars[*]}

  [[ "${#@}" -gt 0 ]] && local -a dirs=( "${@}" ) || local -a dirs=( . )

  for d in "${dirs[@]}"; do
      src="$( git config remote.${typ}.url )" || { bfl::writelog_fail "${FUNCNAME[0]}: git config 'remote.${typ}.url'"; return 1; }
      printf "# %s\t= %s\t@ " "${d}" "${src}"
      [[ "${src}" =~ ^([^@]*)@([^:/]*):(.*)$ ]] && url="https://${BASH_REMATCH[2]}/${BASH_REMATCH[3]%.git}"
      printf "%s\n" "${url}"
      [[ -n "${url}" ]] && { open "${url}"; continue; }
      printf "  Did not open URL\n"
  done

  return 0
  }
