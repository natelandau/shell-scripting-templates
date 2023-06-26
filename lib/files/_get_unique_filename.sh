#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_unique_filename().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Ensure a file to be created has a unique filename to avoid overwriting other
#   filenames by incrementing a number at the end of the filename
#
# @option String    -i
#   Places the unique integer before the file extension.
#
# @param String $filename
#   Name of file to be created.
#
# @param String $dlmtr (optional)
#   Separation characted (Defaults to a period '.')
#
# @return String $result
#   Unique name of file.
#
# @example
#   bfl::get_unique_filename "/some/dir/file.txt" --> /some/dir/file.txt.1
#   bfl::get_unique_filename -i"/some/dir/file.txt" "-" --> /some/dir/file-1.txt
#   printf "%s" "line" > "$(bfl::get_unique_filename "/some/dir/file.txt")"
#------------------------------------------------------------------------------
bfl::get_unique_filename() {
  bfl::verify_arg_count "$#" 1 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local opt
  local OPTIND=1
  local _internalInteger=false
  while getopts ":iI" opt; do
      case ${opt,,} in
          i) _internalInteger=true ;;
          *) bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
             return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _fullFile="${1}"
  #                         Why ?
  # Find directories with realpath if input is an actual file
  # [[ -e "${_fullFile}" ]] && _fullFile="$(bfl::get_canonical_path "${_fullFile}")"
  f="${_fullFile##*/}"  # $(basename "${_fullFile}")

  local _filePath
  _filePath="${_fullFile%/*}"  # $(dirname "${_fullFile}")

  local _spacer="${2:-.}"
  local f _ext _originalFile _newFilename str
  local -i _num

  #shellcheck disable=SC2064
  trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
  shopt -s nocasematch                  # Use case-insensitive regex

  # Find Extension
  _ext=$(bfl::get_file_extension "$f")

  if [[ -n "${_ext}" ]]; then
      f="${f%."${_ext}"}"
      _ext=".${_ext}"
  fi

  _newFilename="${_filePath}/${f}${_ext}"

  if [[ -e "${_newFilename}" ]]; then
      _num=1
      if [[ "${_internalInteger}" == true ]]; then
          while [[ -e "${_filePath}/${f}${_spacer}${_num}${_ext}" ]]; do
              ((_num++))
          done
          _newFilename="${_filePath}/${f}${_spacer}${_num}${_ext}"
      else
          while [[ -e "${_filePath}/${f}${_ext}${_spacer}${_num}" ]]; do
              ((_num++))
          done
          _newFilename="${_filePath}/${f}${_ext}${_spacer}${_num}"
      fi
  fi

  printf "%s\n" "${_newFilename}"
  return 0
  }
