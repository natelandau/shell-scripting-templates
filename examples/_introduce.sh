#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::introduce().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Introduces a person given their name and age.
#
# This is a silly example of a function that could be added to the Bash
# Function Library. Because the filename begins with an underscore, if this
# file were placed in the library's root directory, it would autoload with the
# other library functions.
#
# This file must not be executable, and its extension must be .sh.
#
# The tags in the file and function headers (@file, @function, @param,
# @return, and @example) are parsed by the library's documentation generator,
# makedoc, located in the docs directory.
#
#-----
#
# The @param tag must be formatted as follows:
#
#   @param type $name [(optional)]
#     Description.
#
# Bash can only pass string values to a function. The "type" attribute
# describes what type of string the function is expecting (string, integer,
# true/false).
#
# If the parameter is optional, add "(optional)" after the name. Obviously,
# with positional arguments, optional arguments must be sequential, right to
# left. For example, with 3 arguments:
#
#   - The 3rd argument can be optional.
#   - If the 3rd argument is optional, the 2nd can also be optional.
#   - If the 3rd and 2nd arguments are optional, the 1st can also be optional.
#
# For simple functions, positional arguments are generally sufficient. For
# complex implementations consider getopt or getopts.
#
#-----
#
# The @return tag must be formatted as follows:
#
#   @return [global] type $name
#     Description.
#
# Note that @return is misleading. Bash functions cannot return an arbitrary
# value. They return an exit status (0-255) where zero indicates success. To
# return an arbitrary value to the caller this library relies on command
# substitution. Each library function that "returns" a value does so by
# printing the value to stdout. The caller uses command substitution to capture
# this value.
#
# For example, to capture the "return" value of this function from a script:
#
#   introduction=$(bfl::introduce "John" "25") ||
#     bfl::die "Unable to create introduction."
#
# Note that we test the exit status of the command substitution, and in this
# case call bfl::die with an error message upon failure.
#
# If the library function "returns" a value by printing, assign the value to a
# variable, then print the variable. Reference this variable name in the
# function header's "@return" declaration.
#
# Although discouraged, if you choose to create a global variable within the
# library function:
#
#   a) Use "declare -g" syntax.
#   b) Prepend `bfl_` to the variable name to avoid namespace collisions.
#   c) Include a @return declaration in the function header. For example:
#
#   @return global string $foo
#     The foo, which can either be "bar" or "baz".
#
#-----
#
# This silly example function has 171 lines (5599 bytes):
#
#   Shebang: 1 (not required)
#   Comments: 143
#   Blank: 11
#   Code: 16
#
#   The shebang is not required in a sourced file. It is included in this
#   file so that shellcheck will know which shell is targeted. If you are
#   not using shellcheck, you should be. See https://www.shellcheck.net.
#
# Now look at the 16 lines of code:
#
#   Function declaration: 2
#   Data validation: 5
#   Variable declaration: 6
#   Variable assignment: 1
#   Null: 1
#   Commands: 1
#
# You could produce the same output in one line (77 bytes):
#
#   bfl::introduce() { printf "My name is %s. I am %s years old.\\n" "$1" "$2"; }
#
# Or even less (52 bytes):
#
#   f() { echo -e "My name is $1. I am $2 years old." ;}
#
# Then why, oh why, is it so damn long?
#
#   1) To validate data.
#   2) To perform dependency checks.
#   3) To safely scope variables (defend against dynamic scoping, no globals).
#   4) To enable automated documentation (@tags).
#   5) To make it easy to read (formatting).
#   6) To make it easy to understand (comments, simplicity).
#   7) To ensure a consistent structure and style for every function in the
#      library, regardless of complexity.
#
# As of April 29, 2020 the average number of lines per library function is 51.
# If you throw out the high and the low, the average is 44 lines per function.
#
#-----
#
# @param String $name
#   The person's name.
#
# @param Integer $age
#   The person's age.
#
# @return String $introduction
#   The introduction.
#
# @example
#   bfl::introduce "John" "25"
#------------------------------------------------------------------------------
bfl::introduce() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 2 2 || exit 1

  # Verify dependencies.
  bfl::verify_dependencies "printf"

  # Declare positional arguments (readonly, sorted by position).
  declare -r name="$1"
  declare -r age="$2"

  # Declare return value.
  declare introduction

  # Declare readonly variables (sorted by name).
  declare -r const1="My name is"
  declare -r const2="I am"
  declare -r const3="years old"

  # Declare all other variables (sorted by name).
  :

  # Verify argument values.
  bfl::is_empty "${name}" &&
    bfl::die "Name is required."
  bfl::is_positive_integer "${age}" ||
    bfl::die "Expected positive integer, received ${age}."

  # Build the return value.
  introduction="${const1} ${name}. ${const2} ${age} ${const3}."

  # Print the return value.
  printf "%s\\n" "${introduction}"
}
