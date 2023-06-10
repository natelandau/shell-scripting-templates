#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# -------------- https://github.com/ralish/bash-script-template ---------------
# ----------- https://github.com/natelandau/shell-scripting-templates ---------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_root_available().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Validate we have superuser access as root (via sudo if requested).
#
# @param string $val (optional)
#   Set to any value to not attempt root access via sudo.
# @return bool $perl_prefix
#   0 / 1   (true / false)
#
# @example
#   bfl::is_root_available
#------------------------------------------------------------------------------
bfl::is_root_available() {
  bfl::verify_arg_count "$#" 0 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [0, 1]"  # Verify argument count.
  [[ $(id -u) -eq 0 ]] && return 0
  [[ -n "$1" ]] && bfl::die 'Unable to acquire superuser credentials.'

#  sudo test -d /tmp
#  [[ $? -eq 0 ]] && return 0 || return 1

  local superuser=false
  if sudo -v; then
      [[ $(sudo -H -- "${BASH}" -c 'printf "%s" "$EUID"') -eq 0 ]] && superuser=true
  fi

  if $superuser; then
      bfl::writelog_debug 'Successfully acquired superuser credentials.'
      return 0
  else
      bfl::writelog_debug 'Unable to acquire superuser credentials.'
      return 1
  fi
  }
