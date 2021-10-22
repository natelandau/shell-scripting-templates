#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/strings.bash"
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
  shopt -u nocasematch
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

@test "_splitString_" {
  run _splitString_ "a,b,cd" ","
  assert_success
  assert_line --index 0 "a"
  assert_line --index 1 "b"
  assert_line --index 2 "cd"
}

@test "_stringContains_: success" {
  run _stringContains_ "hello world!" "lo"
  assert_success
}

@test "_stringContains_: failure" {
  run _stringContains_ "hello world!" "LO"
  assert_failure
}

@test "_stringContains_: success, case insensitive" {
  run _stringContains_ -i "hello world!" "LO"
  assert_success
}

@test "_stringRegex_: success" {
  run _stringRegex_ "hello world!" "^h[a-z ]+!$"
  assert_success
}

@test "_stringRegex_: failure" {
  run _stringRegex_ "Hello World!" "^h[a-z ]+!$"
  assert_failure
}

@test "_stringRegex_: success, case insensitive" {
  run _stringRegex_ -i "Hello World!" "^h[a-z ]+!$"
  assert_success
}


_testCleanString_() {

  @test "_cleanString_: fail" {
    run _cleanString_
    assert_failure
  }

  @test "_cleanString_: lowercase" {
    run _cleanString_ -l "I AM IN CAPS"
    assert_success
    assert_output "i am in caps"
  }

  @test "_cleanString_: uppercase" {
    run _cleanString_ -u "i am in caps"
    assert_success
    assert_output "I AM IN CAPS"
  }

  @test "_cleanString_: remove white space" {
    run _cleanString_ -u "   i am     in caps   "
    assert_success
    assert_output "I AM IN CAPS"
  }

  @test "_cleanString_: remove spaces before/after dashes" {
    run _cleanString_ "word - another- word -another-word"
    assert_success
    assert_output "word-another-word-another-word"
  }

   @test "_cleanString_: remove spaces before/after underscores" {
    run _cleanString_ "word _ another_ word _another_word"
    assert_success
    assert_output "word_another_word_another_word"
  }

  @test "_cleanString_: alnum" {
    run _cleanString_ -a "  !@#$%^%& i am     in caps 12345 == "
    assert_success
    assert_output "i am in caps 12345"
  }

  @test "_cleanString_: alnum w/ spaces" {
    run _cleanString_ -as "this(is)a[string]"
    assert_success
    assert_output "this is a string"
  }

  @test "_cleanString_: alnum w/ spaces and dashes" {
    run _cleanString_ -as "this(is)a-string"
    assert_success
    assert_output "this is a-string"
  }

    @test "_cleanString_: alnum w/ spaces and dashes and regex replace" {
    run _cleanString_ -asp "-|_|st, " "th_is(is)a-string"
    assert_success
    assert_output "th is is a ring"
  }

  @test "_cleanString_: user replacement" {
    run _cleanString_ -p "e,g" "there should be a lot of e's in this sentence"
    assert_success
    assert_output "thgrg should bg a lot of g's in this sgntgncg"
  }

  @test "_cleanString_: remove specified characters" {
    run _cleanString_ "there should be a lot of e's in this sentence" "e"
    assert_success
    assert_output "thr should b a lot of 's in this sntnc"
  }

  @test "_cleanString_: compound test 1" {
    run _cleanString_ -p "2,4" -au "  @#$%[]{} clean   a compound command ==23---- " "e"
    assert_success
    assert_output "CLAN A COMPOUND COMMAND 43-"
  }

}
_testCleanString_

_testStopWords_() {

  @test "_stripStopwords_: success" {
    run _stripStopwords_ "A string to be parsed"
    assert_success
    assert_output "string parsed"
  }

  @test "_stripStopwords_: success w/ user terms" {
    run _stripStopwords_ "A string to be parsed to help pass this test being performed by bats" "bats,string"
    assert_success
    assert_output "parsed pass performed"
  }

  @test "_stripStopwords_: No changes" {
    run _stripStopwords_ "string parsed pass performed"
    assert_success
    assert_output "string parsed pass performed"
  }

  @test "_stripStopwords_: fail" {
    run _stripStopwords_
    assert_failure
  }

}
_testStopWords_

@test "_escapeString_" {
  run _escapeString_ "Here is some / text to & be - escaped"
  assert_success
  assert_output "Here\ is\ some\ /\ text\ to\ &\ be\ -\ escaped"
}

@test "_encodeHTML_" {
  run _encodeHTML_ "Here's some text& to > be h?t/M(l• en™codeç£§¶d"
  assert_success
  assert_output "Here's some text&amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
}

@test "_decodeHTML_" {
  run _decodeHTML_ "&clubs;Here's some text &amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
  assert_success
  assert_output "♣Here's some text & to > be h?t/M(l• en™codeç£§¶d"
}

@test "_lower" {
  local text="$(echo "MAKE THIS LOWERCASE" | _lower_)"

  run echo "$text"
  assert_output "make this lowercase"
}

@test "_ltrim_" {
  local text=$(_ltrim_ <<<"    some text")

  run echo "$text"
  assert_output "some text"
}

@test "_rtrim_" {
  local text=$(_rtrim_ <<<"some text    ")

  run echo "$text"
  assert_output "some text"
}

@test "_upper_" {
  local text="$(echo "make this uppercase" | _upper_)"

  run echo "$text"
  assert_output "MAKE THIS UPPERCASE"
}

@test "_encodeURL_" {
  run _encodeURL_ "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
  assert_success
  assert_output "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
}

@test "_decodeURL_" {
  run _decodeURL_ "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
  assert_success
  assert_output "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
}

@test "_regexCapture_: success" {
  run _regexCapture_ "#FFFFFF" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$' || echo "no match found"

  assert_success
  assert_output "#FFFFFF"
}

@test "_regexCapture_: success, case insensitive" {
  run _regexCapture_ -i "#FFFFFF" '^(#?([a-f0-9]{6}|[a-f0-9]{3}))$' || echo "no match found"

  assert_success
  assert_output "#FFFFFF"
}

@test "_regexCapture_: failure, no match found" {
  run _regexCapture_ "gggggg" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'

  assert_failure
}

@test "_regexCapture_: failure, would only match with case insensitive" {
  run _regexCapture_ "#FFFFFF" '^(#?([a-f0-9]{6}|[a-f0-9]{3}))$' || echo "no match found"

  assert_failure
}
