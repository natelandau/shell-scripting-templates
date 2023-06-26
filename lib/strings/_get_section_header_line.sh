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
# Defines function: bfl::get_section_header_line().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns line for pastng in text file like: // ---------- Section ----------
#   The string - header for code blocks dividing
#
# @param String $header
#   The section name.
#
# @param String $line_beginning (optional)
#   '#' by default.
#
# @param Integer $width (optional)
#   Width of line (including section name).
#
# @param String $symbols (optional)
#   '-' by default.
#
# @return String $str
#   Something like // ----------- Section -----------
#
# @example
#   bfl::get_section_header_line "New section" "//" 30 "-"
#         для вывода на экран можно использовать $COLUMNS
#------------------------------------------------------------------------------
bfl::get_section_header_line() {
  bfl::verify_arg_count "$#" 1 4  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1..4]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: no parameters were specified!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local bgn
  [[ -z ${2+x} ]] && bgn='#' || bgn="$2"  # может быть и '//'
  local l="${3:-126}"   # Общая длина
  local -r s="${4:--}"     # Символы

  local -r hdr="$1"
  local -i iHdr=${#hdr}  # Длина заголовка
  local -i iBgn=${#bgn}  # Длина начала строки

  local t
  ((t=l-iBgn-iHdr-3))
  [[ t -lt 0 ]] && { bfl::writelog_fail "${FUNCNAME[0]}:${NC} line' total length ${Red}$l${NC} is not enough for printing ${Yellow}$hdr."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local y z
  y=$((t/2)); z=$((t-y*2))
  t=$(bfl::string_of_char "$s" $y)
  l="$bgn $t $hdr $t"
  [[ $z -eq 1 ]] && l+="$s"

  echo "$l"
#  printf %s "$l"
  return 0
  }
