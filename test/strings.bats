#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/strings
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
}

teardown() {
  set +o nounset
  set +o errtrace
  set +o pipefail

  popd &>/dev/null
  temp_del "${TESTDIR}"
}

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

# ---------------------------------------------------------------------------- #
# bfl::escape_special_symbols                                                  #
# ---------------------------------------------------------------------------- #

@test "bfl::escape_special_symbols -> Should return STRING with all special characters escaped" {
  run bfl::escape_special_symbols 'foo'
  [ "${output}" == 'foo' ]

  run bfl::escape_special_symbols 'foo\'
  [ "${output}" == 'foo\\' ]

  run bfl::escape_special_symbols 'f\$oo'
  [ "${output}" == 'f\\\$oo' ]

  run bfl::escape_special_symbols ''
  [ "${output}" == '' ]
}

# ---------------------------------------------------------------------------- #
# bfl::string_replace                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::string_replace -> Should return STRING with each occurence of TARGET replaced with REPLACEMENT" {
  # String with a single occurence
  run bfl::string_replace "foo-bar" "-" "#"
  [ "${output}" == "foo#bar" ]

  # String with multiple occurences
  run bfl::string_replace "foo-bar" "o" "#"
  [ "${output}" == "f##-bar" ]

  # String with no occurences
  run bfl::string_replace "foo-bar" "#" "#"
  [ "${output}" == "foo-bar" ]

  # Match multiple chars
  run bfl::string_replace "foo-bar" "oo" "#"
  [ "${output}" == "f#-bar" ]

  # Match one char, replace with multiple chars
  run bfl::string_replace "foo-bar" "-" "##"
  [ "${output}" == "foo##bar" ]
}

@test "bfl::string_replace -> Should return the STRING if REPLACEMENT or TARGET were not specified" {
  # String with a single occurence
  run bfl::string_replace "foo-bar" "-"
  [ "${output}" == "foo-bar" ]

  # String with a single occurence
  run bfl::string_replace "foo-bar"
  [ "${output}" == "foo-bar" ]
}

@test "bfl::string_replace -> Should return an empty string if STRING was not specified" {
  # String with a single occurence
  run bfl::string_replace
  [ "${output}" == "" ]
}

# ---------------------------------------------------------------------------- #
# bfl::string_split                                                            #
# ---------------------------------------------------------------------------- #

@test "bfl::string_split -> Should return the string representation of an array, containing STRING splittet into its elements using REGEX" {
  # String separated by a single char
  run bfl::string_split "foo,bar" ","
  [ "${output}" == "( foo bar )" ]

  # String separated by a multiple chars
  run bfl::string_split "foo, bar" ", "
  [ "${output}" == "( foo bar )" ]

  # String separated by a a regex
  run bfl::string_split "foo--bar" "-+"
  [ "${output}" == "( foo bar )" ]

  # No separator
  run bfl::string_split "foo,bar"
  [ "${output}" == "( foo,bar )" ]

  # No argument
  run bfl::string_split
  [ "${output}" == "(  )" ]
}

@test "bfl::string_split" {
  run bfl::string_split "a,b,cd" ","
  assert_success
  assert_line --index 0 "a"
  assert_line --index 1 "b"
  assert_line --index 2 "cd"
}


# ---------------------------------------------------------------------------- #
# bfl::trimL                                                                   #
# ---------------------------------------------------------------------------- #

@test "bfl::trimL" {
  local text=$(bfl::trimL <<<"    some text")

  run echo "$text"
  assert_output "some text"
}


# ---------------------------------------------------------------------------- #
# bfl::trimR                                                                   #
# ---------------------------------------------------------------------------- #

@test "bfl::trimR" {
  local text=$(bfl::trimR <<<"some text    ")

  run echo "$text"
  assert_output "some text"
}

# ---------------------------------------------------------------------------- #
# bfl::path_prepend                                                            #
# ---------------------------------------------------------------------------- #

@test "bfl::path_prepend: succeed on dir not found" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  run bfl::path_prepend "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/again" "${TESTDIR}/testing/from/bats_again"
  assert_success
}

@test "bfl::path_prepend: fail on dir not found" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  run bfl::path_prepend -x "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/again" "${TESTDIR}/testing/from/bats_again"
  assert_failure
}

@test "bfl::path_prepend: success" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  bfl::path_prepend "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/from/bats_again"

  run echo "${PATH}"
  assert_output --regexp "/testing/from/bats"
  refute_output --regexp "/testing/again"
  assert_output --regexp "/testing/from/bats_again"
}

@test "bfl::is_email: true" {
  run bfl::is_email "some.email+name@gmail.com"
  assert_success
}

@test "bfl::is_email: false" {
  run bfl::is_email "testemail"
  assert_failure
}

@test "bfl::is_FQDN: true" {
  run bfl::is_FQDN "some.domain.com"
  assert_success
}

@test "bfl::is_FQDN: false" {
  run bfl::is_FQDN "testing"
  assert_failure
}

@test "bfl::is_FQDN: false2" {
  run bfl::is_FQDN "192.168.1.1"
  assert_failure
}

@test "bfl::is_IPv4: true" {
  run bfl::is_IPv4 "192.168.1.1"
  assert_success
  run bfl::is_IPv4 "4.2.2.2"
  assert_success
  run bfl::is_IPv4 "0.192.168.1"
  assert_success
  run bfl::is_IPv4 "255.255.255.255"
  assert_success
}

