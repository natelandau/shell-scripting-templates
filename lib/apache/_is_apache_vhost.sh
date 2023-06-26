#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to Apache
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::is_apache_vhost().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if the given path is the root of an Apache virtual host.
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @param String $sites_enabled [optional]
#   Absolute path to Apache's "sites-enabled" directory.
#   Defaults value is /etc/apache2/sites-enabled.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_apache_vhost "./foo"
#   bfl::is_apache_vhost "./foo" "/etc/apache2/sites-enabled"
#------------------------------------------------------------------------------
bfl::is_apache_vhost() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GREP} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'grep' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  # Declare positional arguments (readonly, sorted by position).
  [[ -n "$2" ]] && bfl::is_blank "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: path_sites_enabled is blank!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  local -r sites_enabled="${2:-"/etc/apache2/sites-enabled"}"

  # Declare all other variables (sorted by name).
  local canonical_sites_enabled

  # Get canonical paths.
  canonical_path=$(bfl::get_directory_path "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to determine canonical path to $1."; return 1; }
  canonical_sites_enabled=$(bfl::get_directory_path "${sites_enabled}") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to determine canonical path to ${sites_enabled}."; return 1; }

  grep -q -P -R -m1 "DocumentRoot\\s+${canonical_path}$" "${canonical_sites_enabled}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed grep -q -P -R -m1 'DocumentRoot\\s+${canonical_path}$' '${canonical_sites_enabled}'"; return 1; }
  return 0
  }
