#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Linux Systems
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_kernel_sources_dir().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns the path to the sources of KERNEL.
#
# @param  String  $KERNEL
#   Name of the kernel (e.g. 4.12.12-gentoo). If not specified, the path to the current sources is returned.
#
# @return String  $result
#   Path to the sources (e.g. "/usr/src/linux-4.12.12-gentoo")
#
# @example
#   bfl::get_kernel_sources_dir '4.12.12-gentoo'
#------------------------------------------------------------------------------
bfl::get_kernel_sources_dir() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1"      && { bfl::writelog_fail "${FUNCNAME[0]}: Kernel was not specified!";   return ${BFL_ErrCode_Not_verified_arg_values}; }

  src_dir="/usr/src/linux-${1}"

  [[ -d "$src_dir" ]] || { echo ''; return 1; }

  echo "$src_dir"
  return 0
  }
