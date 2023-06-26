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
# Defines function: bfl::get_efi_least_entry().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns of all EFI bootloader entries matching the OS_ID the one with the lowest boot priority, as long as there will be KEEP others left.
#
# @param  String  $OS_ID
#   Identifier that limits the search.
#
# @param  Integer  $KEEP
#   Number of entries that should be kept (Default: 2).
#
# @return String $result
#   String representation of an associative array (e.g. '( [bootnum]="0001" [label]="Gentoo Linux 4.4.6" [loader]="\EFI\GENTOO\VMLINUZ-4.4.6-GENTOO.EFI" )').
#
# @example
#   bfl::get_efi_least_entry
#------------------------------------------------------------------------------
bfl::get_efi_least_entry() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r KEEP="${2:-2}"

  # Verify argument values.
  bfl::is_blank "$1"      && { bfl::writelog_fail "${FUNCNAME[0]}: OS Id was not specified!";   return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_integer ${KEEP} || { bfl::writelog_fail "${FUNCNAME[0]}: 'KEEP' must be an integer!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r OS_ID="${1,,}"

  # Alternative implementation: Iterate Boot Order and select the first entry that matches the filter ("\EFI\<OS_ID>\*.EFI")
  local result
  local -i counter=0

  local -a bootorder=$( String::split "$( System::Efi::get_bootorder )" "," )
  for (( i=${#bootorder[@]}-1 ; i>=0 ; i-- )) ; do
    local efi_entry="$( System::Efi::get_entry "${bootorder[$i]}" )"

    local -A efi_entry_array=${efi_entry}
    local loader=$( String::to_lowercase "${efi_entry_array[loader]}" )
    if [[ ${loader} =~ ^\\efi\\${OS_ID}\\[[:print:]]+\.efi$ ]]; then
      [[ -z ${result} ]] && {
        result="${efi_entry}"
      }
      (( counter++ ))
    fi

    (( counter > KEEP )) && {
      echo "${result}"
      break
    }
  done

  return 0
  }
