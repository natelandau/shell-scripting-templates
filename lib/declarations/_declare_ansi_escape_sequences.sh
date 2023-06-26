#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to constants declarations
#
# @author  Joe Mooring
#
# @file
# Defines and calls function: bfl::declare_ansi_escape_sequences().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Declares ANSI escape sequences.
#
# These are ANSI escape sequences for controlling a VT100 terminal. Examples
# for using these constants within a script:
#
#   echo -e "${bfl_aes_yellow}foo${bfl_aes_reset}"
#   printf "${bfl_aes_yellow}%s${bfl_aes_reset}\\n" "foo"
#   printf "%b\\n" "${bfl_aes_yellow}foo${bfl_aes_reset}"
#
# In some cases it may be desirable to disable color output. For example, let's
# say you've written a script leveraging this library. When you run the script
# in a terminal, you'd like to see the error messages in color. However, when
# run as a cron job, you don't want to see the ANSI escape sequences
# surrounding error messages when viewing logs or emails sent by cron.
#
# To disable color output, set the BASH_FUNCTION_LIBRARY_COLOR_OUTPUT
# environment variable to "disabled" before sourcing the autoloader. For
# example:
#   export BASH_FUNCTION_LIBRARY_COLOR_OUTPUT=disabled
#   if ! source "${BASH_FUNCTION_LIBRARY}"; then
#     printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
#     exit 1
#   fi
#
#       FOR 'black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white'
# @return global string $bfl_aes_color
#   ANSI escape sequence for color.
# @return global string $bfl_aes_color_bold
#   ANSI escape sequence for color + bold.
# @return global string $bfl_aes_color_faint
#   ANSI escape sequence for color + faint.
# @return global string $bfl_aes_color_underline
#   ANSI escape sequence for color + underline.
# @return global string $bfl_aes_color_blink
#   ANSI escape sequence for color + blink.
# @return global string $bfl_aes_color_reverse
#   ANSI escape sequence for color + reverse.
#
# -----------------------------------------------------------------------------
# @return global string $bfl_aes_reset
#   ANSI escape sequence for WITHOUT_COLOR
#
# @example:
#   bfl::declare_ansi_escape_sequences
#------------------------------------------------------------------------------
# shellcheck disable=SC2034
bfl::declare_ansi_escape_sequences() {
  [[ "${BASH_FUNCTION_LIBRARY_COLOR_OUTPUT:=enabled}" = "disabled" ]] && local bEnabled=false || local bEnabled=true
#  [[ "$TERM" =~ 256color ]] && local use256=true || local use256=false
#                                                      magenta
  local ar_clrs=('black' 'red' 'green' 'yellow' 'blue' 'purple' 'cyan' 'white')
  local ar_nmbrs=(30 31 32 33 34 35 36 37)

  local max=${#ar_clrs[@]}
  local -i i
  local sColor sNumbr s
  # shellcheck disable=SC2034
  for ((i = 0; i < max; i++)); do
      sColor=${ar_clrs[$i]}; iNumbr=${ar_nmbrs[$i]};
      s="bfl_aes_$sColor";             $bEnabled && declare -gr $s="\\033[0;${iNumbr}m" || declare -gr $s=""
      s="bfl_aes_${sColor}_bold";      $bEnabled && declare -gr $s="\\033[1;${iNumbr}m" || declare -gr $s=""
      s="bfl_aes_${sColor}_faint";     $bEnabled && declare -gr $s="\\033[2;${iNumbr}m" || declare -gr $s=""
      s="bfl_aes_${sColor}_underline"; $bEnabled && declare -gr $s="\\033[4;${iNumbr}m" || declare -gr $s=""
      s="bfl_aes_${sColor}_blink";     $bEnabled && declare -gr $s="\\033[5;${iNumbr}m" || declare -gr $s=""
      s="bfl_aes_${sColor}_reverse";   $bEnabled && declare -gr $s="\\033[7;${iNumbr}m" || declare -gr $s=""
  done
#                                       \[\033[00m\]
  $bEnabled && declare -gr bfl_aes_reset="\\033[0m"  || declare -gr bfl_aes_reset=""

  $bEnabled && declare -gr bfl_aes_gray="\033[0;37m" || declare -gr bfl_aes_gray=""
  }

bfl::declare_ansi_escape_sequences

# ---------------------------- colors -------------------------------

# readonly RED_E='\[\e[0;31m\]'
# readonly PALERED_E=''                #                '\033[38;5;9m'
# readonly LIGHTRED_E='\[\e[1;31m\]'
# readonly GREEN_E='\[\e[0;32m\]'      # '\033[0;32m'   '\033[38;5;2m'
# readonly LIGHTGREEN_E='\[\e[1;32m\]' # '\033[1;32m'   '\033[38;5;10m'
# readonly YELOW_E='\[\e[0;33m\]'
# readonly LIGHTYELOW_E='\[\e[1;33m\]' #                '\033[38;5;11m'
# readonly BLACK_E='\[\e[0;30m\]'
# readonly DARKGRAY_E='\[\e[1;30m\]'
# readonly ORANGE_E='\[\e[1;33m\]'
# readonly BLUE_E='\[\e[0;34m\]'
# readonly PALEBLUE_E=''               #                '\033[38;5;12m'
# readonly LIGHTBLUE_E='\[\e[1;34m\]'  # '\033[1;34m'
# readonly PURPLE_E='\[\e[0;35m\]'
# readonly LIGHTPURPLE_E='\[\e[1;35m\]'
# readonly CYAN_E='\[\e[0;36m\]'       #                 '\033[38;5;14m'
# readonly LIGHTCYAN_E='\[\e[1;36m\]'
# readonly LIGHTGRAY_E='\[\e[0;37m\]'
# readonly WHITE_E='\[\e[1;37m\]'
# readonly NORMAL_E='\[\e[0m\]' # '\033[0m' # No color
