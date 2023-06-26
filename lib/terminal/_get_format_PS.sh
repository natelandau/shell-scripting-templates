#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::get_format_PS().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Provides prompt for non-login shells, specifically shells started in the X environment.
#   [Review the LFS archive thread titled PS1 Environment Variable for a great case study behind this script addendum.]
#
# @return String $PS
#   PS1 format.
#
# @example
#   bfl::get_format_PS
#------------------------------------------------------------------------------
bfl::get_format_PS() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local str
  if [[ $EUID == 0 ]] ; then
      str="$bfl_aes_red_bold\u [ $bfl_aes_reset\w$bfl_aes_red_bold ]# $bfl_aes_reset"
  else
      PS1="$bfl_aes_green_bold\u [ $bfl_aes_reset\w$bfl_aes_green_bold ]\$ $bfl_aes_reset"
  fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile), but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
# [[ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]] || PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

  printf "%s" "$str"
  return 0
  }
