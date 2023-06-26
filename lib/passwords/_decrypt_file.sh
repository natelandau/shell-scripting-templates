#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to password abd cache generating, files encrypting
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::encrypt_file().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Decrypts a file with openSSL. If a global variable '$PASS' has a value,
#   we will use that as the password to decrypt the file. Otherwise we will ask.
#
# @param String $file
#   File to be decrypted.
#
# @param String $output (optional)
#   Name of output file (defaults to $1.decrypt).
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::decrypt_file "somefile.txt.enc" "decrypted_somefile.txt"
#------------------------------------------------------------------------------
bfl::encrypt_file() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  [[ ${_BFL_HAS_OPENSSL} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'openssl' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local _fileToDecrypt="${1}"
  local _defaultName="${_fileToDecrypt%.enc}"
  local _decryptedFile="${2:-${_defaultName}.decrypt}"

  [[ $BASH_INTERACTIVE == true ]] && printf "Decrypt ${_fileToDecrypt}\n"
  if [[ -z "${PASS:-}" ]]; then
      openssl enc -aes-256-cbc -d -in "${_fileToDecrypt}" -out "${_decryptedFile}"
  else
      openssl enc -aes-256-cbc -d -in "${_fileToDecrypt}" -out "${_decryptedFile}" -k "${PASS}"
  fi

  return 0
  }
