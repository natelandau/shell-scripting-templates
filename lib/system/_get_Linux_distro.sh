#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Linux Systems
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_Linux_distro().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Detects the Linux distribution of the host the script is run on.
#
# @return String   $result
# 		0 - If Linux distro is successfully detected
# 		1 - If unable to detect OS distro or not on Linux
#			Prints name of Linux distro
#
# @example
#   bfl::get_Linux_distro
#------------------------------------------------------------------------------
bfl::get_Linux_distro() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local distro
  if [[ -f /etc/os-release ]]; then
      # shellcheck disable=SC1091,SC2154
      . "/etc/os-release"
      distro="${NAME}"
  elif type lsb_release >/dev/null 2>&1; then
      distro=$(lsb_release -si)   # linuxbase.org
  elif [[ -f /etc/lsb-release ]]; then
      # For some versions of Debian/Ubuntu without lsb_release command
      # shellcheck disable=SC1091,SC2154
      . "/etc/lsb-release"
      distro="${DISTRIB_ID}"
  elif [[ -f /etc/debian_version ]]; then
      distro="debian"             # Older Debian/Ubuntu/etc.
  elif [[ -f /etc/SuSe-release ]]; then
      distro="suse"               # Older SuSE/etc.
  elif [[ -f /etc/redhat-release ]]; then
      distro="redhat"             # Older Red Hat, CentOS, etc.
  else
      return 1
  fi
                        # in lower case (ex: 'raspbian' or 'debian')
  printf "%s" "$distro" #| tr '[:upper:]' '[:lower:]'

  return 0
  }
