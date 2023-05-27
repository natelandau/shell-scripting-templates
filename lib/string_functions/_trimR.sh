#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::trimR().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes leading and trailing symbols (or evem substrings), from the end of string only.
#
# The string ONLY single line
#
# @param string $str
#   The string to be trimmed.
#
# @param string $str (optional)
#   The symbols (or strings) to be removed.
#
# @return string $str_trimmed
#   The trimmed string.
#
# @example
#   bfl::trimR " foo "
#------------------------------------------------------------------------------
bfl::trimR() {
  if [[ -z $1 ]]; then
    [[ $BASH_INTERACTIVE == true ]] && printf "${Red}trimR()${NC} No parameters\n" > /dev/tty
    return 1
  fi

  local s="$1"
  local ptrn=' '  # space by default
  if [[ $# -gt 1 ]]; then
    local d
    shift
    for d in "$@"; do
      ptrn="$ptrn$d"
    done
  fi

  [[ "$ptrn" =~ '"' ]] && s=`echo "$s" | sed 's/^\(.*\)['"$ptrn"']*$/\1/'` || s=`echo "$s" | sed "s/^\(.*\)[$ptrn]*$/\1/"`
  echo "$s"
  return 0
}
