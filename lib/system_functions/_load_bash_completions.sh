#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::move_and_relink().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the files in a directory (recursively or not).
#
# NOT recursively
#
# @param string $path1
#   A directory path.
#
# @param string $path2
#   A directory path.
#
# @param string $mask
#   mask for searching files.
#
# @example
#   bfl::move_and_relink "$folder1" "$folder2" ".la"
#------------------------------------------------------------------------------
bfl::move_and_relink() {
  local d=${1:-/etc/bash_completion.d}
  ! [[ -d $d && -r $d && -x $d ]] && return 0


  $isBashInteractive &&
      seq -s- 70 | tr -d '[0-9]' > /dev/tty &&
      printf "${Orange}Loading $d:${NC}\n" > /dev/tty
  local _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
  local i _blacklist_glob='@(acroread.sh)'
  for i in "$d"/*; do
      if [[ ${i##*/} != @($_backup_glob|Makefile*|$_blacklist_glob) && -f $i && -r $i ]]; then
          $isBashInteractive && printf "${Yellow}$(basename $i)${NC}\n" > /dev/tty
          . "$i"
      fi
  done
  return 0
  }
