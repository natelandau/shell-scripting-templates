#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# -------------- https://github.com/ralish/bash-script-template ---------------
# ----------- https://github.com/natelandau/shell-scripting-templates ---------
#
# Library of functions related to Linux Systems
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::is_root_available().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Validate we have superuser access as root (via sudo if requested).
#
# @param String $val (optional)
#   Set to any value to not attempt root access via sudo.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_root_available
#------------------------------------------------------------------------------
bfl::is_root_available() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ $(id -u) -eq 0 ]] && return 0
  [[ -n "$1" ]] && { bfl::writelog_debug "${FUNCNAME[0]}: passed parameter to skip acquire superuser credentials."; return 1; }

#  sudo test -d /tmp
#  [[ $? -eq 0 ]] && return 0 || return 1

  local superuser=false
  if sudo -v; then
      [[ $(sudo -H -- "$BASH" -c 'printf "%s" "$EUID"') -eq 0 ]] && superuser=true
  fi

  if $superuser; then
      bfl::writelog_debug "${FUNCNAME[0]}: Successfully acquired superuser credentials."
      return 0
  else
      bfl::writelog_debug "${FUNCNAME[0]}: Unable to acquire superuser credentials."
      return 1
  fi

#  _runAsRoot_() from https://github.com/natelandau/shell-scripting-templates
#  if [[ ${EUID} -eq 0 ]]; then
#      "$@"
#  elif [[ -z ${_skip_sudo} ]]; then
#      sudo -H -- "$@"

  }
