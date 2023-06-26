#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::parse_yaml().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Converts a YAML file into BASH variables for use in a shell script.
#   Prints variables and arrays derived from YAML File.
#
# @param String $file
#   Source YAML file.
#
# @param String $prefix
#   Prefix for the variables to avoid namespace collisions.
#
# @return String $JSON
#   YAML file from the JSON input.
#
# @example
#   To source into a script
#   bfl::parse_yaml "sample.yml" "CONF_" > tmp/variables.txt
#   source "tmp/variables.txt"
#   https://gist.github.com/DinoChiesa/3e3c3866b51290f31243
#   https://gist.github.com/epiloque/8cf512c6d64641bde388
#------------------------------------------------------------------------------
bfl::parse_yaml() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local _yamlFile="${1}"
  local _prefix="${2:-}"

  local _s='[[:space:]]*'
  local _w='[a-zA-Z0-9_]*'
  local _fs
  _fs="$(printf @ | tr @ '\034')"

  sed -ne "s|^\(${_s}\)\(${_w}\)${_s}:${_s}\"\(.*\)\"${_s}\$|\1${_fs}\2${_fs}\3|p" \
      -e "s|^\(${_s}\)\(${_w}\)${_s}[:-]${_s}\(.*\)${_s}\$|\1${_fs}\2${_fs}\3|p" "${_yamlFile}" \
      | awk -F"${_fs}" '{
  indent = length($1)/2;
  if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
  if (length($3) > 0) {
          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
          printf("%s%s%s%s=(\"%s\")\n", "'"${_prefix}"'",vn, $2, conj[indent-1],$3);
  }
}' | sed 's/_=/+=/g' | sed 's/[[:space:]]*#.*"/"/g'

  return 0
  }
