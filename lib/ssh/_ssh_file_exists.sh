#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the Secure Shell
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::ssh_file_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if file exists on host and is readable.
#
# @param String $file
#   URL of the file that should be checked.
#
# @param String $host
#   Username to be used for authentication.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::_ssh_file_exists "url" "host"
#------------------------------------------------------------------------------
bfl::ssh_file_exists() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r FILE="${1:-}"
  local -r HOST="${2:-}"

  ssh -q -T "$HOST" 'bash' <<-EOF
      [[ -r "$FILE" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: [[ -r '$FILE' ]] error"; return 1; }
	EOF

  }
