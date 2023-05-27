#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 2 || exit 1

  # Verify dependencies.
  bfl::verify_dependencies "grep"

  # Declare positional arguments (readonly, sorted by position).
  declare -r path="$1"
  declare -r sites_enabled="${2:-"/etc/apache2/sites-enabled"}"

  # Declare all other variables (sorted by name).
  declare canonical_path
  declare canonical_sites_enabled

  # Verify argument values.
  bfl::is_empty "${path}" &&
    bfl::die "path is required."
  bfl::is_empty "${sites_enabled}" &&
    bfl::die "path_sites_enabled is required."

  # Get canonical paths.
  canonical_path=$(bfl::get_directory_path "${path}") ||
    bfl::die "Unable to determine canonical path to ${path}."
  canonical_sites_enabled=$(bfl::get_directory_path "${sites_enabled}") ||
    bfl::die "Unable to determine canonical path to ${sites_enabled}."

  grep -q -P -R -m1 \
    "DocumentRoot\\s+${canonical_path}$" \
    "${canonical_sites_enabled}"
}
