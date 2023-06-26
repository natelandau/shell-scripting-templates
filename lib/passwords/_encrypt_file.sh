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
#   Encrypts a file using openSSL. If a variable '$PASS' has a value,
#   we will use that as the password for the encrypted file. Otherwise ask.
#
# @param String $file
#   Input file.
#
# @param String $output (optional)
#   Name of output file (defaults to $1.enc).
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::encrypt_file "somefile.txt" "encrypted_somefile.txt"
#------------------------------------------------------------------------------
bfl::encrypt_file() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  [[ ${_BFL_HAS_OPENSSL} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'openssl' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local _fileToEncrypt="${1}"
  local _defaultName="${_fileToEncrypt%.decrypt}"
  local _encryptedFile="${2:-${_defaultName}.enc}"

  [[ $BASH_INTERACTIVE == true ]] && printf "Encrypt ${_fileToEncrypt}\n"
  if [[ -z "${PASS:-}" ]]; then
      openssl enc -aes-256-cbc -salt -in "${_fileToEncrypt}" -out "${_encryptedFile}"
  else
      openssl enc -aes-256-cbc -salt -in "${_fileToEncrypt}" -out "${_encryptedFile}" -k "${PASS}"
  fi

  return 0
  }
