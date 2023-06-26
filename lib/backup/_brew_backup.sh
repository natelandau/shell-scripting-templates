#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to backups
#
# @author  A. River
#
# @file
# Defines function: bfl::brew_backup().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Backup brew to directry.
#
# @param String $path
#   Directory to make backup.
#
# @param String $file_mask (optional)
#   File mask to save backup
#
# @return String $result
#   Text.
#
# @example
#   bfl::brew_backup path 'brew_backup'
#------------------------------------------------------------------------------
bfl::brew_backup() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_BREW} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'brew' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_JQ} -eq 1 ]]     || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'jq' not found";   return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: directory '$1' doesn't exist!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r file_mask=${2:-'brew_backup'}
  local -r out="$1/${file_mask}_$(date '+%Y-%m-%d_%H-%M-%S').txt"

  local fnc tc_tab tc_nln tc_tilde pkgs pkg opti optu out tmp rgx IFS IFS_DEF IFS_NLN
  printf -v tc_tab    '\t'
  printf -v tc_nln    '\n'
  printf -v tc_tilde  '~'
  printf -v IFS_DEF   ' \t\n'
  printf -v IFS_NLN   '\n'
  IFS="${IFS_DEF}"
  fnc="${FUNCNAME}"
  tmp="$( brew info --json=v1 --installed |
          jq -c '.[] | { ( .name ): .dependencies }' |
          sed -e 's="[^"]*/\([^"]*\)"="\1"=g' -e :END
  )"
  rgx="$( echo "${tmp}" |
          sed -e = \
              -e 's=^{\([^:]*\)\(.*\)}=s'"${tc_tab}"'\1\\([^:]\\)'"${tc_tab}"'{\1\2}\\1'"${tc_tab}"'=' \
              -e :END |
          sed -e '/^[0-9]*$/bLBL' \
              -e bPRT \
              -e :LBL \
              -e 's/^/:RGX/' \
              -e p \
              -e 's/^:/t/' \
              -e h \
              -e d \
              -e :PRT \
              -e 'p;g' \
              -e :END
  )"
  tmp="$( echo "${tmp}" |
          sed -f <( echo "${rgx}" ) |
          grep -o '"[^"]*"' |
          cut -d'"' -f2
  )"
  tmp="$( echo "${tmp}" |
          grep -n . |
          sort -t: -k 2,2 -k 1,1gr |
          sort -t: -k 2,2 -u |
          sort -t: -k 1,1gr |
          cut -d: -f2
  )"

  IFS="${IFS_NLN}"
  pkgs=( ${tmp} )
  IFS="${IFS_DEF}"

  brew info --json=v1 "${pkgs[@]}" | jq -r '
          .[] |
          .name as $name |
          .installed[].version as $ver |
          (
              (
                  .versions |
                  to_entries |
                  map( select( .value == $ver ) ) |
                  .[].key
              )
              //
              (
                  "version_not_found_" + $ver + "_this_will_install_default"
              )
          ) as $ver |
          (
              if $ver == "head" then
                  "HEAD"
              elif
                  $ver == "stable"
              then
                  null
              else
                  $ver
              end
          ) as $ver |
          [ .installed[].used_options[] ] as $opti |
          ( [ .options[].option ] - $opti ) as $optu |
          [
              "brew install",
              $name,
              ( if $ver then "--" + $ver else empty end ),
              $opti[],
              ( if ( $optu | length ) > 0 then "#", $optu[] else empty end )
          ] |
          join(" ")' |
      tee "${out}"

  printf "${fnc}: %s\n" "Stored in { ${out/${HOME}/${tc_tilde}} }" 1>&2

  return 0
  }
