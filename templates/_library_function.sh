#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::library_function(). # TODO
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Does something.   # TODO
#   Detailed description. Use multiple lines if needed. # TODO
#
# @param Type $foo  # TODO
#   Description.    # TODO
#
# @param Type $bar  # TODO
#   Description.    # TODO
#
# @return Type $baz # TODO
#   Description.    # TODO
#
# @example
#   bfl::library_function "Fred" "George" # TODO
#------------------------------------------------------------------------------
bfl::library_function() {
  bfl::verify_arg_count "$#" 1 2    || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count. # TODO

  bfl::verify_dependencies 'perl'   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'perl' is not found!"; return $BFL_ErrCode_Not_verified_dependency; } # TODO

  # Verify argument values.
  bfl::is_empty "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: Foo is required."; return $BFL_ErrCode_Not_verified_arg_values; } # TODO
  bfl::is_empty "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: Bar is required."; return $BFL_ErrCode_Not_verified_arg_values; } # TODO

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

  # Build the return value.
  baz="${foo}, ${bar}, ${wibble}, ${wobble}, ${eggs}, and ${ham}." # TODO

  # Print the return value.
  printf "%s\\n" "${baz}"   # TODO
  return 0
  }
