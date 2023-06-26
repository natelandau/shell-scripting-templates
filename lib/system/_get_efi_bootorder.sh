#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Linux Systems
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_efi_bootorder().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns a string with the efibootmgr entry for the boot order (if it exists)
#   Note: This function requires the tool "efibootmgr" which may has to be installed manually
#
# @return String $result
#   Comma separated list.
#
# @example
#   bfl::get_efi_bootorder
#------------------------------------------------------------------------------
bfl::get_efi_bootorder() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _bootorder

  # Utilizing Process Substitution (http://tldp.org/LDP/abs/html/process-sub.html) to make the command output parsable
  while read -r line ; do
    if [[ "${line}" == BootOrder:* ]]; then
      _bootorder="${line#* }"
      break
    fi
  done < <(efibootmgr)
  [[ -z "${_bootorder}" ]] && return 1

  echo "${_bootorder}"
  return 0
  }
