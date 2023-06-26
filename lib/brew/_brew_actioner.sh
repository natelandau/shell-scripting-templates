#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to brew
#
# @author  A. River
#
# @file
# Defines function: bfl::brew_actioner().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Run Homebrew ( brew ) commands via shortcuts, or 'smarter' invocations.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_actioner
#------------------------------------------------------------------------------
bfl::brew_actioner() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_BREW} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'brew' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_TPUT} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'tput' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  declare vars=(
      str
      fnc                 # Function name, for errors, etc.
      fnc_msg             # Message code for function.
      fnc_return          # Return code for function.

      act                 # Action ( What brew is being asked to do. )
      args arg            # Arguments provided to these functions.
      tmp                 # General termporary variable.
      results             # Output of invoked brew commands.

      IFS                 # Override default shell IFS, for manipulation of IO.

      # TERM codes for display enhancement.
      tc_rst              # Reset
      tc_rev              # Reverse
      )
  declare ${vars[*]}

  printf -v IFS '\n\n\n'  # Delimit IO on newline only.
  fnc="${FUNCNAME[1]}"    # What was brew_actioner *called* as?
  # Message code for function.
  fnc_msg=( printf "${fnc}: %s\n" )

  act="${fnc#brew}"       # What action was requested?
  args=( "${@}" )         # Store arguments to calling function.
  # Init 'results' and 'tmp' as arrays.
  results=()
  tmp=()
  # Execute brew actions..
  case "${act}" in
      # These actions are just simple shortcuts.
      # No output manipulation.

      "I"  ) brew install    "${args[@]}" ;;
      "U"  ) brew uninstall  "${args[@]}" ;;
      "u"  ) brew update     "${args[@]}" ;;
      "Up" ) brew upgrade    "${args[@]}" ;;
      "R"  ) brew uninstall  "${args[@]}"
             brew install    "${args[@]}"
             ;;

      "h"  ) brew home       "${args[@]}" ;;

      # Actions where results are stored for further manipulation.
      "s"  ) str=$( brew search "${args[@]}" )
             results=($str) ;;
      "l"  ) str=$( brew list "${args[@]}" )
             results=($str) ;;

      # The ouput of 'info' for multiple packages can be hard to read.
      # This just helps out some.
      # It *does* inhibit the use of options to the info action.

      "i"  ) tc_rev="$( tput rev )"
             tc_rst="$( tput sgr0 )"
             for arg in "${args[@]}"; do
                 tmp=( $( brew info "${arg}" ) )
                 tmp[0]="${tc_rev}${tmp[0]}${tc_rst}"
                 results=( "${results[@]}" "" "${tmp[@]}" )
                 fnc_return="$(( ${fnc_return:-0} + ${?} ))" # Store return codes.
             done
             ;;

      # Just in case the actioner gets called with an unknown function/action.
      * )    bfl::writelog_fail "${FUNCNAME[0]}: Unknown action ( ${act} )";
             return 1 ;;
  esac

  [[ -z "${fnc_return}" ]] && fnc_return="${?}"   # If return value is still null, assign the latest error code.
  [[ "${#results[@]}" -gt 0 ]] || return 0        # If no results, then just return from function.

  # Print results, using a pager if result count is greater than height of our terminal.
  printf '%s\n' "${results[@]}" |
      { [[ "${#results[@]}" -lt ${LINES:-0} ]] && cat - || less -isR; }

  return 0
  }
