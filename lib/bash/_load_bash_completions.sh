#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::load_bash_completions().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Loads bash completion files from a given directory (recursively or not).
#
# NOT recursively
#
# @param String $path1
#   A directory path, /etc/bash_completion.d by default
#
# @param String $mask (optional)
#   A mask for files in directory path, * by default
#
# @example
#   bfl::load_bash_completions
#------------------------------------------------------------------------------
bfl::load_bash_completions() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify system environment.
  $(shopt -q progcomp) || { bfl::writelog_fail "${FUNCNAME[0]}: shopt -q progcomp is off!"; return ${BFL_ErrCode_Not_verified_dependency}; }

  # Verify argument values.
  if [[ -f "$1" ]]; then
      [[ -r "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: File $1 is not readable!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
      . "$1"
      return 0
  fi

  [[ -d "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: directory $1 doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -r "$1" && -x "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: directory $1 exists, but cannot be load!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  # ------------------------------------------
  if [[ $BASH_INTERACTIVE == true ]]; then
      seq -s- 70 | tr -d '[0-9]' > /dev/tty
      printf "${DarkOrange}Loading $1:${NC}\n" > /dev/tty
  fi

  local -r _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
  local -r _blacklist_glob='@(acroread.sh)'
  local -r mask=${2:-'*'}
  local f

  for f in "$1"/"$mask"; do
      if [[ ${f##*/} != @($_backup_glob|Makefile*|$_blacklist_glob) && -f $f && -r $f ]]; then
          [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}${f##*/}${NC}\n" > /dev/tty     # $(basename $f)
          [[ -r "$f" ]] && . "$f"
      fi
  done

  return 0
  }
