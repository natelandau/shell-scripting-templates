#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::declare_global_display_constants().
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
# @return string $black (global)
# @return string $black_bold (global)
# @return string $black_faint (global)
# @return string $black_underline (global)
# @return string $black_blink (global)
# @return string $black_reverse (global)
# @return string $red (global)
# @return string $red_bold (global)
# @return string $red_faint (global)
# @return string $red_underline (global)
# @return string $red_blink (global)
# @return string $red_reverse (global)
# @return string $green (global)
# @return string $green_bold (global)
# @return string $green_faint (global)
# @return string $green_underline (global)
# @return string $green_blink (global)
# @return string $green_reverse (global)
# @return string $yellow (global)
# @return string $yellow_bold (global)
# @return string $yellow_faint (global)
# @return string $yellow_underline (global)
# @return string $yellow_blink (global)
# @return string $yellow_reverse (global)
# @return string $blue (global)
# @return string $blue_bold (global)
# @return string $blue_faint (global)
# @return string $blue_underline (global)
# @return string $blue_blink (global)
# @return string $blue_reverse (global)
# @return string $magenta (global)
# @return string $magenta_bold (global)
# @return string $magenta_faint (global)
# @return string $magenta_underline (global)
# @return string $magenta_blink (global)
# @return string $magenta_reverse (global)
# @return string $cyan (global)
# @return string $cyan_bold (global)
# @return string $cyan_faint (global)
# @return string $cyan_underline (global)
# @return string $cyan_blink (global)
# @return string $cyan_reverse (global)
# @return string $white (global)
# @return string $white_bold (global)
# @return string $white_faint (global)
# @return string $white_underline (global)
# @return string $white_blink (global)
# @return string $white_reverse (global)
#
# @example:
#   bfl::declare_global_display_constants
#
# shellcheck disable=SC2034
#------------------------------------------------------------------------------
bfl::declare_global_display_constants() {
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
