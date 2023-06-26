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
# Defines function: bfl::is_efi_boot_partition().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if PARTITION is used by the EFI bootloader.
#
# @param  String  $PARTITION
#   Device path of the partition (e.g. '/dev/sda1').
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_efi_boot_partition '/dev/sda1'
#------------------------------------------------------------------------------
bfl::is_efi_boot_partition() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::partition_exists "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: Partition '$1' doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  local -r PARTITION="${1:-}"

  # EFI partitions have to be Fat32
  local PARTITION_TYPE RESULT TMP_MOUNT_DIR
  PARTITION_TYPE=$( blkid -o value -s TYPE "$PARTITION" )
  [[ "$PARTITION_TYPE" != "vfat" ]] && return 1

  # And they have to contain an "EFI" folder
  TMP_MOUNT_DIR="$( mktemp -d )"
  if [[ -d "${TMP_MOUNT_DIR}" ]]; then
    mount -t vfat "$PARTITION" "${TMP_MOUNT_DIR}"
    RESULT=$( [[ -d "${TMP_MOUNT_DIR}/EFI" ]] )$?

    umount "${TMP_MOUNT_DIR}"
    rm -rf "${TMP_MOUNT_DIR}"
  fi

  [[ "${RESULT}" -eq "0" ]]

  return 0
  }
