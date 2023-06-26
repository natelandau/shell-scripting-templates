#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------- https://github.com/jmooring/bash-function-library -------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to the internet
#
# @author  Joe Mooring, Nathaniel Landau, A. River
#
# @file
# Defines function: bfl::encode_url().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Percent-encodes a URL.
#
# See <https://tools.ietf.org/html/rfc3986#section-2.1>.
#
# @param String $str
#   The string to be encoded.
#
# @return String $str_encoded
#   The encoded string.
#
# @example
#   bfl::encode_url "foo bar"
#------------------------------------------------------------------------------
bfl::encode_url() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  if ${has_jq}; then
      local rslt  # Build the return value.
      rslt=$(jq -Rr @uri <<< "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to encode url $1."; return 1; }
  else
# ----------------- https://github.com/ariver/bash_functions ------------------
      declare {h,tab,str,old,rslt}=
      printf -v tab "\t"
      #declare LC_ALL="${LC_ALL:-C}"

      old="${*}"  # printf "\n: old : %5d : %s\n" "${#old}" "${old}" 1>&2

      local -i i=0
      local -i k=${#old}
      for ((i=0; i < k; i++)); do
          str="${old:$i:1}"
          case "$str" in
              " " )                         printf -v h "+" ;;
              [-=\+\&_.~a-zA-Z0-9:/\?\#] )  printf -v h %s "$str" ;;
              * )                           printf -v h "%%%02X" "'$str" ;;
          esac
          rslt+="$h"
      done
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#    for ((i = 0; i < ${#1}; i++)); do
#        if [[ ${1:i:1} =~ ^[a-zA-Z0-9\.\~_-]$ ]]; then
#            printf "%s" "${1:i:1}"
#        else
#            printf '%%%02X' "'${1:i:1}"
#        fi
#    done
  fi

  printf "%s\\n" "$rslt"  # Print the return value.
  return 0
  }
