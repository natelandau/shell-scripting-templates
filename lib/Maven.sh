#!/usr/bin/env bash

# Library of functions related to the build tool Apache Maven
#
# @author  Michael Strache


# Returns the path the specified maven artefact would have in the local filesystem repository and if that artifact exists on localhost
#
# @param String   GROUP_ID        GroupId as specified in the pom.xml
# @param String   ARTIFACT_ID     ArtifactId as specified in the pom.xml
# @param String   VERSION         Version of the artefact
# @param String   EXTENSION       File extension of the artefact
# @param String   REPOSITORY      Path of the local repository, if not located at "${HOME}/.m2/repository"
function Maven::Artifact::get_path() {
  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift
  local -r VERSION="${1:-}"; shift
  local -r EXTENSION="${1:-}"; shift
  local -r REPOSITORY="${1:-$HOME/.m2/repository}"; shift

  local -r ARTIFACT="${REPOSITORY}/${GROUP_ID//./\/}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.${EXTENSION}"

  echo ${ARTIFACT}
  [[ -f "${ARTIFACT}" ]]
}


# Extracts and returns the version of the specified dependency from a pom.xml file
#
# @param String   POM             pom.xml file to search in
# @param String   GROUP_ID        group-id of the dependency
# @param String   ARTIFACT_ID     artifact-id of the dependency
function Maven::Project::Dependency::get_version() {
  local -r POM="${1:-}"; shift
  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift

  local -r VERSION=$(xmllint --shell "${POM}" <<< "setns x=http://maven.apache.org/POM/4.0.0"$'\n'"cat /x:project/x:dependencies/x:dependency[x:groupId='${GROUP_ID}' and x:artifactId='${ARTIFACT_ID}']/x:version/text()" | grep -v ">" | tail -1)

  echo ${VERSION}
  [[ "${VERSION}" ]]
}


# Update the version of a dependency in the a pom.xml
# See: http://stackoverflow.com/questions/34957616/is-it-possible-to-use-sed-to-replace-dependenciess-version-in-a-pom-file
#
# @param String   POM             pom.xml file to search in
# @param String   GROUP_ID        group-id of the dependency
# @param String   ARTIFACT_ID     artifact-id of the dependency
# @param String   NEW_VERSION     Version to be set
function Maven::Project::Dependency::update_version() {
  local -r POM="${1:-}"; shift
  local -r GROUP_ID="${1:-}"; shift
  local -r ARTIFACT_ID="${1:-}"; shift
  local -r NEW_VERSION="${1:-}"; shift

  # if the version is not found, we better should not try to replace it
  Maven::Project::Dependency::get_version "${POM}" "${GROUP_ID}" "${ARTIFACT_ID}" || return 1

  sed -i'' -e '/<dependency>/ {
      :start
      N
      /<\/dependency>$/!b start
      /<artifactId>'"${ARTIFACT_ID}"'<\/artifactId>/ {
          s/\(<version>\).*\(<\/version>\)/\1'"${NEW_VERSION}"'\2/
      }
  }' "${POM}" > ${LOG_FILE} 2>&1
}
