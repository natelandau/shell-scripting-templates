#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::switch_usr_local().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prepares .la files for libraries in given directory.
#
# @param string $TARGET (optional)
#   directory with /bin, /lib, /share and other standard directories
#
# @example
#   bfl::switch_usr_local /STACK2
#------------------------------------------------------------------------------
bfl::switch_usr_local() {
  bfl::verify_arg_count "$#" 0 1 || exit 1  # Verify argument count.

  # Verify argument values.
  [[ -e /usr/local && ! -L /usr/local ]] && bfl::die "/usr/local exists, but is not a symlink"

  local target="${1:-'/STACK2'}"
  ! [[ -d "$target" ]]  && bfl::die "Неудачно${NC} - директория не существует!"
  ! [[ -L /usr/local ]] && bfl::die "/usr/local is not a symlinkНеудачно${NC} - директория не существует!"

  ! bfl::ask_sudo_rights && bfl::die "Неудачно${NC} - не удалось получить права суперпользователя"

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
