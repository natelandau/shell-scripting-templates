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
# Defines function: bfl::partition_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if PARTITION exists in the local system.
#
# @param  String  $PARTITION
#   Device path of the partition (e.g. '/dev/sda1').
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::partition_exists '/dev/sda1'
#------------------------------------------------------------------------------
bfl::partition_exists() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # If the string is empty or does not follow the device notation, quit
  { bfl::is_blank "$1" || ! [[ "$1" =~ ^\/dev\/(hd|sd)[[:lower:]][[:digit:]]$ ]] ; } && { return 1; }

  blkid "$1" &>/dev/null
  return 0
  }
