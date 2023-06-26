#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Bash Strings
#
#
#
# @file
# Defines function: bfl::path_remove().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Searches and removes path from variable like PATH.
#
# Standart Linux path functions. The string ONLY single line
#
# @param String $directory
#   The directory to be searching and removed. There may be several paths, eg.  /opt/lib:/usr/local/lib:/home/usr/.local/lib
#
# @param String $path_variable (optional)
#   The variable to be changed. By default, PATH
#
# @example
#   bfl::path_remove '/opt/lib:/usr/local/lib:/home/usr/.local/lib' LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::path_remove() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r PATHVARIABLE=${2:-PATH}
  local str="${!PATHVARIABLE}"  # Var value by its name
  bfl::is_blank "$str" && return 0   # PATHVARIABLE is not defined yet

  local s
  s=$(echo "$1" | sed 's/^[ :]*\(.*\)[ :]*$/\1/' | sed 's/::*/:/g')
  str=$(echo "$str" | sed 's/^[ :]*\(.*\)[ :]*$/\1/' | sed 's/::*/:/g')
  # PATHVARIABLE => Nothing
  [[ "$str" == "$s" ]] && { export $PATHVARIABLE=''; return 0; }

  # ---------------------------------------------------------------
  local d
  if [[ "$s" =~ : ]]; then
  # If 1st parameter is set of paths with : delimeter
      local arr=()
      arr=( $(echo "$str" | sed 's/:/ /g' ) )
      str=""  # Check every element of PATHVARIABLE to be contained in first parameter
      for d in ${arr[@]}; do
        ! [[ ":$s:" =~ :"$d": ]] && str="$str:$d"
      done

      [[ -n "$str" ]] && str="${str:1}"
  else   # If 1st parameter is one path only
      ! [[ ":$str:" =~ :"$s": ]] && return 0 # Nothing to do
      str=$(echo ":$str:" | sed "s|:$s:|:|g")
      [[ "$str" == ':' ]] && str='' || str="${str:1:-1}"
  fi

  export $PATHVARIABLE="$str"

# ------------- https://github.com/jmooring/bash-function-library -------------
#  local -r ENTRY="${1:-}"; shift
#  export PATH=$(sed -E -e "s;:${ENTRY};;" -e "s;${ENTRY}:?;;" <<< "${PATH}")

  return 0
  }
