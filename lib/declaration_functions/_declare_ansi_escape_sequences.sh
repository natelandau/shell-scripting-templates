#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines and calls function: bfl::declare_ansi_escape_sequences().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Declares ANSI escape sequences.
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
#
#   export BASH_FUNCTION_LIBRARY_COLOR_OUTPUT=disabled
#   if ! source "${BASH_FUNCTION_LIBRARY}"; then
#     printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
#     exit 1
#   fi
#
# @return global string $bfl_aes_black
#   ANSI escape sequence for black.
# @return global string $bfl_aes_black_bold
#   ANSI escape sequence for black + bold.
# @return global string $bfl_aes_black_faint
#   ANSI escape sequence for black + faint.
# @return global string $bfl_aes_black_underline
#   ANSI escape sequence for black + underline.
# @return global string $bfl_aes_black_blink
#   ANSI escape sequence for black + blink.
# @return global string $bfl_aes_black_reverse
#   ANSI escape sequence for black + reverse.
# @return global string $bfl_aes_red
#   ANSI escape sequence for red.
# @return global string $bfl_aes_red_bold
#   ANSI escape sequence for red + bold.
# @return global string $bfl_aes_red_faint
#   ANSI escape sequence for red + faint.
# @return global string $bfl_aes_red_underline
#   ANSI escape sequence for red + underline.
# @return global string $bfl_aes_red_blink
#   ANSI escape sequence for red + blink.
# @return global string $bfl_aes_red_reverse
#   ANSI escape sequence for red + reverse.
# @return global string $bfl_aes_green
#   ANSI escape sequence for green.
# @return global string $bfl_aes_green_bold
#   ANSI escape sequence for green + bold.
# @return global string $bfl_aes_green_faint
#   ANSI escape sequence for green + faint.
# @return global string $bfl_aes_green_underline
#   ANSI escape sequence for green + underline.
# @return global string $bfl_aes_green_blink
#   ANSI escape sequence for green + blink.
# @return global string $bfl_aes_green_reverse
#   ANSI escape sequence for green + reverse.
# @return global string $bfl_aes_yellow
#   ANSI escape sequence for yellow.
# @return global string $bfl_aes_yellow_bold
#   ANSI escape sequence for yellow + bold.
# @return global string $bfl_aes_yellow_faint
#   ANSI escape sequence for yellow + faint.
# @return global string $bfl_aes_yellow_underline
#   ANSI escape sequence for yellow + underline.
# @return global string $bfl_aes_yellow_blink
#   ANSI escape sequence for yellow + blink.
# @return global string $bfl_aes_yellow_reverse
#   ANSI escape sequence for yellow + reverse.
# @return global string $bfl_aes_blue
#   ANSI escape sequence for blue.
# @return global string $bfl_aes_blue_bold
#   ANSI escape sequence for blue + bold.
# @return global string $bfl_aes_blue_faint
#   ANSI escape sequence for blue + faint.
# @return global string $bfl_aes_blue_underline
#   ANSI escape sequence for blue + underline.
# @return global string $bfl_aes_blue_blink
#   ANSI escape sequence for blue + blink.
# @return global string $bfl_aes_blue_reverse
#   ANSI escape sequence for blue + reverse.
# @return global string $bfl_aes_magenta
#   ANSI escape sequence for magenta.
# @return global string $bfl_aes_magenta_bold
#   ANSI escape sequence for magenta + bold.
# @return global string $bfl_aes_magenta_faint
#   ANSI escape sequence for magenta + faint.
# @return global string $bfl_aes_magenta_underline
#   ANSI escape sequence for magenta + underline.
# @return global string $bfl_aes_magenta_blink
#   ANSI escape sequence for magenta + blink.
# @return global string $bfl_aes_magenta_reverse
#   ANSI escape sequence for magenta + reverse.
# @return global string $bfl_aes_cyan
#   ANSI escape sequence for cyan.
# @return global string $bfl_aes_cyan_bold
#   ANSI escape sequence for cyan + bold.
# @return global string $bfl_aes_cyan_faint
#   ANSI escape sequence for cyan + faint.
# @return global string $bfl_aes_cyan_underline
#   ANSI escape sequence for cyan + underline.
# @return global string $bfl_aes_cyan_blink
#   ANSI escape sequence for cyan + blink.
# @return global string $bfl_aes_cyan_reverse
#   ANSI escape sequence for cyan + reverse.
# @return global string $bfl_aes_white
#   ANSI escape sequence for white.
# @return global string $bfl_aes_white_bold
#   ANSI escape sequence for white + bold.
# @return global string $bfl_aes_white_faint
#   ANSI escape sequence for white + faint.
# @return global string $bfl_aes_white_underline
#   ANSI escape sequence for white + underline.
# @return global string $bfl_aes_white_blink
#   ANSI escape sequence for white + blink.
# @return global string $bfl_aes_white_reverse
#   ANSI escape sequence for white + reverse.
#
# @example:
#   bfl::declare_ansi_escape_sequences
#
# shellcheck disable=SC2034
#------------------------------------------------------------------------------
bfl::declare_ansi_escape_sequences() {
  if [[ "${BASH_FUNCTION_LIBRARY_COLOR_OUTPUT:=enabled}" = "disabled" ]]; then

    declare -gr bfl_aes_black=""
    declare -gr bfl_aes_black_bold=""
    declare -gr bfl_aes_black_faint=""
    declare -gr bfl_aes_black_underline=""
    declare -gr bfl_aes_black_blink=""
    declare -gr bfl_aes_black_reverse=""

    declare -gr bfl_aes_red=""
    declare -gr bfl_aes_red_bold=""
    declare -gr bfl_aes_red_faint=""
    declare -gr bfl_aes_red_underline=""
    declare -gr bfl_aes_red_blink=""
    declare -gr bfl_aes_red_reverse=""

    declare -gr bfl_aes_green=""
    declare -gr bfl_aes_green_bold=""
    declare -gr bfl_aes_green_faint=""
    declare -gr bfl_aes_green_underline=""
    declare -gr bfl_aes_green_blink=""
    declare -gr bfl_aes_green_reverse=""

    declare -gr bfl_aes_yellow=""
    declare -gr bfl_aes_yellow_bold=""
    declare -gr bfl_aes_yellow_faint=""
    declare -gr bfl_aes_yellow_underline=""
    declare -gr bfl_aes_yellow_blink=""
    declare -gr bfl_aes_yellow_reverse=""

    declare -gr bfl_aes_blue=""
    declare -gr bfl_aes_blue_bold=""
    declare -gr bfl_aes_blue_faint=""
    declare -gr bfl_aes_blue_underline=""
    declare -gr bfl_aes_blue_blink=""
    declare -gr bfl_aes_blue_reverse=""

    declare -gr bfl_aes_magenta=""
    declare -gr bfl_aes_magenta_bold=""
    declare -gr bfl_aes_magenta_faint=""
    declare -gr bfl_aes_magenta_underline=""
    declare -gr bfl_aes_magenta_blink=""
    declare -gr bfl_aes_magenta_reverse=""

    declare -gr bfl_aes_cyan=""
    declare -gr bfl_aes_cyan_bold=""
    declare -gr bfl_aes_cyan_faint=""
    declare -gr bfl_aes_cyan_underline=""
    declare -gr bfl_aes_cyan_blink=""
    declare -gr bfl_aes_cyan_reverse=""

    declare -gr bfl_aes_white=""
    declare -gr bfl_aes_white_bold=""
    declare -gr bfl_aes_white_faint=""
    declare -gr bfl_aes_white_underline=""
    declare -gr bfl_aes_white_blink=""
    declare -gr bfl_aes_white_reverse=""

    declare -gr bfl_aes_reset=""

  else

    declare -gr bfl_aes_black="\\033[0;30m"
    declare -gr bfl_aes_black_bold="\\033[1;30m"
    declare -gr bfl_aes_black_faint="\\033[2;30m"
    declare -gr bfl_aes_black_underline="\\033[4;30m"
    declare -gr bfl_aes_black_blink="\\033[5;30m"
    declare -gr bfl_aes_black_reverse="\\033[7;30m"

    declare -gr bfl_aes_red="\\033[0;31m"
    declare -gr bfl_aes_red_bold="\\033[1;31m"
    declare -gr bfl_aes_red_faint="\\033[2;31m"
    declare -gr bfl_aes_red_underline="\\033[4;31m"
    declare -gr bfl_aes_red_blink="\\033[5;31m"
    declare -gr bfl_aes_red_reverse="\\033[7;31m"

    declare -gr bfl_aes_green="\\033[0;32m"
    declare -gr bfl_aes_green_bold="\\033[1;32m"
    declare -gr bfl_aes_green_faint="\\033[2;32m"
    declare -gr bfl_aes_green_underline="\\033[4;32m"
    declare -gr bfl_aes_green_blink="\\033[5;32m"
    declare -gr bfl_aes_green_reverse="\\033[7;32m"

    declare -gr bfl_aes_yellow="\\033[0;33m"
    declare -gr bfl_aes_yellow_bold="\\033[1;33m"
    declare -gr bfl_aes_yellow_faint="\\033[2;33m"
    declare -gr bfl_aes_yellow_underline="\\033[4;33m"
    declare -gr bfl_aes_yellow_blink="\\033[5;33m"
    declare -gr bfl_aes_yellow_reverse="\\033[7;33m"

    declare -gr bfl_aes_blue="\\033[0;34m"
    declare -gr bfl_aes_blue_bold="\\033[1;34m"
    declare -gr bfl_aes_blue_faint="\\033[2;34m"
    declare -gr bfl_aes_blue_underline="\\033[4;34m"
    declare -gr bfl_aes_blue_blink="\\033[5;34m"
    declare -gr bfl_aes_blue_reverse="\\033[7;34m"

    declare -gr bfl_aes_magenta="\\033[0;35m"
    declare -gr bfl_aes_magenta_bold="\\033[1;35m"
    declare -gr bfl_aes_magenta_faint="\\033[2;35m"
    declare -gr bfl_aes_magenta_underline="\\033[4;35m"
    declare -gr bfl_aes_magenta_blink="\\033[5;35m"
    declare -gr bfl_aes_magenta_reverse="\\033[7;35m"

    declare -gr bfl_aes_cyan="\\033[0;36m"
    declare -gr bfl_aes_cyan_bold="\\033[1;36m"
    declare -gr bfl_aes_cyan_faint="\\033[2;36m"
    declare -gr bfl_aes_cyan_underline="\\033[4;36m"
    declare -gr bfl_aes_cyan_blink="\\033[5;36m"
    declare -gr bfl_aes_cyan_reverse="\\033[7;36m"

    declare -gr bfl_aes_white="\\033[0;37m"
    declare -gr bfl_aes_white_bold="\\033[1;37m"
    declare -gr bfl_aes_white_faint="\\033[2;37m"
    declare -gr bfl_aes_white_underline="\\033[4;37m"
    declare -gr bfl_aes_white_blink="\\033[5;37m"
    declare -gr bfl_aes_white_reverse="\\033[7;37m"

    declare -gr bfl_aes_reset="\\033[0m"

  fi
}

bfl::declare_ansi_escape_sequences
