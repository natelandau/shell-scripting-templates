#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/maven
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# May later be part of a demo repository that is checked out to the BATS_TMPDIR
T_MAVEN_POM=${BATS_TMPDIR}/pom.xml

T_MAVEN_GROUPID="biz.netcentric.michaelstrache"
T_MAVEN_ARTIFACTID="existing-package"
T_MAVEN_ARTIFACTID_NONEXISTING="non-existing-package"
T_MAVEN_VERSION="1.0.0"
T_MAVEN_EXTENSION="jar"

# **************************************************************************** #
# Setup tests                                                                  #
# **************************************************************************** #
setup() {
  cp "${BATS_TEST_DIRNAME}/testdata/maven/pom.xml" "${T_MAVEN_POM}"
}

teardown() {
  rm "${T_MAVEN_POM}"
}


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# bfl::get_maven_artifact_path                                                 #
# ---------------------------------------------------------------------------- #

@test "bfl::get_maven_artifact_path ->  If the artifact exists in the default repository, the function should exit with 0 and return the path of the artifact" {
  which mvn || skip "Maven required but not found"

  local -r GROUP_ID="org.apache.maven"
  local -r ARTIFACT_ID="maven-artifact"
  local -r VERSION="3.1.1"
  local -r EXTENSION="jar"

  run bfl::get_maven_artifact_path "${GROUP_ID}" "${ARTIFACT_ID}" "${VERSION}" "${EXTENSION}"
  [ "${status}" -eq 0 ]
  [ "${output}" == "${HOME}/.m2/repository/$(String::replace ${GROUP_ID} '\.' '\/')/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.${EXTENSION}" ]
}

@test "bfl::get_maven_artifact_path -> If the artifact does not exist in the default repository, the function should exit with 1 but still return the path the artifact would have" {
  run bfl::get_maven_artifact_path "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID_NONEXISTING}" "${T_MAVEN_VERSION}" "${T_MAVEN_EXTENSION}"
  [ "${status}" -eq 1 ]
  [ "${output}" == "${HOME}/.m2/repository/$(String::replace ${T_MAVEN_GROUPID} '.' '/')/${T_MAVEN_ARTIFACTID_NONEXISTING}/${T_MAVEN_VERSION}/${T_MAVEN_ARTIFACTID_NONEXISTING}-${T_MAVEN_VERSION}.${T_MAVEN_EXTENSION}" ]
}

@test "bfl::get_maven_artifact_path -> If the artifact exists in a userspecific repository, the function should exit with 0 and return the path of the artifact" {
  local -r REPOSITORY="${BATS_TEST_DIRNAME}/testdata/maven"

  run bfl::get_maven_artifact_path "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID}" "${T_MAVEN_VERSION}" "${T_MAVEN_EXTENSION}" "${REPOSITORY}"
  [ "${status}" -eq 0 ]
  [ "${output}" == "${REPOSITORY}/$(String::replace ${T_MAVEN_GROUPID} '.' '/')/${T_MAVEN_ARTIFACTID}/${T_MAVEN_VERSION}/${T_MAVEN_ARTIFACTID}-${T_MAVEN_VERSION}.${T_MAVEN_EXTENSION}" ]
}


# ---------------------------------------------------------------------------- #
# bfl::get_maven_project_dependency_version                                    #
# ---------------------------------------------------------------------------- #

@test "bfl::get_maven_project_dependency_version -> If the dependency exists in the POM, the function should exit with 0 and return the version" {
  run bfl::get_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID}"
  [ "${status}" -eq 0 ]
  [ "${output}" == "${T_MAVEN_VERSION}" ]
}

@test "bfl::get_maven_project_dependency_version -> If the dependency does not exist in the POM, the function should exit with 1 and return an empty string" {
  run bfl::get_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID_NONEXISTING}"
  [ "${status}" -eq 1 ]
  [ -z "${output}" ]
}


# ---------------------------------------------------------------------------- #
# bfl::update_maven_project_dependency_version                                 #
# ---------------------------------------------------------------------------- #

@test "bfl::update_maven_project_dependency_version -> If the dependency exists in the POM, the function should change it and exit with 0" {
  local VERSION_NEW="2.0.0"

  local ARTIFACT_VERSION=$(bfl::get_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID}")
  [ "${ARTIFACT_VERSION}" == "${T_MAVEN_VERSION}" ]

  run bfl::update_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID}" "${VERSION_NEW}"
  [ "${status}" -eq 0 ]

  local ARTIFACT_VERSION=$(bfl::get_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID}")
  [ "${ARTIFACT_VERSION}" == "${VERSION_NEW}" ]
}

@test "bfl::update_maven_project_dependency_version -> If the dependency does not exist in the POM, the function should exit with 1" {
  local VERSION_NEW="2.0.0"

  run bfl::get_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID_NONEXISTING}"
  [ "${status}" -eq 1 ]

  run bfl::update_maven_project_dependency_version "${T_MAVEN_POM}" "${T_MAVEN_GROUPID}" "${T_MAVEN_ARTIFACTID_NONEXISTING}" "${VERSION_NEW}"
  [ "${status}" -eq 1 ]
}
