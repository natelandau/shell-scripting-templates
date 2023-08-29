#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/checks.bash"
BASEHELPERS="${ROOTDIR}/utilities/misc.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"

if test -f "${SOURCEFILE}" >&2; then
  source "${SOURCEFILE}"
else
  echo "Sourcefile not found: ${SOURCEFILE}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

if test -f "${ALERTS}" >&2; then
  source "${ALERTS}"
  _setColors_ #Set color constants
else
  echo "Sourcefile not found: ${ALERTS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

if test -f "${BASEHELPERS}" >&2; then
  source "${BASEHELPERS}"
else
  echo "Sourcefile not found: ${BASEHELPERS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false

  set -o errtrace
  set -o nounset
  set -o pipefail
}

teardown() {
  set +o nounset
  set +o errtrace
  set +o pipefail

  popd &>/dev/null
  temp_del "${TESTDIR}"
}

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "_functionExists_: Success" {
  run _functionExists_ "_varIsEmpty_"
  assert_success
}

@test "_functionExists_: Failure" {
  run _functionExists_ "_someUndefinedFunction_"
  assert_failure
}

@test "_commandExists_: true" {
  run _commandExists_ "vi"
  assert_success
}

@test "_commandExists_: false" {
  run _commandExists_ "someNonexistentBinary"
  assert_failure
}

@test "_isEmail_: true" {
  run _isEmail_ "some.email+name@gmail.com"
  assert_success
}

@test "_isEmail_: false" {
  run _isEmail_ "testemail"
  assert_failure
}

@test "_isFQDN_: true" {
  run _isFQDN_ "some.domain.com"
  assert_success
}

@test "_isFQDN_: false" {
  run _isFQDN_ "testing"
  assert_failure
}

@test "_isFQDN_: false2" {
  run _isFQDN_ "192.168.1.1"
  assert_failure
}

@test "_isIPv4_: true" {
  run _isIPv4_ "192.168.1.1"
  assert_success
  run _isIPv4_ "4.2.2.2"
  assert_success
  run _isIPv4_ "0.192.168.1"
  assert_success
  run _isIPv4_ "255.255.255.255"
  assert_success
}

@test "_isIPv4_: false" {
  run _isIPv4_ "1.b.c.d"
  assert_failure
  run _isIPv4_ "1234.123.123.123"
  assert_failure
  run _isIPv4_ "192.168.0"
  assert_failure
  run _isIPv4_ "255.255.255.256"
  assert_failure
}

@test "_isIPv6_: true" {
  run _isIPv6_ "2001:db8:85a3:8d3:1319:8a2e:370:7348"
  assert_success
  run _isIPv6_ "fe80::1ff:fe23:4567:890a"
  assert_success
  run _isIPv6_ "fe80::1ff:fe23:4567:890a%eth2"
  assert_success
  run _isIPv6_ "::"
  assert_success
  run _isIPv6_ "2001:db8::"
  assert_success
}

@test "_isIPv6_: false" {
  run _isIPv6_ "2001:0db8:85a3:0000:0000:8a2e:0370:7334:foo:bar"
  assert_failure
  run _isIPv6_ "fezy::1ff:fe23:4567:890a"
  assert_failure
  run _isIPv6_ "192.168.0"
}

@test "_isFile_: true" {
  touch testfile.txt
  run _isFile_ "testfile.txt"
  assert_success
}

@test "_isFile_: false" {
  run _isFile_ "testfile.txt"
  assert_failure
}

@test "_isDir_: true" {
  mkdir -p "some/path"
  run _isDir_ "some/path"
  assert_success
}

@test "_isDir_: false" {
  run _isDir_ "some/path"
  assert_failure
}

@test "_isAlpha_: true " {
  testVar="abc"
  run _isAlpha_ "${testVar}"
  assert_success
}

@test "_isAlpha_: false " {
  testVar="ab c"
  run _isAlpha_ "${testVar}"
  assert_failure
}

@test "_isNum_: true " {
  testVar="123"
  run _isNum_ "${testVar}"
  assert_success
}

@test "_isNum_: false " {
  testVar="12 3"
  run _isNum_ "${testVar}"
  assert_failure
}

@test "_isAlphaDash_: true " {
  testVar="abc_123-xyz"
  run _isAlphaDash_ "${testVar}"
  assert_success
}

@test "_isAlphaDash_: false " {
  testVar="abc_123 xyz"
  run _isAlphaDash_ "${testVar}"
  assert_failure
}

@test "_isAlphaNum_: true " {
  testVar="abc123"
  run _isAlphaNum_ "${testVar}"
  assert_success
}

@test "_isAlphaNum_: false " {
  testVar="ab c123"
  run _isAlphaNum_ "${testVar}"
  assert_failure
}

@test "_varIsFalse_: true" {
  testvar=false
  run _varIsFalse_ "${testvar}"
  assert_success
}

@test "_varIsFalse_: false" {
  testvar=true
  run _varIsFalse_ "${testvar}"
  assert_failure
}

@test "_varIsTrue_: true" {
  testvar=true
  run _varIsTrue_ "${testvar}"
  assert_success
}

@test "_varIsTrue_: false" {
  testvar=false
  run _varIsTrue_ "${testvar}"
  assert_failure
}

@test "_varIsEmpty_: true" {
  testvar=""
  run _varIsEmpty_ "${testvar}"
  assert_success
}

@test "_varIsEmpty_: false" {
  testvar=test
  run _varIsEmpty_ "${testvar}"
  assert_failure
}
