#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Bash
#
# @author  A. River
#
# @file
# Defines function: bfl::bash_command_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Display list of commands and where they are defined.
#   If called as *_overrides or with --overrides, only show those defined multiple times.
#   Includes BASH Alias/Keyword/Function/Builtin entries.
#
# @param String $args
#   Arguments list.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::bash_command_list ....
#------------------------------------------------------------------------------
bfl::bash_command_list() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # List of local strings.
  declare vars_sl_=(
      str
      fnc                     # Function name.
      tmp                     # General temporary variable.
      arg                     # Argument for parsing.

      # TERM chars for regex/delim use.
      tc_spc tc_tab tc_nln    # Space, Tab, Newline
      tc_tilde tc_fslash      # Tilde, Forward-slash

      # Values for IFS assignment.
      IFS_DEF                 # Default IFS
      IFS_TAN                 # Break on Tab/Newline
      IFS_NLN                 # Break only on Newline
      IFS_RGX                 # Glob using pipe '|'

      typ dir cmd file
      )

  # List of exported local strings.
  declare vars_slx=( IFS )
  # List of local arrays.
  declare vars_al_=(
      args                    # Arguments to function.
      typs dirs cmds cmd_typs
      )
  # List of local integers.
  declare vars_il_=(
      fnc_return
      i
      flg_overrides           # Ran in list-overrides mode?
      )
  # List of all local variables.
  declare vars____=( ${vars_sl_[*]} ${vars_slx[*]} ${vars_al_[*]} ${vars_il_[*]} )
  # Declare variables.
  declare    ${vars_sl_[*]}
  declare -x ${vars_slx[*]}
  declare -a ${vars_al_[*]}
  declare -i ${vars_il_[*]}

  fnc="${FUNCNAME[0]}"    # This function.
  fnc_return=0            # Return code for this function.

  # Assign various delimiters for IO
  printf -v tc_spc    ' '
  printf -v tc_tab    '\t'
  printf -v tc_nln    '\n'
  printf -v tc_tilde  '~'
  printf -v tc_fslash '/'
  printf -v IFS_DEF   ' \t\n'
  printf -v IFS_TAN   '\t\t\n'
  printf -v IFS_NLN   '\n\n\n'
  printf -v IFS_RGX   '|\t\n'
  IFS="${IFS_DEF}"

  flg_overrides=0
  args=( "${@}" )
  for (( i=0; i < "${#args[@]}"; i++ )); do
      [[ "${args[${i}]}" == --* ]] || continue
      case "${args[${i}]:2}" in
          overrides ) flg_overrides=1 ;;
      esac
      unset args[${i}]
  done

  args=( "${args[@]}" )
  typs=( alias keyword function builtin file )       # Default types of commands for BASH.
  IFS="${IFS_NLN}"                                   # Break on newline only.
  dirs=( ${PATH//:/${tc_nln}} )                      # Array of command paths.
  str=$( compgen -A command "${args[@]}" | sort -u )
  cmds=( $str )                  # Use completion capability to generate list of commands.

  # Reset IFS to default.
  IFS="${IFS_DEF}"

  # For each command found ..
  for cmd in "${cmds[@]}"; do
      cmd_typs=( $( type -at "${cmd}" ) )   # .. find all known types.
      # This function is only concerned with overrides ( i.e. duplicates )
      [ "${#cmd_typs[@]}" -gt 1 -o "${flg_overrides}" -eq 0 ] || continue
      printf %s "${cmd}"            # Show what command we're looking at.

      for typ in "${typs[@]}"; do
          # For all types other than 'file', simply show that any entry was found ..
          [[ "${typ}" == "file" ]] || {
              [[ "${cmd_typs[*]}" =~ ^(.* )?${typ}( .*)?$ ]] && printf '\t%s' "${typ}"
              continue  # .. then continue to the next entry.
              }
          # Once we find 'file' types, move on to the next stage.
          break
      done

      # If the last type found was 'file', then let's find them.
      [[ "${typ}" == "file" ]] && {
          # For each directory in our PATH ..
          for dir in "${dirs[@]}"; do
              file="${dir}/${cmd}"

              # .. show any entry for the current command.
              # ( further, if in home-dir, shorten/anonymize the entry. )
              [ -d "${file}" -o ! -r "${file}" -o ! -x "${file}" ] \
                  || printf '\t%s' "${dir/#${HOME}${tc_fslash}/${tc_tilde}${tc_fslash}}"
          done
          }

      printf '\n'   # New is always better! ;P
  done

  return "${fnc_return:-0}"
  }
