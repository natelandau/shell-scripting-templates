#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Linux Systems
#
# @file
# Defines function: bfl::mount().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns the version string of the currently running kernel.
#
# @param  String  $DEVICE
#   The device providing the mount. This can be whatever device is supporting by the mount.
#
# @param  String  $DIR
#   The mount path for the mount.
#
# @param  String  $FSTYPE
#   The mount type.
#
# @param  String  $OPTIONS
#   A single string containing options for the mount, as they would appear in fstab.
#
# @return boolean $result
#        0 / 1 (true / false)
#
# @example
#   bfl::mount
#------------------------------------------------------------------------------
bfl::mount() {
  bfl::verify_arg_count "$#" 4 4 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 4"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  local -r device="${1:-}"
  local -r d="${2:-}"
  local -r fstype="${3:+"-t $3"}"
  local -r options="${4:+"-o $4"}"

  if ! [[ -d "$d" ]]; then
      { [[ $BASH_INTERACTIVE == true ]] && mkdir  -v "$d"    || mkdir "$d" ; }     || { bfl::writelog_fail "${FUNCNAME[0]} error mkdir '$d' )";     return 1; }
      { [[ $BASH_INTERACTIVE == true ]] && chmod -v 755 "$d" || chmod 755 "$d" ; } || { bfl::writelog_fail "${FUNCNAME[0]} error chmod 755 '$d' )"; return 1; }
  fi

  mount "$fstype" "$options" "$device" "$d" || { bfl::writelog_fail "${FUNCNAME[0]} error mount '$fstype' '$options' '$device' '$d' )"; return 1; }

  return 0
  }