#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the build tool Apache Maven
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::update_maven_project_dependency_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Update the version of a dependency in the a pom.xml.
# See: http://stackoverflow.com/questions/34957616/is-it-possible-to-use-sed-to-replace-dependenciess-version-in-a-pom-file
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
# @param string $NEW_VERSION
#   Version to be set.
#
# @example
#   bfl::update_maven_project_dependency_version ....
#------------------------------------------------------------------------------
#
bfl::update_maven_project_dependency_version() {
  local -r POM="${1:-}"; shift
  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift
  local -r NEW_VERSION="${1:-}"; shift

  # if the version is not found, we better should not try to replace it
  bfl::get_maven_project_dependency_version "${POM}" "${GROUP_ID}" "${ARTIFACT_ID}" || return 1

  sed -i'' -e '/<dependency>/ {
      :start
      N
      /<\/dependency>$/!b start
      /<artifactId>'"${ARTIFACT_ID}"'<\/artifactId>/ {
          s/\(<version>\).*\(<\/version>\)/\1'"${NEW_VERSION}"'\2/
      }
  }' "${POM}" > ${LOG_FILE} 2>&1
}
