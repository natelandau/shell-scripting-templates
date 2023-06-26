#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of internal library functions
#
# @author  A. River
#
# @file
# Defines function: bfl::function_actioner().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ........................
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::function_actioner
#------------------------------------------------------------------------------
bfl::function_actioner() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  declare vars_sl_=(
      fnc
      tmp
      tc_spc tc_tab tc_nln
      tc_tilde tc_fslash
      IFS_DEFAULT IFS_TAN IFS_NLN IFS_RGX
      act
      ent
      rgx rgx_ent rgx_h rgx_f
      fname fline
      ffile
      editor
      editor_typ
      )

  declare vars_slx=(
      IFS
      )

  declare vars_al_=(
      ents
      ffiles
      ffiles_fnames
      fnames
      ffiles_flines
      flines
      editor_cmd
      )

  declare vars_il_=(
      fnc_return
      flg_help
      flg_home
      i j
      ents_max
      )

  declare vars____=(
      ${vars_sg_[*]} ${vars_sgx[*]} ${vars_sl_[*]} ${vars_slx[*]}
      ${vars_ag_[*]} ${vars_agx[*]} ${vars_al_[*]} ${vars_alx[*]}
      ${vars_ig_[*]} ${vars_igx[*]} ${vars_il_[*]} ${vars_ilx[*]}
      )

  declare    ${vars_sl_[*]}
  declare -x ${vars_slx[*]}
  declare -a ${vars_al_[*]}
  declare -i ${vars_il_[*]}

  fnc="${FUNCNAME[0]}"
  fnc_return=0

  printf -v tc_spc ' '
  printf -v tc_tab '\t'
  printf -v tc_nln '\n'

  printf -v tc_tilde  '~'
  printf -v tc_fslash '/'

  printf -v IFS_DEFAULT   ' \t\n'
  printf -v IFS_TAN     '\t\t\n'
  printf -v IFS_NLN     '\n\n\n'
  printf -v IFS_RGX     '|\t\n'
  IFS="${IFS_DEFAULT}"

  act="${FUNCNAME[1]:-${FUNCNAME[0]}}"

  [ "${fnc%%_*}" == "${act%%_*}" -a "${act}" != "${fnc}" ] || {
      printf -- "${fnc}: %s\n" "Not to be called directly."
      return 9
      }

  fnc="${act}"
  act="${act#*_}"

  flg_help=0
  for i in "${@}"; do
      [[ "${i}" =~ ^[-]+h ]] || continue
      flg_help=1
      break
  done

  [[ "${flg_help}" -eq 0 ]] || {
      printf -- "${fnc}: %s\n" \
              "Perform ${act%_home} of functions from source files." \
              "Provide function names as arguments." \
              "Empty argument list acts on all current functions."
      [[ "${act##*_}" != "home" ]] || printf -- "${fnc}: %s\n" "The 'home' actions are limited to home directory functions."
      return 1
      }

  [[ "${act##*_}" == "home" ]] && flg_home=1 || flg_home=0

  act="${act%_home}"

  [[ "${#}" -gt 0 ]] && fnames=( "${@}" ) || fnames=( $( compgen -A function ) )

  IFS="${IFS_NLN}"
  ents=( $( {
      shopt -s extdebug;
      declare -F "${fnames[@]}";
      shopt -u extdebug;
  } ) )
  IFS="${IFS_DEFAULT}"

  rgx_ent='^([^[:blank:]]+)([[:blank:]]+)([^[:blank:]]+)([[:blank:]]+)(.*)'

  ents_max="${#ents[@]}"

  for (( i=0; i < ents_max; i++ )); do
      ent="${ents[${i}]}"

      [[ "${ent}" =~ ${rgx_ent} ]] || {
          printf -- "${fnc}: Bad Location Format { %q }!" "${ent}" 1>&2
          unset ents[${i}]
          continue
          }

      fname="${BASH_REMATCH[1]}"
      fline="${BASH_REMATCH[3]}"
      ffile="${BASH_REMATCH[5]}"

      [[ "${flg_home}" -eq 0 ]] || [[ "${ffile}" == ${HOME}/* ]] || { unset ents[${i}]; continue; }
      ents[${i}]="${fname}${tc_tab}${fline}${tc_tab}${ffile}"
      [[ "${act}" == "locate" ]] && continue

      IFS="${IFS_TAN}"
      if [[ "${ffiles[*]}" =~ ^(.*${tc_tab})?${ffile}(${tc_tab}.*)?$ ]]; then
          for (( j=0; j < ${#ffiles[@]}; j++ )); do
              [[ "${ffile}" == "${ffiles[${j}]}" ]] || continue
              break
          done
      else
          j="${#ffiles[@]}"
          ffiles[${j}]="${ffile}"
      fi
      IFS="${IFS_DEFAULT}"

      ffiles_fnames[${j}]="${ffiles_fnames[${j}]}${ffiles_fnames[${j}]:+:}${fname}"
      ffiles_flines[${j}]="${ffiles_flines[${j}]}${ffiles_flines[${j}]:+:}${fline}"
  done

  ents=( "${ents[@]}" )

  case "${act}" in
      "locate" ) {
          printf '%s\n' "${ents[@]/${tc_tab}${HOME}\//${tc_tab}${tc_tilde}/}" |
              sort -t"${tc_tab}" -k 3,99 -k 2,2g -k 1,1 |
              { [[ -t 1 ]] && column -ts"${tc_tab}" || cat -; }
          };;

      * ) {
          [[ "${act}" == "edit" ]] && {
              editor="${EDITOR:-${VISUAL:-${FCEDIT:-vim}}}"
              [[ -n "${editor_typ}" ]] || ! [[ "${editor}" =~ ^(.*/)?([gm]?vim)( .*)?$ ]] || editor_typ=vim
              [[ -n "${editor_typ}" ]] || printf -- "${fnc}: %s\n" "Proceeding with unknown editor { ${editor} }"
              }

          for (( i=0; i < ${#ffiles[@]}; i++ )); do
              ffile="${ffiles[${i}]}"
              fnames=( ${ffiles_fnames[${i}]//:/ } )
              flines=( ${ffiles_flines[${i}]//:/ } )

              [[ "${act}" == "edit" ]] && {
                  editor_cmd=( ${editor} )

                  case "${editor_typ}" in
                      "vim" ) {
                              IFS="${IFS_RGX}"
                              rgx="${fnames[*]}"
                              IFS="${IFS_DEFAULT}"
                              rgx="${rgx//|/\|}"
                              printf -v rgx_h '\(function \+\|^\)\@<=\(%s\)\( \|$\)\@=' "${rgx}"
                              printf -v rgx_f '\(function \+\|^\)\@<=\(%s\)\( \|$\)\@=' "${rgx}"

                              editor_cmd=(
                                  "${editor_cmd[@]}"
                                  "+:highlight bash_functions ctermbg=white ctermfg=black guibg=white guifg=black"
                                  "+:match bash_functions /${rgx_h}/"
                                  "+/${rgx_f}"
                                  "${ffile}"
                                  )
                              };;

                      * )  {
                           editor_cmd=( "${editor_cmd[@]}" "${ffile}" )
                           };;
                  esac

                  printf -- "${fnc}: %s\n" "edit: ${ffile/#${HOME}${tc_fslash}/${tc_tilde}${tc_fslash}} ( ${fnames[*]} )"
                  "${editor_cmd[@]}"
                  }

              printf -- "${fnc}: %s\n" "load: ${ffile/#${HOME}${tc_fslash}/${tc_tilde}${tc_fslash}} ( ${fnames[*]} )"
              . "${ffile}" || fnc_return=9

          done
      };;
  esac

  return "${fnc_return}"
  }
