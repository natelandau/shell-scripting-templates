#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::is_apache_vhost().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if the given path is the root of an Apache virtual host.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
# @param string $sites_enabled [optional]
#   Absolute path to Apache's "sites-enabled" directory.
#   Defaults value is /etc/apache2/sites-enabled.
#
# @example
#   bfl::is_apache_vhost "./foo"
# @example
#   bfl::is_apache_vhost "./foo" "/etc/apache2/sites-enabled"
#------------------------------------------------------------------------------
bfl::is_apache_vhost() {
  bfl::verify_arg_count "$#" 1 2 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1, 2]"  # Verify argument count.
  bfl::verify_dependencies "grep"           # Verify dependencies.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "path is required."

  # Declare positional arguments (readonly, sorted by position).
  declare -r sites_enabled="${2:-"/etc/apache2/sites-enabled"}"
  [[ -z "$sites_enabled" ]] && bfl::die "path_sites_enabled is required."

  # Declare all other variables (sorted by name).
  declare canonical_sites_enabled

  # Get canonical paths.
  canonical_path=$(bfl::get_directory_path "$1") ||
    bfl::die "Unable to determine canonical path to $1."
  canonical_sites_enabled=$(bfl::get_directory_path "$sites_enabled") ||
    bfl::die "Unable to determine canonical path to $sites_enabled."

  grep -q -P -R -m1 "DocumentRoot\\s+${canonical_path}$" "$canonical_sites_enabled"
  }
