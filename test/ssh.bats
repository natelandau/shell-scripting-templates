#!/usr/bin/env bats

# Unittests for the functions in Ssh.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/Ssh.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# TODO: Find public test subjects
T_SSH_FILE="/etc/hosts"
T_SSH_FILE_INVALID="/12345"
T_SSH_HOST="localhost"
T_SSH_HOST_INVALID="my-fake-host"


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# Ssh::file_exists                                                             #
# ---------------------------------------------------------------------------- #

@test "Ssh::file_exists -> If FILE exists on HOST, the function should return 0" {
  run Ssh::file_exists "${T_SSH_FILE}" "${T_SSH_HOST}"
  [ "${status}" -eq 0 ]
}

@test "Ssh::file_exists -> If FILE does not exist on HOST, the function should return 1" {
  run Ssh::file_exists "${T_SSH_FILE_INVALID}" "${T_SSH_HOST}"
  [ "${status}" -eq 1 ]
}

@test "Ssh::file_exists -> If HOST is inaccessible, the function should return an error code" {
  run Ssh::file_exists "${T_SSH_FILE}" "${T_SSH_HOST_INVALID}"
  [ "${status}" -ne 0 ]
}
