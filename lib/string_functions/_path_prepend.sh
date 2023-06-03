#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
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
#   The directory to be searching and remove.
#
# @param string $path_variable (optional)
#   The variable to be changed. By default, PATH
#
# @example
#   bfl::path_prepend '/usr/local/lib' LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::path_prepend() {
  bfl::verify_arg_count "$#" 1 2 || exit 1  # Verify argument count.
# Original:
#  pathremove $1 $2
#  export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
  [[ -z "$1" ]] && bfl::die 'path is empty!'

  local s
  s=$(trimLR "$1" ':' ' ')

  local PATHVARIABLE=${2:-PATH}
  local str="${!PATHVARIABLE}"  # значение переменной по ее имени

  # если переменная даже не объявлена
  [[ -z "$str" ]] && export $PATHVARIABLE="$s" && return 0
  # если нет необходимости что-то менять
  [[ "$str" == "$s" ]] && return 0

  local b=false
  if [[ "$s" =~ ':' ]]; then
      local d arr
      arr=()
      IFS=$':' read -r -a arr <<< "$str"

      s=":$s:"
      for d in ${arr[@]}; do
        s=`echo "$s" | sed "s|:$d:|:|g"`
      done
      unset IFS
      [[ "$s" == ':' ]] && s=''
      [[ -n "$s" ]] && s="${s:1:-1}"
  else
      b=`isDirInPath "$s" "$str"`
      $b && return 0  # нет необходимости что-то менять
  fi

  if [[ -n "$s" ]]; then
      str=`fixPathColons "$str"`
      export $PATHVARIABLE="$s:$str"
  fi

  return 0
  }
