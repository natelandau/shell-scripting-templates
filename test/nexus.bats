#!/usr/bin/env bats

# Unittests for the functions in Nexus.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/Nexus.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# TODO: Find public test subjects
T_NEXUS_USER=""
T_NEXUS_PASSWORD=""
T_NEXUS_SERVER="https://nexus.localhost"
T_NEXUS_REPOSITORY="myrepo"
T_NEXUS_GROUPID="biz.netcentric.michaelstrache"
T_NEXUS_ARTIFACTID="existing-package"
T_NEXUS_VERSION="1.0.0"
T_NEXUS_EXTESION="jar"


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# Nexus::Artifact::fetch                                                       #
# ---------------------------------------------------------------------------- #

@test "Nexus::Artifact::fetch -> If the input is correct, the artifact should be downloaded as T_TARGET and the function should return 0" {
  Http::Url::exists "${T_NEXUS_SERVER}" || skip "Nexus not reachable"

  local -r T_TARGET="$(mktemp -d 2>/dev/null || mktemp -d -t 'bats-nexus')/${T_NEXUS_ARTIFACTID}-${T_NEXUS_VERSION}.${T_NEXUS_EXTESION}"

  run Nexus::Artifact::fetch "${T_NEXUS_USER}" "${T_NEXUS_PASSWORD}" "${T_NEXUS_SERVER}" "${T_NEXUS_REPOSITORY}" "${T_NEXUS_GROUPID}" "${T_NEXUS_ARTIFACTID}" "${T_NEXUS_VERSION}" "${T_NEXUS_EXTESION}" "${T_TARGET}"
  [ "${status}" -eq 0 ]
  [ -f "${T_TARGET}" ]

  rm -rf "${T_TARGET}"
}

@test "Nexus::Artifact::fetch -> If T_TARGET is a directory, the file should be downloaded to that directory and the function should return 0" {
  Http::Url::exists "${T_NEXUS_SERVER}" || skip "Nexus not reachable"

  local -r T_TARGET="$(mktemp -d 2>/dev/null || mktemp -d -t 'bats-nexus')"

  run Nexus::Artifact::fetch "${T_NEXUS_USER}" "${T_NEXUS_PASSWORD}" "${T_NEXUS_SERVER}" "${T_NEXUS_REPOSITORY}" "${T_NEXUS_GROUPID}" "${T_NEXUS_ARTIFACTID}" "${T_NEXUS_VERSION}" "${T_NEXUS_EXTESION}" "${T_TARGET}"
  [ "${status}" -eq 0 ]
  [ -f "${T_TARGET}/${T_NEXUS_ARTIFACTID}-${T_NEXUS_VERSION}.${T_NEXUS_EXTESION}" ]

  rm -rf "${T_TARGET}"
}

@test "Nexus::Artifact::fetch -> If T_TARGET is not specified, the file should be downloaded to the current location and the function should return 0" {
  Http::Url::exists "${T_NEXUS_SERVER}" || skip "Nexus not reachable"

  run Nexus::Artifact::fetch "${T_NEXUS_USER}" "${T_NEXUS_PASSWORD}" "${T_NEXUS_SERVER}" "${T_NEXUS_REPOSITORY}" "${T_NEXUS_GROUPID}" "${T_NEXUS_ARTIFACTID}" "${T_NEXUS_VERSION}" "${T_NEXUS_EXTESION}"
  [ "${status}" -eq 0 ]
  [ -f "${T_NEXUS_ARTIFACTID}-${T_NEXUS_VERSION}.${T_NEXUS_EXTESION}" ]

  rm -rf "${T_NEXUS_ARTIFACTID}-${T_NEXUS_VERSION}.${T_NEXUS_EXTESION}"
}


# ---------------------------------------------------------------------------- #
# Nexus::Artifact::get_url                                                     #
# ---------------------------------------------------------------------------- #

@test "Nexus::Artifact::get_url -> The URL should be '${T_NEXUS_SERVER}/nexus/service/local/artifact/maven/redirect?r=${T_NEXUS_REPOSITORY}&g=${T_NEXUS_GROUPID}&a=${T_NEXUS_ARTIFACTID}&v=${T_NEXUS_VERSION}&e=${T_NEXUS_EXTESION}'" {
  run Nexus::Artifact::get_url "${T_NEXUS_SERVER}" "${T_NEXUS_REPOSITORY}" "${T_NEXUS_GROUPID}" "${T_NEXUS_ARTIFACTID}" "${T_NEXUS_VERSION}" "${T_NEXUS_EXTESION}"

  [ "${output}" = "${T_NEXUS_SERVER}/nexus/service/local/artifact/maven/redirect?r=${T_NEXUS_REPOSITORY}&g=${T_NEXUS_GROUPID}&a=${T_NEXUS_ARTIFACTID}&v=${T_NEXUS_VERSION}&e=${T_NEXUS_EXTESION}" ]
}
