#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::error().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints an error message to stderr.
#
# The message provided will be prepended with "Error. "
#
# @param string $msg (optional)
#   The message.
#
# @param string $msg_color (optional)
#   The message color.
#
# @example
#   bfl::error "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::error() {
  bfl::verify_arg_count "$#" 0 2 || exit 1  # Verify argument count.

  # Declare positional arguments (readonly, sorted by position).
  local msg="${1:-"Unspecified error."}"
  local msg_color="${2:-bfl_aes_red}"

  # Print the message.
  printf "%b\\n" "${msg_color}Error. $msg${bfl_aes_reset}" 1>&2
  }
