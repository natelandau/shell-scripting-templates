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
# Defines function: bfl::get_efi_entry().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns an associative array (string representation) with the efibootmgr entry for FILE if it exists.
#
# @param  String  $IDENTIFIER
#   BootNum or Path of an '.efi' file like it is used in the efibootmgr entries (e.g. '\EFI\gentoo\vmlinuz-4.4.6-gentoo.efi').
#
# @return String $result
#   String representation of an associative array (e.g. '( [bootnum]="0001" [label]="Gentoo Linux 4.4.6" [loader]="\EFI\GENTOO\VMLINUZ-4.4.6-GENTOO.EFI" )').
#
# @example
#   bfl::get_efi_entry
#------------------------------------------------------------------------------
bfl::get_efi_entry() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r IDENTIFIER="${1:-}"; shift
  local entry_identifier

  if bfl::is_hex_number "$IDENTIFIER"; then
    (( ${#IDENTIFIER} > 4 )) && { bfl::writelog_fail "Invalid value for 'BOOTNUM', must be hexadecimal but was '$IDENTIFIER'"; return ${BFL_ErrCode_Not_verified_arg_values}; }
    entry_identifier="boot${IDENTIFIER}"
  else
    entry_identifier="$( bfl::string_replace "$IDENTIFIER" '/' '\' )"
    entry_identifier="file(${entry_identifier,,})"
  fi

  # Utilizing Process Substitution (http://tldp.org/LDP/abs/html/process-sub.html) to make the command output parsable
  local -A efi_entry
  while read -r line ; do
    # If we have a boot entry that contains our search string, we have the right one
    if [[ "$line" =~ ^Boot[[:digit:]]{4}.*$ ]] && [[ "${line,,}" == *"${entry_identifier}"* ]]; then
      # Use a regular expression to extract the boot entry attributes
      if [[ "${line}" =~ ^Boot([[:digit:]]{4})\*?[[:space:]]+(.+)[[:space:]]+HD\(.+\)/File\((.*)\).*$ ]]; then
        efi_entry=( [bootnum]="${BASH_REMATCH[1]}" [label]="${BASH_REMATCH[2]}" [loader]="${BASH_REMATCH[3]}" )
      fi
      break
    fi
  done < <(efibootmgr -v)

  [[ -z "${efi_entry[bootnum]}" ]] || [[ -z "${efi_entry[label]}" ]] || [[ -z "${efi_entry[loader]}" ]] && return 1

  # Serialize the array that contains the boot entry ('declare -p' prints out the array constructor, which then is stripped down to the array string)
  local -r EFI_ENTRY_SERIALIZED=$( declare -p efi_entry )
  printf "${EFI_ENTRY_SERIALIZED#*=}"

  return 0
  }
