#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_section_header_line().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns line for pastng in text file like: // ----------- Section -----------
#
# The string - header for code blocks dividing
#
# @param string $header
#   The section name.
#
# @param string $line_beginning (optional)
#   '#' by default.
#
# @param integer $width (optional)
#   Width of line (including section name).
#
# @param string $symbols (optional)
#   '-' by default.
#
# @return string $str
#   Something like // ----------- Section -----------
#
# @example
#   bfl::get_section_header_line "New section" "//" 30 "-"
#------------------------------------------------------------------------------
bfl::get_section_header_line() {
  bfl::verify_arg_count "$#" 1 4 || exit 1  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "Не указан ни один параметр функции getHeaderForSection"

  local bgn
  [[ -z ${2+x} ]] && bgn="${2:-#}" || bgn="$2"  # может быть и '//'
  local -i l="${3:-126}"   # Общая длина
  local -r s="${4:--}"     # Символы

  local -r hdr="$1"
  local -i iHdr=${#hdr}  # Длина заголовка
  local -i iBgn=${#bgn}  # Длина начала строки

  local t s
  ((t=l-iBgn-iHdr-3))

  [[ x -lt 0 ]] && bfl::die "Функция getHeaderForSection:${bfl_aes_reset} Общая длина строки ${Red}$l${bfl_aes_reset} недостаточна для объявления ${Yellow}$hdr" 'Yellow'

  local y z
  ((y=t/2)); ((z=t-y*2))
# printf "%0.s-" {1..$y} чет не работает
  t=`perl -e "print '$s' x $y"`
  l="$bgn $t $hdr $t"
  [[ $z -eq 1 ]] && l="$l$s"

  echo "$l"
  return 0
  }
