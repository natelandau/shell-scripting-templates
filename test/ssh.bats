#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/ssh
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

# TODO: Find public test subjects
T_SSH_FILE="/etc/hosts"
T_SSH_FILE_INVALID="/12345"
T_SSH_HOST="localhost"
T_SSH_HOST_INVALID="my-fake-host"


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# bfl::ssh_file_exists                                                         #
# ---------------------------------------------------------------------------- #

@test "bfl::ssh_file_exists -> If FILE exists on HOST, the function should return 0" {
  run bfl::ssh_file_exists "${T_SSH_FILE}" "${T_SSH_HOST}"
  [ "${status}" -eq 0 ]
}

@test "bfl::ssh_file_exists -> If FILE does not exist on HOST, the function should return 1" {
  run bfl::ssh_file_exists "${T_SSH_FILE_INVALID}" "${T_SSH_HOST}"
  [ "${status}" -eq 1 ]
}

@test "bfl::ssh_file_exists -> If HOST is inaccessible, the function should return an error code" {
  run bfl::ssh_file_exists "${T_SSH_FILE}" "${T_SSH_HOST_INVALID}"
  [ "${status}" -ne 0 ]
}
