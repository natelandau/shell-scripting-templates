#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::echo_args().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Echoes the arguments passed to this function. This is a debugging tool.
#
# This function will accept an unlimited number of arguments.
#
# @param array $parameters
#   One dimensional array of arguments passed to this function.
#------------------------------------------------------------------------------
lib::echo_args() {
  lib::validate_arg_count "$#" 1 999 || exit 1

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
