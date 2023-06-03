#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::load_bash_completions().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# loads bash completion files from a given directory (recursively or not).
#
# NOT recursively
#
# @param string $path1
#   A directory path, /etc/bash_completion.d by default
#
# @example
#   bfl::load_bash_completions
#------------------------------------------------------------------------------
bfl::load_bash_completions() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  local d=${1:-/etc/bash_completion.d}
  ! [[ -d $d && -r $d && -x $d ]] && return 0

  [[ $BASH_INTERACTIVE == true ]] &&
      seq -s- 70 | tr -d '[0-9]' > /dev/tty &&
      printf "${Orange}Loading $d:${bfl_aes_reset}\n" > /dev/tty

  local _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
  local i _blacklist_glob='@(acroread.sh)'

  for i in "$d"/*; do
      if [[ ${i##*/} != @($_backup_glob|Makefile*|$_blacklist_glob) && -f $i && -r $i ]]; then
          [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$(basename $i)${bfl_aes_reset}\n" > /dev/tty
          . "$i"
      fi
  done
  return 0
  }
