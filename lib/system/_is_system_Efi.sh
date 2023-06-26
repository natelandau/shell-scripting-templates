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
# Defines function: bfl::is_system_Efi().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if the system supports the EFI bootloader.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_system_Efi
#------------------------------------------------------------------------------
bfl::is_system_Efi() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # '/sys/firmware/efi' is only available on systems that are booted using EFI
  # 'efibootmgr' is required when working with EFI, so its not wrong to test for it too
  [[ -d /sys/firmware/efi ]] && efibootmgr &>/dev/null
  return 0
  }
