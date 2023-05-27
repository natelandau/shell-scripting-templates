#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::string_replace().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Replace substring in string
#
# Bash StrReplace analog
#
# @param string $main_string
#   String where replacement executes
#
# @param string $search_string
#   String to remove
#
# @param string $new_string
#   String to paste
#
# @example
#   bfl::string_replace "/home/alexei/.local/lib/site-packages" "/home/alexei/.local" "/usr"
#------------------------------------------------------------------------------
bfl::string_replace() {
  local srch=$1; #local substr=$2; local rplce=$3
  local str st2
  str=`echo "$2" | sed 's|/|\\\/|g'`      # echo $substr
  st2=`echo "$srch" | sed -n "/$str/p"`
  while [[ -n "$st2" ]]; do
      srch=`echo "$srch" | sed "s|$str|$3|g"`   # s|$str|$rplce|g
      st2=`echo "$srch" | sed -n "/$str/p"`
  done

  echo "$srch"
  return 0
  }
