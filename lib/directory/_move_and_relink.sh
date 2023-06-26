#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to directories manipulation
#
#
#
# @file
# Defines function: bfl::move_and_relink().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the files in a directory (recursively or not).
#
# NOT recursively
#
# @param String $path1
#   A directory path.
#
# @param String $path2
#   A directory path.
#
# @param String $mask
#   mask for searching files.
#
# @example
#   bfl::move_and_relink "$folder1" "$folder2" ".la"
#------------------------------------------------------------------------------
bfl::move_and_relink() {
  bfl::verify_arg_count "$#" 3 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 3"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  # Verify argument values.
  [[ -d "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: directory '$1' doesn't exist"; return ${BFL_ErrCode_Not_verified_args_count}; }

  local str
  [[ -z "$3" ]] && local -r fltr='*' || local -r fltr="$3"

  [[ "$fltr" == '*' ]] && str=`ls -LA "$1"/ ` || str=`ls -LA "$1"/$fltr `
  [[ -z "$str" ]] && return 0
  str=`echo "$str" | sed "s|^$1/||g" | tr "\\n" " "`
  [[ -z "$str" ]] && return 0

  [[ -d "$2" ]] || install -v -d "$2"
  local arr=($str)
  local f b s
  for f in ${arr[@]}; do
      b=true
      if [[ -L "$1"/"$f" ]] ; then
          s=`readlink "$1"/"$f"`
          [[ -f "$s" ]] && s="${s%/*}"  # s=$(dirname "$s")
          if [[ "$s" == "$2" ]]; then
              b=false
              [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}file ${NC}$1/$f ${Yellow}already linked to $2${NC}\n" > /dev/tty
          fi
      fi

      $b || continue

      [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$2/$f${NC} => $1\n" > /dev/tty
      mv "$1"/"$f" "$2"/
      ln -sf "$2"/$f "$1"/
  done

#    if [[ "$fltr" = '*' ]]; then
#    else      mv "$1"/"$fltr" "$2"/
#    fi

  return 0
  }
