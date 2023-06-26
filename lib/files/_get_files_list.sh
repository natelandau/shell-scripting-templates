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
# Defines function: bfl::get_files_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Find files in a directory.  Use either glob or regex.
#   Searches are NOT case sensitive and MUST be quoted.
#
# @option String  -i, -r, -g
#      -i  Case-insensitive regex
#      -r  Remove first and last lines (ie - the lines which matched the patterns)
#      -g  Greedy regex (Defaults to non-greedy)
#
# @param String $type
#   'g|glob' or 'r|regex'.
#
# @param String $regex
#   pattern to match.
#
# @param String $directory (optional)
#   directory (defaults to .).
#
# @return String $rslt
#   Files list.
#
# @example
#   bfl::get_files_list glob "*.txt" "some/backup/dir"
#   bfl::get_files_list regex ".*\.[sha256|md5|txt]" "some/backup/dir"
#   readarray -t array < <(bfl::get_files_list g "*.txt")
#------------------------------------------------------------------------------
bfl::get_files_list() {
  bfl::verify_arg_count "$#" 3 6 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [3, 6]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _searchType="${1}"
  local _pattern="${2}"
  local _directory="${3:-.}"
  local _fileMatch
  declare -a _matchedFiles=()

  case "${_searchType}" in
      [Gg]*)
          while read -r _fileMatch; do
              _matchedFiles+=("$(realpath "${_fileMatch}")")
          done < <(find "${_directory}" -maxdepth 1 -iname "${_pattern}" -type f | sort)
          ;;
      [Rr]*)
          while read -r _fileMatch; do
              _matchedFiles+=("$(realpath "${_fileMatch}")")
          done < <(find "${_directory}" -maxdepth 1 -regextype posix-extended -iregex "${_pattern}" -type f | sort)
          ;;
      *)
          bfl::writelog_fail "${FUNCNAME[0]}: Could not determine if search was glob or regex"
          return 1 ;;
  esac

  [[ ${#_matchedFiles[@]} -gt 0 ]] && { printf "%s\n" "${_matchedFiles[@]}"; return 0; }

  return 1
  }
