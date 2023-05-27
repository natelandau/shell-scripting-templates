#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the build tool Apache Maven
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_maven_artifact_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns the path the specified maven artefact would have in the local filesystem repository and if that artifact exists on localhost.
#
# @param string $GROUP_ID
#   GroupId as specified in the pom.xml.
#
# @param string $ARTIFACT_ID
#   ArtifactId as specified in the pom.xml.
#
# @param string $VERSION
#   Version of the artefact.
#
# @param string $EXTENSION
#   File extension of the artefact.
#
# @param string $REPOSITORY
#   Path of the local repository, if not located at "${HOME}/.m2/repository".
#
# @return String $result
#   Artifact path.
#
# @example
#   bfl::get_maven_artifact_path ....
#------------------------------------------------------------------------------
#
bfl::get_maven_artifact_path() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift
  local -r VERSION="${1:-}"; shift
  local -r EXTENSION="${1:-}"; shift
  local -r REPOSITORY="${1:-$HOME/.m2/repository}"; shift

  local -r ARTIFACT="${REPOSITORY}/${GROUP_ID//./\/}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.${EXTENSION}"

  echo ${ARTIFACT}
  [[ -f "${ARTIFACT}" ]]
}
