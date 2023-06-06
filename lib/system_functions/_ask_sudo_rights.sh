#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::ask_sudo_rights().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Asks sudo rights for user
#
# @return bool $perl_prefix
#   0 / 1   (true / false)
#
# @example
#   bfl::ask_sudo_rights
#------------------------------------------------------------------------------
bfl::ask_sudo_rights() {
  [[ $(id -u) -eq 0 ]] && return 0

  sudo test -d /tmp
  [[ $? -eq 0 ]] && return 0 || return 1
  }
