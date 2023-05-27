#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to terminal and file logging
# Inspired by https://github.com/gentoo/gentoo-functions/blob/master/functions.sh
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_section_header().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns lines block for pastng in text file
#
# The string - header for code blocks dividing
#
# @param string $TEXT
#   The headline text.
#
# @param string $FORMAT
#   The headline layout to use (valid options: 'h1', 'h2').
#
# @return string $str
#   2 new lines, header line between 2 symbol lines.
#
# @example
#   bfl::get_section_header "New section" "//" 30 "-"
#------------------------------------------------------------------------------
bfl::get_section_header() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  local -r TEXT="${1:-}"; shift
  local -r FORMAT="${1:-}"; shift

  local str=''
  case "${FORMAT}" in
      "h1")
          echo -e "\n\n###############################################################################"
          echo -e "# ${TEXT}"
          echo -e "###############################################################################\n"
          ;;
      "h2")
          echo -e "\n\n# -----------------------------------------------------------------------------"
          echo -e "# ${TEXT}"
          echo -e "# -----------------------------------------------------------------------------\n"
          ;;
  esac
}
