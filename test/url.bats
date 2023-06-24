#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/url
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
load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"

# **************************************************************************** #
# Setup tests                                                                  #
# **************************************************************************** #
setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  BASH_INTERACTIVE=true
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false

  set -o errtrace
  set -o nounset
  set -o pipefail
  shopt -u nocasematch
}

teardown() {
  set +o nounset
  set +o errtrace
  set +o pipefail

  popd &>/dev/null
  temp_del "${TESTDIR}"
}

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
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

# ---------------------------------------------------------------------------- #
# bfl::url_exists                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::url_exists -> If URL is pointing to an existing file, the function should return 0" {
  run bfl::url_exists "${T_HTTP_URL}"
  [ "${status}" -eq 0 ]
}

@test "bfl::url_exists -> If URL is not pointing to an existing file, the function should return 1" {
  run bfl::url_exists "${T_HTTP_URL_INVALID}"
  [ "${status}" -eq 1 ]
}

@test "bfl::url_exists -> If the credendials are valid, the function should return 0" {
  run bfl::url_exists "${T_HTTP_URL_PROTECTED}" "${T_HTTP_USR}" "${T_HTTP_PWD}"
  [ "${status}" -eq 0 ]
}

@test "bfl::url_exists -> If the credendials are invalid, the function should return 1" {
  run bfl::url_exists "${T_HTTP_URL_PROTECTED}" "${T_HTTP_USR}" "${T_HTTP_PWD_INVALID}"
  [ "${status}" -eq 1 ]
}

@test "bfl::url_exists -> If only username or password are specified, the function should ignore the credentials and, being unable to retrieve the file, return 1" {
  skip "Test case not implemented yet"
  run bfl::url_exists "${T_HTTP_URL}" "${T_HTTP_USR}"
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------- #
# bfl::encode_html                                                             #
# ---------------------------------------------------------------------------- #

@test "bfl::encode_html" {
  run bfl::encode_html "Here's some text& to > be h?t/M(l• en™codeç£§¶d"
  assert_success
  assert_output "Here's some text&amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
}

# ---------------------------------------------------------------------------- #
# bfl::decode_html                                                             #
# ---------------------------------------------------------------------------- #

@test "bfl::decode_html" {
  run bfl::decode_html "&clubs;Here's some text &amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
  assert_success
  assert_output "♣Here's some text & to > be h?t/M(l• en™codeç£§¶d"
}

# ---------------------------------------------------------------------------- #
# bfl::encode_url                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::encode_url" {
  run bfl::encode_url "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
  assert_success
  assert_output "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
}

# ---------------------------------------------------------------------------- #
# bfl::decode_url                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::decode_url" {
  run bfl::decode_url "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
  assert_success
  assert_output "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
}