@test "bfl::is_IPv4: false" {
  run bfl::is_IPv4 "1.b.c.d"
  assert_failure
  run bfl::is_IPv4 "1234.123.123.123"
  assert_failure
  run bfl::is_IPv4 "192.168.0"
  assert_failure
  run bfl::is_IPv4 "255.255.255.256"
  assert_failure
}

@test "bfl::is_IPv6: true" {
  run bfl::is_IPv6 "2001:db8:85a3:8d3:1319:8a2e:370:7348"
  assert_success
  run bfl::is_IPv6 "fe80::1ff:fe23:4567:890a"
  assert_success
  run bfl::is_IPv6 "fe80::1ff:fe23:4567:890a%eth2"
  assert_success
  run bfl::is_IPv6 "::"
  assert_success
  run bfl::is_IPv6 "2001:db8::"
  assert_success
}

@test "bfl::is_IPv6: false" {
  run bfl::is_IPv6 "2001:0db8:85a3:0000:0000:8a2e:0370:7334:foo:bar"
  assert_failure
  run bfl::is_IPv6 "fezy::1ff:fe23:4567:890a"
  assert_failure
  run bfl::is_IPv6 "192.168.0"
}

@test "bfl::_is_alphabet: true " {
  testVar="abc"
  run bfl::_is_alphabet "${testVar}"
  assert_success
}

@test "bfl::_is_alphabet: false " {
  testVar="ab c"
  run bfl::_is_alphabet "${testVar}"
  assert_failure
}

@test "bfl::var_is_false: true" {
  testvar=false
  run bfl::var_is_false "${testvar}"
  assert_success
}

@test "bfl::var_is_false: false" {
  testvar=true
  run _variableIsFalse_ "${testvar}"
  assert_failure
}

@test "bfl::var_is_true: true" {
  testvar=true
  run bfl::var_is_true "${testvar}"
  assert_success
}

@test "bfl::var_is_true: false" {
  testvar=false
  run bfl::var_is_true "${testvar}"
  assert_failure
}

@test "bfl::var_is_empty: true" {
  testvar=""
  run bfl::var_is_empty "${testvar}"
  assert_success
}

@test "bfl::var_is_empty: false" {
  testvar=test
  run bfl::var_is_empty "${testvar}"
  assert_failure
}

_testCleanString_() {

  @test "bfl::clean_string: fail" {
    run bfl::clean_string
    assert_failure
  }

  @test "bfl::clean_string: lowercase" {
    run bfl::clean_string -l "I AM IN CAPS"
    assert_success
    assert_output "i am in caps"
  }

  @test "bfl::clean_string: uppercase" {
    run bfl::clean_string -u "i am in caps"
    assert_success
    assert_output "I AM IN CAPS"
  }

  @test "bfl::clean_string: remove white space" {
    run bfl::clean_string -u "   i am     in caps   "
    assert_success
    assert_output "I AM IN CAPS"
  }

  @test "bfl::clean_string: remove spaces before/after dashes" {
    run bfl::clean_string "word - another- word -another-word"
    assert_success
    assert_output "word-another-word-another-word"
  }

   @test "bfl::clean_string: remove spaces before/after underscores" {
    run bfl::clean_string "word _ another_ word _another_word"
    assert_success
    assert_output "word_another_word_another_word"
  }

  @test "bfl::clean_string: alnum" {
    run bfl::clean_string -a "  !@#$%^%& i am     in caps 12345 == "
    assert_success
    assert_output "i am in caps 12345"
  }

  @test "bfl::clean_string: alnum w/ spaces" {
    run bfl::clean_string -as "this(is)a[string]"
    assert_success
    assert_output "this is a string"
  }

  @test "bfl::clean_string: alnum w/ spaces and dashes" {
    run bfl::clean_string -as "this(is)a-string"
    assert_success
    assert_output "this is a-string"
  }

    @test "bfl::clean_string: alnum w/ spaces and dashes and regex replace" {
    run bfl::clean_string -asp "-|_|st, " "th_is(is)a-string"
    assert_success
    assert_output "th is is a ring"
  }

  @test "bfl::clean_string: user replacement" {
    run bfl::clean_string -p "e,g" "there should be a lot of e's in this sentence"
    assert_success
    assert_output "thgrg should bg a lot of g's in this sgntgncg"
  }

  @test "bfl::clean_string: remove specified characters" {
    run bfl::clean_string "there should be a lot of e's in this sentence" "e"
    assert_success
    assert_output "thr should b a lot of 's in this sntnc"
  }

  @test "bfl::clean_string: compound test 1" {
    run bfl::clean_string -p "2,4" -au "  @#$%[]{} clean   a compound command ==23---- " "e"
    assert_success
    assert_output "CLAN A COMPOUND COMMAND 43-"
  }

}

_testStopWords_() {

  @test "bfl::clean_stopwords: success" {
    run bfl::clean_stopwords "A string to be parsed"
    assert_success
    assert_output "string parsed"
  }

  @test "bfl::clean_stopwords: success w/ user terms" {
    run bfl::clean_stopwords "A string to be parsed to help pass this test being performed by bats" "bats,string"
    assert_success
    assert_output "parsed pass performed"
  }

  @test "bfl::clean_stopwords: No changes" {
    run bfl::clean_stopwords "string parsed pass performed"
    assert_success
    assert_output "string parsed pass performed"
  }

  @test "bfl::clean_stopwords: fail" {
    run bfl::clean_stopwords
    assert_failure
  }

}

@test "bfl::strip_escape_symbols" {
  run bfl::strip_escape_symbols "Here is some / text to & be - escaped"
  assert_success
  assert_output "Here\ is\ some\ /\ text\ to\ &\ be\ -\ escaped"
}

_testCleanString_
_testStopWords_
