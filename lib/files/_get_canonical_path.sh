#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to manipulations with files
#
#
#
# @file
# Defines function: bfl::get_canonical_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the canonical path to a file.
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @param boolean $FollowLink
#   Option to foolow symbolic links. False by default
#
# @return String $canonical_file_path
#   The canonical path to the file.
#
# @example
#   bfl::get_canonical_path "./foo/bar.text"
#------------------------------------------------------------------------------
bfl::get_canonical_path() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -e "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' does not exist."; return ${BFL_ErrCode_Not_verified_arg_values}; }   # Verify that the path exists.

  [[ "$2" == true ]] && local -r FollowLink=true || local -r FollowLink=false

#  ------------->  COMPARE WITH CODE FROM  https://github.com/natelandau/shell-scripting-templates
#  local d
#  while [[ -h "$f" ]]; do # Resolve $SOURCE until the file is no longer a symlink
#      d="$(cd -P "${f%/*}" && pwd)"    # "$(dirname "$f")"
#      f="$(readlink "$f")"
#      [[ $f != /* ]] && f="$d/$f" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
#  done
#  printf "%s\n" "$(cd -P "${f%/*}" && pwd)"    # "$(dirname "$f")"
#  < ------------

  local str="$1"
  if $FollowLink; then
      while [[ -L "$str" ]]; do
          str=$(readlink -e "$str") || { bfl::writelog_fail "${FUNCNAME[0]}: symlink '$str' cannot be read."; return 1; }
          # Verify that the path points to real file/directory.
          [[ -e "$str" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path '$str' does not exist."; return 1; }
      done
  fi

  [[ "$str" == /* ]] || str="$(pwd)/$str"
  if $FollowLink; then
      local -a arr
      arr=( $(echo "${str:1}" | sed 's|/| |g') )
      local -ir l=${#arr[@]}

      str=""
      for ((i=0; i < l; i++)); do
          str+="/"${arr[$i]}
          while [[ -L "$str" ]]; do
              str=$(readlink -e "$str") || { bfl::writelog_fail "${FUNCNAME[0]}: symlink '$str' cannot be read."; return 1; }
              # Verify that the path points to real file/directory.
              [[ -e "$str" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path '$str' does not exist."; return 1; }
          done
      done
  fi

  local s
  s=$(echo "$str" | sed -n '/\.\./p')
  [[ -z "$s" ]] && { printf "%s" "$str"; return 0; }

  if [[ -d "$str" ]]; then         # Directory
      pushd "$str" > /dev/null 2>&1
          str="$(pwd)"
      popd > /dev/null 2>&1
  else
      local d="${str%/*}" # parentdir   $(dirname "$str")
      s="${str##*/}"    # $(basename "$str")
      pushd "$d" > /dev/null 2>&1
          str="$(pwd)"/"$s"
      popd > /dev/null 2>&1
  fi

  printf "%s" "$str"
  return 0
  }
