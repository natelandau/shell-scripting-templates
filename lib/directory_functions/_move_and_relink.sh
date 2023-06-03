#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
  bfl::verify_arg_count "$#" 3 3 || exit 1  # Verify argument count.
  ! [[ -d "$1" ]] && return 1

  local str fltr
  [[ -z "$3" ]] && fltr='*' || fltr="$3"

  [[ "$fltr" = '*' ]] && str=`ls -LA "$1"/ ` || str=`ls -LA "$1"/$fltr `
  [[ -z "$str" ]] && return 0
  str=`echo "$str" | sed "s|^$1/||g" | tr "\\n" " "`
  [[ -z "$str" ]] && return 0

  ! [[ -d "$2" ]] && install -v -d "$2"
  local arr=($str)
  local f b s
  for f in ${arr[@]}; do
      b=true
      if [[ -L "$1"/"$f" ]] ; then
          s=`readlink "$1"/"$f"`
          [[ -f "$s" ]] && s=`dirname "$s"`
          if [[ "$s" == "$2" ]]; then
              b=false
              [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}file ${bfl_aes_reset}$1/$f ${Yellow}already linked to $2${bfl_aes_reset}\n" > /dev/tty
          fi
      fi

      if $b; then
          [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$2/$f${bfl_aes_reset} => $1\n" > /dev/tty
          mv "$1"/"$f" "$2"/
          ln -sf "$2"/$f "$1"/
      fi
  done

#    if [[ "$fltr" = '*' ]]; then
#    else      mv "$1"/"$fltr" "$2"/
#    fi

  return 0
  }
