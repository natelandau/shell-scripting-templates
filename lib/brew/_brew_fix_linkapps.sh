#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to brew
#
# @author  A. River
#
# @file
# Defines function: bfl::brew_fix_linkapps().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_fix_linkapps
#------------------------------------------------------------------------------
bfl::brew_fix_linkapps() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_BREW} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'brew' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local IFS apps app applnk lnk str
  printf -v IFS '\t'
  [[ $BASH_INTERACTIVE == true ]] && printf '\n# Generating Apps List and Updating Links ..\n'
  str=$(brew linkapps 2>&1 | grep -o '[^/]*\.app' | sort -u | tr '\n' '\t' )
  apps=($str)
  printf -v IFS ' \t\n'
  apps=("${apps[@]/#//Applications/}")
  [[ $BASH_INTERACTIVE == true ]] && printf '\n'
  for app in "${apps[@]}"; do
      [[ -z "${app}" ]] || ! [[ -e "${app}" ]] || {
          [[ $BASH_INTERACTIVE == true ]] && printf '# Removing .. %s\n' "${app}"
          rm -i -rf "${app}"
          }
  done

  [[ $BASH_INTERACTIVE == true ]] && printf '\n# Generating Apps Links ..\n'
  brew linkapps
  for app in "${apps[@]}"; do
      applnk="${app}.linkapps_fix"
      [[ $BASH_INTERACTIVE == true ]] && printf '\n# Moving link .. %s\n' "${applnk}"
      rm -i -f "${applnk}"
      mv -i -vf "${app}" "${applnk}"
      lnk="$( ls -lond "${applnk}" | sed -n 's=.* -> ==p' )"
      [[ $BASH_INTERACTIVE == true ]] && printf '# Generating Fixed Links .. %s .. %s\n' "${app}" "${lnk}"
      mkdir "${app}"
      ln -vnfs "${lnk}"/* "${app}"/
      chmod -R a+rx "${app}"
      [[ $BASH_INTERACTIVE == true ]] && printf '# Removing .. %s\n' "${applnk}"
      rm -i -vf "${applnk}"
  done

  return 0
  }
