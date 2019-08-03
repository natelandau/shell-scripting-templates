#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::declare_global_display_constants().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Declares global display constants.
#
# These are ANSI escape sequences for controlling a VT100 terminal.
# Example:
#
#   echo -e "${red}{underline}foo bar baz${reset}"
#
# @return global string $red
# @return global string $light_red
# @return global string $green
# @return global string $light_green
# @return global string $blue
# @return global string $light_blue
# @return global string $purple
# @return global string $light_purple
# @return global string $cyan
# @return global string $light_cyan
# @return global string $brown
# @return global string $yellow
# @return global string $black
# @return global string $dark_gray
# @return global string $light_gray
# @return global string $white
# @return global string $blinking
# @return global string $bold
# @return global string $reverse_video
# @return global string $underline
# @return global string $reset
#
# shellcheck disable=SC2034
#------------------------------------------------------------------------------
bfl::declare_global_display_constants() {
  bfl::validate_arg_count "$#" 0 0 || exit 1

  # Declare colors.
  declare -rg red="\\e[0;31m"
  declare -rg light_red="\\e[1;31m"
  declare -rg green="\\e[0;32m"
  declare -rg light_green="\\e[1;32m"
  declare -rg blue="\\e[0;34m"
  declare -rg light_blue="\\e[1;34m"
  declare -rg purple="\\e[0;35m"
  declare -rg light_purple="\\e[1;35m"
  declare -rg cyan="\\e[0;36m"
  declare -rg light_cyan="\\e[1;36m"
  declare -rg brown="\\e[0;33m"
  declare -rg yellow="\\e[1;33m"
  declare -rg black="\\e[0;30m"
  declare -rg dark_gray="\\e[1;30m"
  declare -rg light_gray="\\e[0;37m"
  declare -rg white="\\e[1;37m"

  # Declare styles.
  declare -rg blinking="\\e[5m"
  declare -rg bold="\\e[1m"
  declare -rg reverse_video="\\e[7m"
  declare -rg underline="\\e[4m"

  # Declare reset (turn off character attributes).
  declare -rg reset="\\e[0m"
}
