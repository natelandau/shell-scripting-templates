#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Python
#
# @author  A. River
#
# @file
# Defines function: bfl::pip_upup().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Guided python update
#
# @example
#   bfl::pip_upup
#------------------------------------------------------------------------------
bfl::pip_upup() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # Verify argument values.
#  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local IFS fnc pipc pkgs pkg tmp

  fnc="${FUNCNAME[1]:-${FUNCNAME[0]}}"
  pipc=( ${fnc%_upup} --disable-pip-version-check )
  printf -v IFS   ' \t\n'

  {
      printf -v IFS   '\n'
      pkgs=(
          $(
              "${pipc[@]}" list -o
#                {
#                    { "${pipc[@]}" list -e | grep .; } \
#                        && { "${pipc[@]}" list -o | egrep '^(pip|setuptools) '; } \
#                        || { "${pipc[@]}" list -o; };
#                } 2>/dev/null
          )
      )
      printf -v IFS   ' \t\n'

      if [[ "${#pkgs[@]}" -gt 0 ]]; then

          if [[ $BASH_INTERACTIVE == true ]]; then
              printf "${fnc}: Proposed Updates..\n"
              printf '  %s\n' "${pkgs[@]}"
              printf "${fnc}: Install Updates? "
          fi
          read -p '' tmp

          if ! [[ $BASH_INTERACTIVE == true ]] || [[ "${tmp,,}" == [y]* ]]; then
              printf "${fnc}: Installing Updates\n"
              for pkg in "${pkgs[@]}"; do
                  if [[ "${pkg}" =~ \(Current:.*Latest:.*\) ]]; then
                      printf "\n${fnc}: %s\n" "Installing ${pkg}"
                      "${pipc[@]}" install -U "${pkg%% *}" 2>&1 |
                          egrep -e '^Requirement already up-to-date:' \
                                -e '^[[:blank:]]*Using cached' \
                                -e '^[[:blank:]]*Found existing installation:' \
                                -e '^[[:blank:]]*Uninstalling .*:' \
                                -v
                  elif [[ "${pkg}" =~ \(.*,.*\) ]]; then
                      printf '\n%s\n' "${pipc[0]}"' -v list -o 2>&1 | less -isR -p '"${pkg%% *}"
                  else
                      printf "${fnc}: %s\n" "ERROR: ${pkg}"
                  fi
              done

              printf -v IFS '\n'
              #pkgs=( $( { "${pipc[@]}" list -e | grep -q . || "${pipc[@]}" list -o; } 2>/dev/null ) )
              pkgs=( $( "${pipc[@]}" list -o ) )
              printf -v IFS ' \t\n'

              [[ "${#pkgs[@]}" -gt 0 ]] && { printf "\n${fnc}: Still Outdated\n"; printf '  %s\n' "${pkgs[@]}"; }
          fi
      else
          printf "${fnc}: No Outdated Packages\n"
      fi

  } 1>&2

  return 0
  }
