#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of useful utility functions for compiling sources
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::switch_usr_local().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Rebuilds symlinks to / out of /usr/local.
#
# @param String $TARGET (optional)
#   directory with /bin, /lib, /share and other standard directories
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::switch_usr_local /STACK2
#------------------------------------------------------------------------------
bfl::switch_usr_local() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  [[ -e /usr/local && ! -L /usr/local ]] && { bfl::writelog_fail "${FUNCNAME[0]}: /usr/local exists, but is not a symlink"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local target="${1:-'/STACK2'}"
  [[ -d "$target" ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: failed - directory $target doesn't exist!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -L /usr/local ]] || { bfl::writelog_fail "${FUNCNAME[0]}: /usr/local is not a symlink!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  bfl::is_root_available || { bfl::writelog_fail "${FUNCNAME[0]}: failed to get sudo rights!"; return 1; }

  local d
  if [[ -e /usr/local ]]; then
      d=$(readlink /usr/local)
#      local i
#      i=$(bfl::_get_files_count "$d")

      [[ "$BASH_INTERACTIVE" == true ]] && sudo rm -fv /usr/local || sudo rm -f /usr/local

      if [[ "$d" == "$target" ]]; then
          d='/usr/EMPTY_STACK'
          ! [[ -d "$d" ]] && sudo install -v -d "$d"
          [[ "$BASH_INTERACTIVE" == true ]] && sudo ln -sfv "$d" /usr/local || sudo ln -sf "$d" /usr/local
      else
          [[ "$BASH_INTERACTIVE" == true ]] && sudo ln -sfv "$target" /usr/local || sudo ln -sf "$target" /usr/local
          . /etc/profile.d/addCustomPath.sh
      fi
  else
      sudo ln -sfv "$target" /usr/local
  fi

  return 0
  }
