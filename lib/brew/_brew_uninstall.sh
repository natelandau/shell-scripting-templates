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
# Defines function: bfl::brew_uninstall().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Uninstalls brew.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_uninstall
#------------------------------------------------------------------------------
bfl::brew_uninstall() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  declare fnc ents ent
  fnc="${FUNCNAME}"
  ents=(
      Library/Aliases
      Library/Contributions
      Library/Formula
      Library/Homebrew
      Library/LinkedKegs
      Library/Taps
      .git
      '~/Library/*/Homebrew'
      '/Library/Caches/Homebrew/*'
  )

  hash -r
  export HOMEBREW_PREFIX
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$( brew --prefix )}"

  {

      if [[ -n "${HOMEBREW_PREFIX}" ]]; then
          cd "${HOMEBREW_PREFIX}"/. >/dev/null 2>&1
          if [[ "${?}" -ne 0 ]]; then
              printf "${fnc}: %s\n" "ERROR: Could not change directory { ${HOMEBREW_PREFIX} }"
          fi
      else
          printf "${fnc}: %s\n" "ERROR: Could not determine HOMEBREW_PREFIX"
      fi

      if [[ -e Cellar/. ]]; then
          printf "${fnc}: %s\n" "Removing Cellar"
          command rm -rf Cellar || return 255
      fi

      if [[ -x bin/brew ]]; then
          printf "${fnc}: %s\n" "Brew Pruning"
          bin/brew prune || return 254
      fi

      if [[ -d .git/. ]]; then
          printf "${fnc}: %s\n" "Removing GIT Data"
          git checkout -q master || return 253
          { git ls-files | tr '\n' '\0' | xargs -0 rm -f; } || return 252
      fi

      for ent in "${ents[@]}"; do
          [[ -n "${ent}" ]] || continue
          if [[ $( eval ls -1d "${ent}" >/dev/null 2>&1 ) ]]; then
          printf "${fnc}: %s\n" "Removing { ${ent} }"
          eval command rm -rf "${ent}"
          fi
      done

      [[ $BASH_INTERACTIVE == true ]] && printf "${fnc}: %s\n" "Removing Broken SymLinks"
      find -L . -type l -exec rm -- {} +
      [[ $BASH_INTERACTIVE == true ]] && printf "${fnc}: %s\n" "Removing Empty Dirs"
      find . -depth -type d -empty -exec rmdir -- '{}' \; 2>/dev/null

  } 1>&2


  return 0
  }
