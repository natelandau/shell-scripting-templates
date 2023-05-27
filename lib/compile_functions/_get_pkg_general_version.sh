#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::_get_pkg_general_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Upper version: 2.35.1-dfg => 2.35
#
# @param string $path
#   Package version.
#
# @return string $version
#   Upper version.
#
# @example
#   bfl::_get_pkg_general_version "2.35.1-dfg"
#------------------------------------------------------------------------------
bfl::_get_pkg_general_version() {
  local n=`echo "$1" | tr -cd '.' | wc -m` # сколько точек в версии файла
  ((n<2)) && echo "$1" && return 0

  local str=`echo "$1" | sed 's/\(.*\..*\)\..*/\1/'`
  echo "$str"
  return 0
  }
