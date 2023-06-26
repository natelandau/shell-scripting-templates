#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
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
#   Returns lines block for pastng in text file
#   The string - header for code blocks dividing
#
# @param String $text
#   The headline text.
#
# @param String $format
#   The headline layout to use (valid options: 'h1', 'h2').
#
# @return String $str
#   2 new lines, header line between 2 symbol lines.
#
# @example
#   bfl::get_section_header "New section" "//" 30 "-"
#------------------------------------------------------------------------------
bfl::get_section_header() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r TEXT="${1:-}"
  local -r FORMAT="${2:-}"

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
