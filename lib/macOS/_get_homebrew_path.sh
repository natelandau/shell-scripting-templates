#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# https://github.com/herrbischoff/awesome-osx-command-line/blob/master/functions.md
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions for use on computers running MacOS
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::MacOS::set_homebrew_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Add homebrew bin dir to PATH.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#   PATH: Adds GNU utilities to the path
#
# @example
#   if ! bfl::MacOS::set_homebrew_path; then return 1; fi
#------------------------------------------------------------------------------
bfl::MacOS::set_homebrew_path() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ ${_BFL_HAS_UNAME} -eq 1 ]] && { # if has_uname
      local os
      os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }
      if [[ "$os" == "mac" ]]; then #  | tr '[:upper:]' '[:lower:]' | grep -q 'darwin'
          bfl::path_prepend "/usr/local/bin:/opt/homebrew/bin" || return 1
          return 0
      fi
  }
  # else ???
  bfl::path_prepend "/usr/local/bin:/opt/homebrew/bin" || return 1

  return 0
  }
