#!/usr/bin/env bash

# Library of functions related to the software repository manager Sonatype Nexus
#
# @author  Michael Strache


# Prevent this library from being sourced more than once
[[ ${_GUARD_BFL_NEXUS:-} -eq 1 ]] && return 0 || declare -r _GUARD_BFL_NEXUS=1


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# Downloads an artifact from Nexus
#
# @param String   USER
# @param String   PASSWORD
# @param String   SERVER
# @param String   REPOSITORY
# @param String   GROUP
# @param String   ARTIFACT
# @param String   VERSION
# @param String   EXTENSION
# @param String   TARGET
function Nexus::Artifact::fetch() {
  local -r USER="${1:-}"; shift
  local -r PASSWORD="${1:-}"; shift
  local -r SERVER="${1:-}"; shift
  local -r REPOSITORY="${1:-}"; shift
  local -r GROUP="${1:-}"; shift
  local -r ARTIFACT="${1:-}"; shift
  local -r VERSION="${1:-}"; shift
  local -r EXTENSION="${1:-}"; shift
  local target="${1:-$ARTIFACT-$VERSION.$EXTENSION}"; shift

  [[ -d "${target}" ]] && target="${target}/${ARTIFACT}-${VERSION}.${EXTENSION}"

  local -r URL="$(Nexus::Artifact::get_url ${SERVER} ${REPOSITORY} ${GROUP} ${ARTIFACT} ${VERSION} ${EXTENSION})"
  wget --quiet --no-check-certificate --user="${USER}" --password="${PASSWORD}" "${URL}" --output-document="${target}"
}


# Downloads an artifact from Nexus
#
# @param String   SERVER
# @param String   REPOSITORY
# @param String   GROUP
# @param String   ARTIFACT
# @param String   VERSION
# @param String   EXTENSION
function Nexus::Artifact::get_url() {
  local -r SERVER="${1:-}"; shift
  local -r REPOSITORY="${1:-}"; shift
  local -r GROUP="${1:-}"; shift
  local -r ARTIFACT="${1:-}"; shift
  local -r VERSION="${1:-}"; shift
  local -r EXTENSION="${1:-}"; shift

  echo "${SERVER}/nexus/service/local/artifact/maven/redirect?r=${REPOSITORY}&g=${GROUP}&a=${ARTIFACT}&v=${VERSION}&e=${EXTENSION}"
}
