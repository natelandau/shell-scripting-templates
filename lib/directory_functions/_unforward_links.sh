#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::unforward_links().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the files in a directory (recursively or not).
#
# @param string $path1
#   A directory with files.
#
# @param string $path2
#   A directory with file links.
#
# @example
#   bfl::unforward_links  /tools/binutils-2.40 /usr/local
#------------------------------------------------------------------------------
bfl::unforward_links() {
  bfl::verify_arg_count "$#" 2 2 || exit 1  # Verify argument count.

  }
