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
# Defines function: bfl::make_symlink().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Creates a symlink and backs up a file which may be overwritten by the new symlink.
#   If the exact same symlink already exists, nothing is done.
#   Default behavior will create a backup of a file to be overwritten.
#
# @option String    -c, -n, s
#    -c   Only report on new/changed symlinks.  Quiet when nothing done.
#    -n   Do not create a backup if target already exists
#    -s   Use sudo when removing old files to make way for new symlinks
#
# @param String $filename
#   Source file.
#
# @param String $dest_dir
#   Destination dir name.
#
# @return boolean $result
#     0 / 1    ( true / false )
#
# @example
#   bfl::make_symlink "/dir/someExistingFile" "/dir/aNewSymLink" "/dir/backup/location"
#------------------------------------------------------------------------------
bfl::make_symlink() {
  bfl::verify_arg_count "$#" 2 5 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 5]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#  declare -f "bfl::get_unique_filename" &>/dev/null || fatal "_backupFile_ needs function bfl::get_unique_filename"

  local opt
  local OPTIND=1
  local _backupOriginal=true
  local _useSudo=false
  local _onlyShowChanged=false

  while getopts ":cCnNsS" opt; do
      case ${opt,,} in
          n ) _backupOriginal=false ;;
          s ) _useSudo=true ;;
          c ) _onlyShowChanged=true ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

#  declare -f _backupFile_ &>/dev/null || { bfl::writelog_fail "${FUNCNAME[0]}: needs function bfl::backup_file"

  if ! command -v bfl::get_canonical_path >/dev/null 2>&1; then
      error "We must have 'bfl::get_canonical_path' installed and available in \$PATH to run."
      local os
      os=$(bfl::get_OS)
      if [[ "$os" == "mac" ]]; then
          notice "Install coreutils using homebrew and rerun this script."
          info "\t$ brew install coreutils"
      fi
      return 1
  fi

  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _sourceFile="$1"
  local _destinationFile="$2"
  local _originalFile

  # Fix files where $HOME is written as '~'
  _destinationFile="${_destinationFile/\~/${HOME}}"
  _sourceFile="${_sourceFile/\~/${HOME}}"

  # Verify arguments.
  [[ -e "${_sourceFile}" ]] || { bfl::writelog_fail "'${_sourceFile}' not found"; return 1; }
  [[ -z "${_destinationFile}" ]] && { bfl::writelog_fail "'${_destinationFile}' not specified"; return 1; }

  # Create destination directory if needed
  [[ -d "${_destinationFile%/*}" ]] || mkdir -p "${_destinationFile%/*}"

  if ! [[ -e "${_destinationFile}" ]]; then
      [[ $BASH_INTERACTIVE == true ]] && "symlink ${_sourceFile} → ${_destinationFile}"
      ln -fs "${_sourceFile}" "${_destinationFile}"
  elif [[ -h "${_destinationFile}" ]]; then
      _originalFile="$(bfl::get_canonical_path "${_destinationFile}")"

      [[ ${_originalFile} == "${_sourceFile}" ]] && {
          if [[ ${_onlyShowChanged} == true ]]; then
              debug "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
          elif [[ ${DRYRUN:-} == true ]]; then
              dryrun "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
          else
              info "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
          fi
          return 0
      }

      [[ ${_backupOriginal} == true ]] && _backupFile_ "${_destinationFile}"

      if [[ ${DRYRUN} == false ]]; then
          if [[ ${_useSudo} == true ]]; then
              command rm -rf "${_destinationFile}"
          else
              command rm -rf "${_destinationFile}"
          fi
      fi

      printf "symlink ${_sourceFile} → ${_destinationFile}\n"
      ln -fs "${_sourceFile}" "${_destinationFile}"
  elif [[ -e "${_destinationFile}" ]]; then
      [[ ${_backupOriginal} == true ]] && bfl::backup_file "${_destinationFile}"

      if [[ ${DRYRUN} == false ]]; then
          if [[ ${_useSudo} == true ]]; then
              sudo command rm -rf "${_destinationFile}"
          else
              command rm -rf "${_destinationFile}"
          fi
      fi

      printf "symlink ${_sourceFile} → ${_destinationFile}\n"
      ln -fs "${_sourceFile}" "${_destinationFile}"
  else
      bfl::writelog_fail "${FUNCNAME[0]}: Error linking ${_sourceFile} → ${_destinationFile}"
      return 1
  fi

  return 0
  }
