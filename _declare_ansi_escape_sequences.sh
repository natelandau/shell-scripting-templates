#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::declare_ansi_escape_sequences().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Declares global display constants.
#
# These are ANSI escape sequences for controlling a VT100 terminal. Examples
# for using these constants within a script:
#
#   echo -e "${cyan_blink}foo${reset}"
#   printf "${red_bold}%s${reset}\\n" "foo"
#   printf "%b\\n" "${yellow_underline}foo${reset}"
#
# @return global string $black
#   ANSI escape sequence for black.
# @return global string $black_bold
#   ANSI escape sequence for black + bold.
# @return global string $black_faint
#   ANSI escape sequence for black + faint.
# @return global string $black_underline
#   ANSI escape sequence for black + underline.
# @return global string $black_blink
#   ANSI escape sequence for black + blink.
# @return global string $black_reverse
#   ANSI escape sequence for black + reverse.
# @return global string $red
#   ANSI escape sequence for red.
# @return global string $red_bold
#   ANSI escape sequence for red + bold.
# @return global string $red_faint
#   ANSI escape sequence for red + faint.
# @return global string $red_underline
#   ANSI escape sequence for red + underline.
# @return global string $red_blink
#   ANSI escape sequence for red + blink.
# @return global string $red_reverse
#   ANSI escape sequence for red + reverse.
# @return global string $green
#   ANSI escape sequence for green.
# @return global string $green_bold
#   ANSI escape sequence for green + bold.
# @return global string $green_faint
#   ANSI escape sequence for green + faint.
# @return global string $green_underline
#   ANSI escape sequence for green + underline.
# @return global string $green_blink
#   ANSI escape sequence for green + blink.
# @return global string $green_reverse
#   ANSI escape sequence for green + reverse.
# @return global string $yellow
#   ANSI escape sequence for yellow.
# @return global string $yellow_bold
#   ANSI escape sequence for yellow + bold.
# @return global string $yellow_faint
#   ANSI escape sequence for yellow + faint.
# @return global string $yellow_underline
#   ANSI escape sequence for yellow + underline.
# @return global string $yellow_blink
#   ANSI escape sequence for yellow + blink.
# @return global string $yellow_reverse
#   ANSI escape sequence for yellow + reverse.
# @return global string $blue
#   ANSI escape sequence for blue.
# @return global string $blue_bold
#   ANSI escape sequence for blue + bold.
# @return global string $blue_faint
#   ANSI escape sequence for blue + faint.
# @return global string $blue_underline
#   ANSI escape sequence for blue + underline.
# @return global string $blue_blink
#   ANSI escape sequence for blue + blink.
# @return global string $blue_reverse
#   ANSI escape sequence for blue + reverse.
# @return global string $magenta
#   ANSI escape sequence for magenta.
# @return global string $magenta_bold
#   ANSI escape sequence for magenta + bold.
# @return global string $magenta_faint
#   ANSI escape sequence for magenta + faint.
# @return global string $magenta_underline
#   ANSI escape sequence for magenta + underline.
# @return global string $magenta_blink
#   ANSI escape sequence for magenta + blink.
# @return global string $magenta_reverse
#   ANSI escape sequence for magenta + reverse.
# @return global string $cyan
#   ANSI escape sequence for cyan.
# @return global string $cyan_bold
#   ANSI escape sequence for cyan + bold.
# @return global string $cyan_faint
#   ANSI escape sequence for cyan + faint.
# @return global string $cyan_underline
#   ANSI escape sequence for cyan + underline.
# @return global string $cyan_blink
#   ANSI escape sequence for cyan + blink.
# @return global string $cyan_reverse
#   ANSI escape sequence for cyan + reverse.
# @return global string $white
#   ANSI escape sequence for white.
# @return global string $white_bold
#   ANSI escape sequence for white + bold.
# @return global string $white_faint
#   ANSI escape sequence for white + faint.
# @return global string $white_underline
#   ANSI escape sequence for white + underline.
# @return global string $white_blink
#   ANSI escape sequence for white + blink.
# @return global string $white_reverse
#   ANSI escape sequence for white + reverse.
#
# @example:
#   bfl::declare_ansi_escape_sequences
#
# shellcheck disable=SC2034
#------------------------------------------------------------------------------
bfl::declare_ansi_escape_sequences() {
  bfl::verify_arg_count "$#" 0 0 || exit 1

  declare -gr black="\\033[0;30m"
  declare -gr black_bold="\\033[1;30m"
  declare -gr black_faint="\\033[2;30m"
  declare -gr black_underline="\\033[4;30m"
  declare -gr black_blink="\\033[5;30m"
  declare -gr black_reverse="\\033[7;30m"

  declare -gr red="\\033[0;31m"
  declare -gr red_bold="\\033[1;31m"
  declare -gr red_faint="\\033[2;31m"
  declare -gr red_underline="\\033[4;31m"
  declare -gr red_blink="\\033[5;31m"
  declare -gr red_reverse="\\033[7;31m"

  declare -gr green="\\033[0;32m"
  declare -gr green_bold="\\033[1;32m"
  declare -gr green_faint="\\033[2;32m"
  declare -gr green_underline="\\033[4;32m"
  declare -gr green_blink="\\033[5;32m"
  declare -gr green_reverse="\\033[7;32m"

  declare -gr yellow="\\033[0;33m"
  declare -gr yellow_bold="\\033[1;33m"
  declare -gr yellow_faint="\\033[2;33m"
  declare -gr yellow_underline="\\033[4;33m"
  declare -gr yellow_blink="\\033[5;33m"
  declare -gr yellow_reverse="\\033[7;33m"

  declare -gr blue="\\033[0;34m"
  declare -gr blue_bold="\\033[1;34m"
  declare -gr blue_faint="\\033[2;34m"
  declare -gr blue_underline="\\033[4;34m"
  declare -gr blue_blink="\\033[5;34m"
  declare -gr blue_reverse="\\033[7;34m"

  declare -gr magenta="\\033[0;35m"
  declare -gr magenta_bold="\\033[1;35m"
  declare -gr magenta_faint="\\033[2;35m"
  declare -gr magenta_underline="\\033[4;35m"
  declare -gr magenta_blink="\\033[5;35m"
  declare -gr magenta_reverse="\\033[7;35m"

  declare -gr cyan="\\033[0;36m"
  declare -gr cyan_bold="\\033[1;36m"
  declare -gr cyan_faint="\\033[2;36m"
  declare -gr cyan_underline="\\033[4;36m"
  declare -gr cyan_blink="\\033[5;36m"
  declare -gr cyan_reverse="\\033[7;36m"

  declare -gr white="\\033[0;37m"
  declare -gr white_bold="\\033[1;37m"
  declare -gr white_faint="\\033[2;37m"
  declare -gr white_underline="\\033[4;37m"
  declare -gr white_blink="\\033[5;37m"
  declare -gr white_reverse="\\033[7;37m"

  declare -gr reset="\\033[0m"
}
