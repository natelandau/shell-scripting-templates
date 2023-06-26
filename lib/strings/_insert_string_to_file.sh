#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://www.programmersought.com/article/93399676487 ------------
#
# Library of functions related to Bash Strings
#
#
#
# @file
# Defines function: bfl::insert_string_to_file().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Inserts string to file. Supports multiline strings!
#
# @param String $str
#   The string to be inserted.
#
# @param Integer $line_no
#   File line number.
#
# @param String $filename
#   The file to be edited.
#
# @example
#   bfl::insert_string_to_file "$str" 288 'Makefile.in'
#------------------------------------------------------------------------------
bfl::insert_string_to_file() {
  bfl::verify_arg_count "$#" 3 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 3";        return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_UNAME} -eq 1 ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'uname' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local -i i
  i=`echo "$1" | wc -l`
  local s
  if [[ $i -gt 1 ]]; then
      # еле-еле вставил - пришлось подставить к кавычкам обратную косую черту
      # дополнительно в конец каждой строки добавить \, кроме самой последней строки
      s=$(echo "$1" | sed 's/"/\"/g;s/[$]/\\\$/g;s/$/\\/g') || { bfl::writelog_fail "${FUNCNAME[0]}: Failed echo "\$1" | sed 's/\"/\\\"/g;s/[$]/\\\\\\$/g;s/$/\\\\/g'"; return 1; }
      s="${s::-1}"    # убираем обратную косую черту из конца
  else
      s=$(echo "$1" | sed 's/"/\"/g;s/[$]/\\\$/g') || { bfl::writelog_fail "${FUNCNAME[0]}: Failed echo "\$1" | sed 's/\"/\\\"/g;s/[$]/\\\\\\$/g'"; return 1; }
  fi

  if [ $(uname -s) == "Darwin" ]; then # mac
      sed -i "" "$2""i$s" "$3" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed sed -i '' '${2}i${s}' '$3'"; return 1; }
  else # linux
      sed -i "$2""i$s" "$3" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed sed -i '${2}i${s}' '$3'"; return 1; }
  fi

  return 0
  }
