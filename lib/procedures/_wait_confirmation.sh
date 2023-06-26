#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::wait_confirmation().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Seek user input for yes/no question.
#
# @param String $qstn
#   Question being asked.
#
# @return boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::wait_confirmation "Do something?" && printf "okay" || printf "not okay"
#      OR
#   if bfl::wait_confirmation "Answer this question"; then
#       something
#   fi
#------------------------------------------------------------------------------
bfl::wait_confirmation() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  input "${1}"
  if "${FORCE:-}"; then
      debug "Forcing confirmation with '--force' flag set"
      printf "%s\n" " "
      return 0
  fi

  local _yesNo
  while true; do
      read -r -p " (y/n) " _yesNo
      case ${_yesNo} in
          [Yy]*) return 0 ;;
          [Nn]*) return 1 ;;
          *) input "Please answer yes or no." ;;
      esac
  done
  }
