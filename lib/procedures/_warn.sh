#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of internal library functions
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::warn().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints a warning message to stderr.
#   The message provided will be prepended with "Warning. "
#
# @param String $msg (optional)
#   The message.
#
# @example
#   bfl::warn "The foo is bar."
#------------------------------------------------------------------------------
# shellcheck disable=SC2154
bfl::warn() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Declare positional arguments (readonly, sorted by position).
  local msg="${1:-"Unspecified warning."}"

  # Print the message.
  printf "%b\\n" "${Yellow}Warning. $msg${NC}" 1>&2
  }
