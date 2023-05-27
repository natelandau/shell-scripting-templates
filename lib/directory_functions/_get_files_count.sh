#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_files_count().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the files count in a directory recursively or not.
#
# @option string -r, -R
#   recursively
#
# @param string $path
#   A directory path.
#
# @return integer $files_count
#   Files count in the directory.
#
# @example
#   bfl::get_files_count "./foo"
#------------------------------------------------------------------------------
bfl::get_files_count() {
  local str sarr Recurs=false
  for str in "$@"; do
    IFS=$'=' read -r -a sarr <<< "$str"; unset IFS
    case "$str" in
      -R | -r )     Recurs=true ;;
    esac
  done

  local i
  if $Recurs; then
    i=`ls --indicator-style=file-type -R -A "$2"/* | sed '/^$/d' | sed '/.*[/:]$/d' | wc -l`
  else
    i=`ls -A "$1" | grep -v / | wc -l`
  fi

  echo "$i"
  return 0
  }
