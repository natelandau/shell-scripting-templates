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
# Defines function: bfl::brew_install().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Loads brew from web and installs to directory.
#
# @param String $path
#   Directory to make backup.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_install '/usr/local'
#------------------------------------------------------------------------------
bfl::brew_install() {
  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_CURL} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'curl' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_RUBY} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'ruby' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]] || install -v -d "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed install -v -d '$1'"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: cannot create directory '$1'"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local fnc precmd cmderr umask_bak
  fnc="${FUNCNAME}"
  precmd=
  cmderr=0
  umask_bak="$( umask )"
  umask 0002

  {
      [[ $BASH_INTERACTIVE == true ]] && printf "${fnc}: %s\n" "Setting up { $1 }"
      while :; do
          {
          "${precmd[@]}" mkdir -p           "$1"/bin
          "${precmd[@]}" chgrp -R admin     "$1"/.
          "${precmd[@]}" chmod -R g+rwX,o+X "$1"/.
          #"${precmd[@]}" find               "$1"/. -type d -exec chmod g+s '{}' \;
          } 2>/dev/null
          cmderr="${?}"
          if [[ "${cmderr}" -gt 0 ]]; then
              if [[ "${precmd[0]}" == 'sudo' ]]; then
                  bfl::writelog_fail "${FUNCNAME[0]}: %s\n" "ERROR: Could not setup { $1 }"   # ${fnc}:
                  return 255
              else
                  precmd=( sudo -p "${fnc}: Need administrator privileges: " )
                  continue
              fi
          fi
          break
      done

      printf "${fnc}: %s\n" "Status of involved directories."
      ls -ld "$1"/. "$1"/*

      printf "${fnc}: %s\n" "Install Homebrew."
      ruby -e "$(curl -fL 'https://raw.githubusercontent.com/Homebrew/install/master/install')"
#        curl -L https://github.com/Homebrew/homebrew/tarball/master |
#            tar xz --strip 1 -C "${prefix}"

#        printf "${fnc}: %s\n" "Create symlink for { brew }."
#        ln -vnfs "${prefix}/bin/brew" "$1"/bin/brew
#
#        printf "${fnc}: %s\n" "Update Homebrew."
#        "$1"/bin/brew update

      umask "${umask_bak}"
  } 1>&2

  return 0
  }
