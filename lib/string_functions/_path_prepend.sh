#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::path_prepend().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Searches path in the variable like PATH. If not found, add directory path to the beginning of string
# This help to exclude duplicates
#
# Standart Linux path functions. The string ONLY single line
#
# @param string $directory
#   The directory to be searching and prepend. There may be several paths, eg.  /opt/lib:/usr/local/lib:/home/usr/.local/lib
#
# @param string $path_variable (optional)
#   The variable to be changed. By default, PATH
#
# @example
#   bfl::path_prepend '/opt/lib:/usr/local/lib:/home/usr/.local/lib' LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::path_prepend() {
  bfl::verify_arg_count "$#" 1 2 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]" && return 1 # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}: path is empty!" && return 1

  local -r PATHVARIABLE=${2:-PATH}
  local str="${!PATHVARIABLE}"  # Var value by its name

  local s
  s=$(echo "$1" | sed 's/^[ :]*\(.*\)[ :]*$/\1/' | sed 's/::*/:/g')

  # PATHVARIABLE is not defined yet
  [[ -z "$str" ]] && { export $PATHVARIABLE="$s"; return 0; }

  str=$(echo "$str" | sed 's/^[ :]*\(.*\)[ :]*$/\1/' | sed 's/::*/:/g')
  [[ "$str" == "$s" ]] && return 0  # Nothing tp change

  # ---------------------------------------------------------------
  local d
  if [[ "$s" =~ : ]]; then
  # If 1st parameter is set of paths with : delimeter
      local arr=()
      arr=( $(echo "$str" | sed 's/:/ /g' ) )
      s=":$s:"  # Check every element of PATHVARIABLE to be contained in first parameter
      for d in ${arr[@]}; do
        s=$(echo "$s" | sed "s|:$d:|:|g")
      done

      [[ "$s" == ':' ]] && s=''
      [[ -n "$s" ]] && s="${s:1:-1}"
  else   # If 1st parameter is one path only
      [[ ":$str:" =~ :"$s": ]] && return 0  # nothing to do
  fi

  [[ -n "$s" ]] && export $PATHVARIABLE="$s:$str"

  return 0
  }
