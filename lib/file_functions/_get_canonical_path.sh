#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_canonical_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the canonical path to a file.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @param boolean $FollowLink
#   Option to foolow symbolic links. False by default
#
# @return string $canonical_file_path
#   The canonical path to the file.
#
# @example
#   bfl::get_canonical_path "./foo/bar.text"
#------------------------------------------------------------------------------
bfl::get_canonical_path() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "The path was not specified."
  ! [[ -e "$1" ]] && bfl::die "$1 does not exist."   # Verify that the path exists.

  [[ "$2" = true ]] && local -r FollowLink=true || local -r FollowLink=false

  local str="$1"
  if $FollowLink; then
      while [[ -L "$str" ]]; do
          str=$(readlink -e "$str") || bfl::die "Symlink $str cannot be read."
          # Verify that the path points to real file/directory.
          [[ -e "$str" ]] || bfl::die "Path $str does not exist."
      done
  fi

  [[ "$str" == /* ]] || str="$(pwd)/$str"
  if $FollowLink; then
      local -a arr
      arr=( $(echo "${str:1}" | sed 's|/| |g') )
      local -ir l=${#arr[@]}

      str=""
      for ((i=0;i<l;i++)); do
          str+="/"${arr[$i]}
          while [[ -L "$str" ]]; do
              str=$(readlink -e "$str") || bfl::die "Symlink $str cannot be read."
              # Verify that the path points to real file/directory.
              [[ -e "$str" ]] || bfl::die "Path $str does not exist."
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
      local d
      d=$(dirname "$str") # parentdir
      s=$(basename "$str")
      pushd "$d" > /dev/null 2>&1
          str="$(pwd)"/"$s"
      popd > /dev/null 2>&1
  fi

  printf "%s" "$str"
  return 0
  }
