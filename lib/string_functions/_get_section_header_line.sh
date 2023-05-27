#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  if [[ -z "$1" ]]; then
      $isBashInteractive && printf "${Red}Не указан ни один параметр функции getHeaderForSection${NC}\n" > /dev/tty
      return 1
  fi
  local bgn l t s hdr="$1" iHdr iBgn
  [[ -z ${2+x} ]] && bgn="${2:-#}" || bgn="$2"  # может быть и '//'
  l="${3:-126}"   # Общая длина
  s="${4:--}"   # Символы

  iHdr=${#hdr}  # Длина заголовка
  iBgn=${#bgn}  # Длина начала строки
  ((t=l-iBgn-iHdr-3))
  if [[ x -lt 0 ]]; then
      $isBashInteractive && printf "${Yellow}Функция getHeaderForSection:${NC} Общая длина строки ${Red}$l${NC} недостаточна для объявления ${Yellow}$hdr${NC}\n" > /dev/tty
      return 1
  fi

  local y z
  ((y=t/2)); ((z=t-y*2))
# printf "%0.s-" {1..$y} чет не работает
  t=`perl -e "print '$s' x $y"`
  l="$bgn $t $hdr $t"
  [[ $z -eq 1 ]] && l="$l$s"

  echo "$l"
  return 0
  }
