#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to directories manipulation
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::get_files_in_directory().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the files in a directory (recursively or not).
#
# @option String -r, -R
#   recursively
#
# @param String $path
#   A directory path.
#
# @return Integer $files_count
#   Files list in the directory.
#
# @example
#   bfl::get_files_in_directory -R "./foo"
#------------------------------------------------------------------------------
bfl::get_files_in_directory() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local str sarr Recurs=false
  for str in "$@"; do
      IFS=$'=' read -r -a sarr <<< "$str"; unset IFS
      case "$str" in
          -R | -r )     Recurs=true ;;
      esac
  done

  if $Recurs; then
      str=`ls --indicator-style=file-type -R -A "$2"/* | sed '/^$/d' | sed '/.*[/:]$/d'`
  else
      str=`ls -A "$1" | grep -v / `
  fi

  echo "$str"
  return 0
  }
