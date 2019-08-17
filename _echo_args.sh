#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::echo_args().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Echoes the arguments passed to this function. This is a debugging tool.
#
# This function will accept an unlimited number of arguments.
#
# @param array $parameters
#   One dimensional array of arguments passed to this function.
#
# @example
# bfl::echo_args "foo" "bar" "baz"
#------------------------------------------------------------------------------
bfl::echo_args() {
  bfl::verify_arg_count "$#" 1 999 || exit 1

  declare -ar parameters=("$@")
  declare counter=0
  declare parameter

  echo -e "\\n----- Begin output from ${FUNCNAME[0]} -----"
  echo "\$@ =" "$@"
  echo "\$# =" "$#"
  for parameter in "${parameters[@]}"; do
    ((counter++)) || true
    echo "\$${counter} = ${parameter}"
  done
  echo -e "----- End output from ${FUNCNAME[0]} -----\\n"
}
