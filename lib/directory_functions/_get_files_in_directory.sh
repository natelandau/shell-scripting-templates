#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_files_in_directory().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the files in a directory (recursively or not).
#
# @option string -r, -R
#   recursively
#
# @param string $path
#   A directory path.
#
# @return integer $files_count
#   Files list in the directory.
#
# @example
#   bfl::get_files_in_directory -R "./foo"
#------------------------------------------------------------------------------
bfl::get_files_in_directory() {
  bfl::verify_arg_count "$#" 1 2 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1, 2]"  # Verify argument count.

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
