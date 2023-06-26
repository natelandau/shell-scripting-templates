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
# Defines function: bfl::get_files_count().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the files count in a directory (recursively or not).
#
# @option String -r, -R
#   recursively
#
# @param String $path
#   A directory path.
#
# @return Integer $files_count
#   Files count in the directory.
#
# @example
#   bfl::get_files_count "./foo"
#------------------------------------------------------------------------------
bfl::get_files_count() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local str sarr Recurs=false
  for str in "$@"; do
      IFS=$'=' read -r -a sarr <<< "$str"; unset IFS
      case "$str" in
          -R | -r )     Recurs=true ;;
      esac
  done

  local -i i
  if $Recurs; then
      i=`ls --indicator-style=file-type -R -A "$2"/* | sed '/^$/d' | sed '/.*[/:]$/d' | wc -l`
  else
      i=`ls -A "$1" | grep -v / | wc -l`
  fi

  echo "$i"
  return 0
  }
