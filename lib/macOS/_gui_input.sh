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
# Defines function: bfl::MacOS::have_scriptable_finder().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Ask for user input using a Mac dialog box.
#
# @param String $text
#   Text in dialogue box (Default: Password).
#
# @return Boolean $result
#     0 / 1   ( true / false )
#   MacOS dialog box output / no output
#
# @example
#   bfl::MacOS::have_scriptable_finder
#------------------------------------------------------------------------------
bfl::MacOS::have_scriptable_finder() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }
  [[ "$os" == "mac" ]] || return 1

  bfl::MacOS::have_scriptable_finder || { [[ $BASH_INTERACTIVE == true ]] && printf "No GUI input without macOS\n"; return 1; }

  local _guiPrompt="${1:-Password:}"
  local _guiInput

  _guiInput=$(
      osascript &>/dev/null <<GUI_INPUT_MESSAGE
      tell application "System Events"
          activate
          text returned of (display dialog "${_guiPrompt}" default answer "" with hidden answer)
      end tell
GUI_INPUT_MESSAGE
  )
  printf "%s\n" "${_guiInput}"

  return 0
  }
