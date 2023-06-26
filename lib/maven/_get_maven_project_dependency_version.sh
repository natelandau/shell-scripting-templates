#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the build tool Apache Maven
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_maven_project_dependency_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Extracts and returns the version of the specified dependency from a pom.xml file.
#
# @param String $POM
#   pom.xml file to search in.
#
# @param String $GROUP_ID
#   Group-id of the dependency.
#
# @param String $ARTIFACT_ID
#   Artifact-id of the dependency.
#
# @return String $VERSION
#   Prject depedency version.
#
# @example
#   bfl::get_maven_project_dependency_version ....
#------------------------------------------------------------------------------
bfl::get_maven_project_dependency_version() {
  bfl::verify_arg_count "$#" 3 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 3"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r POM="${1:-}"
  local -r GROUP_ID="${2:-}"
  local -r ARTIFACT_ID="${3:-}"

  local VERSION
  VERSION=$(xmllint --shell "$POM" <<< "setns x=http://maven.apache.org/POM/4.0.0"$'\n'"cat /x:project/x:dependencies/x:dependency[x:groupId='$GROUP_ID' and x:artifactId='$ARTIFACT_ID']/x:version/text()" | grep -v ">" | tail -1)

  echo "$VERSION"
  [[ "$VERSION" ]]
  }
