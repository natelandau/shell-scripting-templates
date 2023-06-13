#!/usr/bin/env bats

# Unittests for the functions in Http.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/Http.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# URL to a remote file for download related tests (the oldest file on the internet)
T_HTTP_URL="http://www.w3.org/History/1989/proposal.rtf"
T_HTTP_URL_PROTECTED="http://www.advancedhtml.co.uk/password/"
T_HTTP_URL_INVALID=""

T_HTTP_USR="demo"
T_HTTP_PWD="password"
T_HTTP_PWD_INVALID=


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# Http::Url::exists                                                            #
# ---------------------------------------------------------------------------- #

@test "Http::Url::exists -> If URL is pointing to an existing file, the function should return 0" {
  run Http::Url::exists "${T_HTTP_URL}"
  [ "${status}" -eq 0 ]
}

@test "Http::Url::exists -> If URL is not pointing to an existing file, the function should return 1" {
  run Http::Url::exists "${T_HTTP_URL_INVALID}"
  [ "${status}" -eq 1 ]
}

@test "Http::Url::exists -> If the credendials are valid, the function should return 0" {
  run Http::Url::exists "${T_HTTP_URL_PROTECTED}" "${T_HTTP_USR}" "${T_HTTP_PWD}"
  [ "${status}" -eq 0 ]
}

@test "Http::Url::exists -> If the credendials are invalid, the function should return 1" {
  run Http::Url::exists "${T_HTTP_URL_PROTECTED}" "${T_HTTP_USR}" "${T_HTTP_PWD_INVALID}"
  [ "${status}" -eq 1 ]
}

@test "Http::Url::exists -> If only username or password are specified, the function should ignore the credentials and, being unable to retrieve the file, return 1" {
  skip "Test case not implemented yet"
  run Http::Url::exists "${T_HTTP_URL}" "${T_HTTP_USR}"
  [ "${status}" -eq 1 ]
}
