#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to backups
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::backup_file().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Creates a backup of a specified file with .bak extension or optionally to a specified directory.
#   Dotfiles have their leading '.' removed in their backup.
#
# @option String    -d, -m
#    -d   Move files to a backup direcory
#    -m   Replaces copy (default) with move, effectively removing the original file
#
# @param String $filename
#   Source file.
#
# @param String $dest_dir (optional)
#   Destination dir name used only with -d flag (defaults to ./backup)
#
# @return boolean $result
#     0 / 1    ( true / false )
#
# @example
#   bfl::backup_file "sourcefile.txt" "some/backup/dir"
#------------------------------------------------------------------------------
bfl::backup_file() {
  bfl::verify_arg_count "$#" 1 4 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 4]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#  declare -f "bfl::get_unique_filename" &>/dev/null || fatal "_backupFile_ needs function bfl::get_unique_filename"

  local opt
  local OPTIND=1
  local _useDirectory=false
  local _moveFile=false

  while getopts ":dDmM" opt; do
      case ${opt,,} in
          d ) _useDirectory=true ;;
          m ) _moveFile=true ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _fileToBackup="${1}"
  local _backupDir="${2:-backup}"
  local _newFilename

  [[ ! -e "${_fileToBackup}" ]] && { bfl::writelog_fail "${FUNCNAME[0]}: source '${_fileToBackup}' not found"; return 1; }

  if [[ ${_useDirectory} == true ]]; then
      [[ -d "${_backupDir}" ]] || { printf "Creating backup directory"; mkdir -p "${_backupDir}"; }

      _newFilename="$(bfl::get_unique_filename "${_backupDir}/${_fileToBackup#.}")"
      if [[ ${_moveFile} == true ]]; then
          printf "Moving: '${_fileToBackup}' to '${_backupDir}/${_newFilename##*/}'"
          mv "${_fileToBackup}" "${_backupDir}/${_newFilename##*/}"
      else
          printf "Backing up: '${_fileToBackup}' to '${_backupDir}/${_newFilename##*/}'"
          cp -R "${_fileToBackup}" "${_backupDir}/${_newFilename##*/}"
      fi
  else
      _newFilename="$(bfl::get_unique_filename "${_fileToBackup}.bak")"
      if [[ ${_moveFile} == true ]]; then
          printf "Moving '${_fileToBackup}' to '${_newFilename}'"
          mv "${_fileToBackup}" "${_newFilename}"
      else
          printf "Backing up '${_fileToBackup}' to '${_newFilename}'"
          cp -R "${_fileToBackup}" "${_newFilename}"
      fi
  fi

  return 0
  }
