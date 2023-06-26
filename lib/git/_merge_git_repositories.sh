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
# Defines function: bfl::merge_git_repositories().
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
# @param String $editor
#   Git editor (default xed).
#
# @return String $rslt
#   Git section.
#
# @example
#   bfl::merge_git_repositories "/etc/bash_functions_library" "master"  "~/scripts/Jarodiv" "master"
#------------------------------------------------------------------------------
bfl::merge_git_repositories() {
  bfl::verify_arg_count "$#" 4 4 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";      return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_git_repository "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$1' is not a git repository!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_git_repository "$3" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' is not a git repository!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local o1="${1##*/}"    # $(basename "$1")
  local o2="${3##*/}"    # $(basename "$3")

  local s i

  i=$(sed -n "/^\[remote \"$o2\"\]$/=" "$1"/.git/config)

if false; then
#  1) compare files from directories!
#  2) goto dir2
  str=`git status | tail -n 1`
  if [[ -z "$str" ]]; then    # "$str" != "нечего коммитить, нет изменений в рабочем каталоге"
     git add .
     git commit -m  "Preparing to merging with $o1" || { bfl::writelog_fail "${FUNCNAME[0]}: git commit -m 'Preparing to merging with '$o1''"; return 1; }
     git push origin "$4"
  fi
#  3) goto dir 1
  str=`git status | tail -n 1`
  if [[ -z "$str" ]]; then    # "$str" != "нечего коммитить, нет изменений в рабочем каталоге"
      git add .
      git commit -m "Commit before merging '$o2' into '$o1'" || { bfl::writelog_fail "${FUNCNAME[0]}: git commit -m 'Commit before merging '$o2' into '$o1''"; return 1; }
      git push origin "$2"
  fi


  [[ -z "$i" ]] && bfl::build_multiple_git_config "$1" "$2" "$3" "$4" || \   # можно было git remote add "$o2" "$3"
                                                            { bfl::writelog_fail "${FUNCNAME[0]}: bfl::build_multiple_git_config '$1' '$2' '$3' '$4'";     return 1; }
  git fetch "$o2" --tags                                 || { bfl::writelog_fail "${FUNCNAME[0]}: git fetch '$o2' --tags";     return 1; }
  GIT_EDITOR=${5:-xed} git merge --allow-unrelated-histories "$o2"/"$b2" \
                                                         || { bfl::writelog_fail "${FUNCNAME[0]}: git merge --allow-unrelated-histories '$o2/$b2'";        return 1; }
  git push origin "$b1"                                  || { bfl::writelog_fail "${FUNCNAME[0]}: git push origin '$b1'";      return 1; }
  git remote remove "$o2"                                || { bfl::writelog_fail "${FUNCNAME[0]}: git remote remove '$o2'";    return 1; }
fi

  # read remote origin from $3/.git/config
  s=$(bfl::get_file_part "\[remote \"origin\"\]" "\[branch \"$b2\"\]" "$3"/.git/config)
  [[ -n "$s" ]] && s=$(echo "$s" | sed '1d') && [[ -n "$s" ]] && s=$(echo "$s" | sed '$d')
  [[ -n "$s" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: text between sections [remote \"origin\"] и '[branch \"$b2\"]' in '$2' not found!"; return 1; }

  local st
  st=$(echo "$s" | sed '/url =/p' | sed 's|/|\\\/|' )
  [[ -n "$st" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: echo '$s' | sed '/url =/p'!"; return 1; }

  # read $1/.git/config
  st=$(sed -n "/$st/p" "$1"/.git/config)
  if [[ -z "$st" ]]; then
      i=$(sed -n "/^\[remote \"origin\"\]$/=" "$1"/.git/config)
      [[ -n "$i" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: section '[remote \"origin\"]' in '$1' not found!"; return 1; }

      sed -i "$i"'i[remote "'"$o2"'"]' "$1"/.git/config && ((i++))
      bfl::insert_string_to_file "$s" ${i} "$1"/.git/config || { bfl::writelog_fail "${FUNCNAME[0]}: bfl::insert_string_to_file '$s' '${i}' "$1"/.git/config"; return 1; }

      echo "$(echo echo "$s" | sed '/url =/p')" >> "$1"/.git/config
  fi

  return 0
  }

#  mkdir ab
#  cd ab
#  git clone git@github.com:AlexeiKharchev/a
#  git clone git@github.com:AlexeiKharchev/b
#  cd a
#  git remote add b ../b
#  git fetch b --tags
#  git commit -m 'temp commit'
#  editor=xed git merge --allow-unrelated-histories b/main
#  git push origin main
#  git remote remove b
