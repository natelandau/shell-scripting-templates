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
# Defines function: bfl::MacOS::use_GNU_utils().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Add GNU utilities to PATH to allow consistent use of sed/grep/tar/etc. on MacOS.
#   GNU utilities can be added to MacOS using Homebrew
#
# @return Boolean $result
#    0 / 1     ( true / false )
#   PATH: Adds GNU utilities to the path
#
# @example
#   if ! bfl::MacOS::use_GNU_utils; then return 1; fi
#------------------------------------------------------------------------------
bfl::MacOS::use_GNU_utils() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }
  [[ "$os" == "mac" ]] || return 1

  declare -f "bfl::path_prepend" &>/dev/null || { bfl::writelog_fail "${FUNCNAME[0]} needs function bfl::path_prepend"; return 1; }

  local str=$(bfl::join_array ":" "/usr/local/opt/gnu-tar/libexec/gnubin" \
                                  "/usr/local/opt/coreutils/libexec/gnubin" \
                                  "/usr/local/opt/gnu-sed/libexec/gnubin" \
                                  "/usr/local/opt/grep/libexec/gnubin" \
                                  "/usr/local/opt/findutils/libexec/gnubin" \
                                  "/opt/homebrew/opt/findutils/libexec/gnubin" \
                                  "/opt/homebrew/opt/gnu-sed/libexec/gnubin" \
                                  "/opt/homebrew/opt/grep/libexec/gnubin" \
                                  "/opt/homebrew/opt/coreutils/libexec/gnubin" \
                                  "/opt/homebrew/opt/gnu-tar/libexec/gnubin" )

  bfl::path_prepend "$str" || return 1

  return 0
  }
