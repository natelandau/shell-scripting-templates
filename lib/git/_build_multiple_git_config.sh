#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Git commands
#
#
#
# @file
# Defines function: bfl::build_multiple_git_config().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the git config section from local repository.
#
# @param String $Git_path1
#   Git repository path.
#
# @param String $branch1
#   Repository1 branch.
#
# @param String $Git_path2
#   Git repository path.
#
# @param String $branch2
#   Repository2 branch.
#
# @return String $rslt
#   Git section.
#
# @example
#   bfl::build_multiple_git_config "/etc/bash_functions_library" "master"  "~/scripts/Jarodiv" "master"
#------------------------------------------------------------------------------
bfl::build_multiple_git_config() {
  bfl::verify_arg_count "$#" 4 4 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";      return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  # Verify argument values.
  bfl::is_git_repository "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$1' is not a git repository!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_git_repository "$3" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' is not a git repository!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local b1="${2:-master}"
  local b2="${4:-master}"

  local s st1 st2 u
  # At first, check repository2, because I don't need change repostitory1 before repository2 turn out to be broken
  st2=$(bfl::get_git_config_section "$3" "origin") || { bfl::writelog_fail "${FUNCNAME[0]}: Failed bfl::get_git_config_section '$3' 'origin'"; return 1; }

  s=$(sed -n '/^\[remote "origin"\]$/p' "$1"/.git/config)
  st1=$(sed -n '/^\[remote "GitHub"\]$/p' "$1"/.git/config)
  if [[ -n "$s" && -z "$st1" ]]; then #       origin => GitHub
      s="${1##*/}"  # $(basename "$1")
      st1=$(bfl::get_git_config_section "$1" "origin") || { bfl::writelog_fail "${FUNCNAME[0]}: Failed bfl::get_git_config_section '$1' 'origin'"; return 1; }
      st1=$(echo "$st1" | sed "s|\(fetch=+refs.*\)/origin/|\1/$s/|")
      u=$(echo "$st1" | sed -n '/url=/p')

      # неразборчиво делать замену не буду
      sed -i 's/^\[remote "origin"\]$/[remote "GitHub"]/;s/^remote = origin$/remote = GitHub/' "$1"/.git/config
      sed -i 's|/origin/|/GitHub/|' "$1"/.git/config

      st1="[remote \"$s\"]
$st1"

      s=$(sed -n '/^\[branch "'"$b1"'"\]$/p' "$1"/.git/config)
      [[ -z "$s" ]] && { bfl::writelog_fail "${FUNCNAME[0]}: there is no [branch \"$b1\"] in '$1/.git/config'"; return 1; }

      echo "$st1
[remote \"origin\"]
$u" >> "$1"/.git/config
  fi

  local -i i  # Есть ли [branch "master"] в файле .git/config
  i=$(sed -n '/^\[remote "origin"\]$/=' "$1"/.git/config) || { bfl::writelog_fail "${FUNCNAME[0]}: i=\$(sed -n '/^\\[remote \"origin\"\\]$/='"; return 1; }

  s="${3##*/}"  # $(basename "$3")
  st2=$(echo "$st2" | sed "s|\(fetch=+refs.*\)/origin/|\1/$s/|")
  u=$(echo "$st2" | sed -n '/url=/p')

  st2="[remote \"$s\"]
$st2"
  bfl::insert_string_to_file "$st2" $i "$1"/.git/config || { bfl::writelog_fail "${FUNCNAME[0]}: Failed bfl::insert_line_to_file '$st2' '$i' '$1/.git/config'"; return 1; }
  echo "$u" >> "$1"/.git/config

  return 0
  }
