#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
#   bfl::get_files_in_directory "./foo"
#------------------------------------------------------------------------------
bfl::get_files_in_directory() {
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
