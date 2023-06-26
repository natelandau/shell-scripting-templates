#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to password abd cache generating, files encrypting
#
# @author  A. River
#
# @file
# Defines function: bfl::pwgen_wip().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Decrypts a file with openSSL. If a global variable '$PASS' has a value,
#   we will use that as the password to decrypt the file. Otherwise we will ask.
#
# @param String $file
#   File to be decrypted.
#
# @param String $output (optional)
#   Name of output file (defaults to $1.decrypt).
#
# @return ........
#  .............
#
# @example
#   bfl::pwgen_wip ...
#------------------------------------------------------------------------------
bfl::pwgen_wip() {
#  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  declare vars=(
      ent
      pw_len
      pw_rgx
      tmp
      flg_cap
      flg_num
      flg_sym
      flg_sec
      flg_amb
      flg_vwl
      flg_col
      flg_help
      )
    declare ${vars[*]}

    for ent in "${@}"; do
        declare -p ent

        if [[ "${ent}" =~ ^-[^-] ]]; then
            while [[ -n "${ent}" ]]; do
                ent="${ent:1}"
            done
        fi
    done

    return

    local str=
    pw_len="${1:-8}"
#    pw_cnt=0
    pw_rgx='^[0-9a-z]$'
    while read -n1 tmp; do
        [[ "$tmp" =~ ${pw_rgx} ]] || continue
        str+="$tmp"
        [ "${#str}" -lt "${pw_len}" ] || break
    done < /dev/urandom
    echo "$str"

    printf '%s' '
Usage: pwgen [ OPTIONS ] [ pw_length ] [ num_pw ]

Options supported by pwgen:
  -c or --capitalize
    Include at least one capital letter in the password
  -A or --no-capitalize
    Don't include capital letters in the password
  -n or --numerals
    Include at least one number in the password
  -0 or --no-numerals
    Don't include numbers in the password
  -y or --symbols
    Include at least one special symbol in the password
  -s or --secure
    Generate completely random passwords
  -B or --ambiguous
    Don't include ambiguous characters in the password
  -h or --help
    Print a help message
  -C
    Print the generated passwords in columns
  -1
    Don't print the generated passwords in columns
  -v or --no-vowels
    Do not use any vowels so as to avoid accidental nasty words
'

  }
