#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
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
# @param string $mask (optional)
#   A mask for files in directory path, * by default
#
# @example
#   bfl::load_bash_completions
#------------------------------------------------------------------------------
bfl::load_bash_completions() {
  bfl::verify_arg_count "$#" 1 2 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1, 2]"  # Verify argument count.

  # Verify system environment.
  ! $(shopt -q progcomp) && {
      printf "shopt -q progcomp is off!" > /dev/tty
      return 1
      }

  # Verify argument values.
  if [[ -f "$1" ]]; then
      ! [[ -r "$1" ]] && {
        printf "File $1 is not readable!" > /dev/tty
        return 1
        }
      . "$1"
      return 0
  fi

  ! [[ -d "$1" ]] && {
      printf "Directory $1 doesn't exists!" > /dev/tty
      return 1
      }

  ! [[ -r "$1" && -x "$1" ]] && {
      printf "Directory $1 exists, but cannot be load!" > /dev/tty
      return 1
      }
  # ------------------------------------------
  [[ $BASH_INTERACTIVE == true ]] && \
      seq -s- 70 | tr -d '[0-9]' > /dev/tty && \
      printf "${DarkOrange}Loading $d:${NC}\n" > /dev/tty

  local -r _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
  local -r _blacklist_glob='@(acroread.sh)'
  local -r mask=${2:-'*'}
  local f

  for f in "$1"/"$mask"; do
      if [[ ${f##*/} != @($_backup_glob|Makefile*|$_blacklist_glob) && -f $f && -r $f ]]; then
          [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$(basename $f)${NC}\n" > /dev/tty
          [[ -r "$f" ]] && . "$f"
      fi
  done

  return 0
  }
