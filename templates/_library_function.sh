#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::library_function(). # TODO
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Does something.   # TODO
#
# Detailed description. Use multiple lines if needed. # TODO
#
# @param type $foo  # TODO
#   Description.    # TODO
#
# @param type $bar  # TODO
#   Description.    # TODO
#
# @return type $baz # TODO
#   Description.    # TODO
#
# @example
#   bfl::library_function "Fred" "George" # TODO
#------------------------------------------------------------------------------
bfl::library_function() {
  bfl::verify_arg_count "$#" 1 2    || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return 1; } # Verify argument count. # TODO
  bfl::verify_dependencies "printf" || { bfl::writelog_fail "${FUNCNAME[0]}: dependency printf not found"; return 1; } # Verify dependencies.   # TODO

  # Declare positional arguments (readonly, sorted by position).
  declare -r foo="$1"       # TODO
  declare -r bar="$2"       # TODO

  # Declare return value.
  declare baz # TODO

  # Declare readonly variables (sorted by name).
  declare -r wibble="Harry" # TODO
  declare -r wobble="Ron"   # TODO

  # Declare all other variables (sorted by name).
  declare eggs="Dean"       # TODO
  declare ham="Seamus"      # TODO

  # Verify argument values.
  bfl::is_empty "${foo}" && { bfl::writelog_fail "${FUNCNAME[0]}: Foo is required."; return 1; } # TODO
  bfl::is_empty "${bar}" && { bfl::writelog_fail "${FUNCNAME[0]}: Bar is required."; return 1; } # TODO

  # Build the return value.
  baz="${foo}, ${bar}, ${wibble}, ${wobble}, ${eggs}, and ${ham}." # TODO

  # Print the return value.
  printf "%s\\n" "${baz}"   # TODO
  return 0
  }
