#!/usr/bin/env bash

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
# Extracts and returns the version of the specified dependency from a pom.xml file.
#
# @param string $POM
#   pom.xml file to search in.
#
# @param string $GROUP_ID
#   Group-id of the dependency.
#
# @param string $ARTIFACT_ID
#   Artifact-id of the dependency.
#
# @return String $VERSION
#   Prject depedency version.
#
# @example
#   bfl::get_maven_project_dependency_version ....
#------------------------------------------------------------------------------
#
bfl::get_maven_project_dependency_version() {
  local -r POM="${1:-}"; shift
  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift

  local -r VERSION=$(xmllint --shell "${POM}" <<< "setns x=http://maven.apache.org/POM/4.0.0"$'\n'"cat /x:project/x:dependencies/x:dependency[x:groupId='${GROUP_ID}' and x:artifactId='${ARTIFACT_ID}']/x:version/text()" | grep -v ">" | tail -1)

  echo ${VERSION}
  [[ "${VERSION}" ]]
}
