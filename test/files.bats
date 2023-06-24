#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/arrays
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

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:${PATH}"

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
  PASS=123
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

######## FIXTURES ########
TEXT="${BATS_TEST_DIRNAME}/fixtures/text.txt"
YAML1="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml"
YAML1parse="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml.txt"

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

# ---------------------------------------------------------------------------- #
# bfl::get_file_name                                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::get_file_name: with extension" {
  run bfl::get_file_name "./path/to/file/test.txt"
  assert_success
  assert_output "test.txt"
}

@test "bfl::get_file_name: without extension" {
  run bfl::get_file_name "path/to/file/test"
  assert_success
  assert_output "test"
}

# ---------------------------------------------------------------------------- #
# bfl::get_file_basename                                                       #
# ---------------------------------------------------------------------------- #

@test "bfl::get_file_basename" {
  run bfl::get_file_basename "path/to/file/test.txt"
  assert_success
  assert_output "test"
}

# ---------------------------------------------------------------------------- #
# bfl::get_file_extension                                                      #
# ---------------------------------------------------------------------------- #

@test "bfl::get_file_extension: simple extension" {
    run bfl::get_file_extension "path/to/file/test.txt"
  assert_success
  assert_output "txt"
}

@test "bfl::get_file_extension: no extension" {
    run bfl::get_file_extension "path/to/file/test"
  assert_failure
}

@test "bfl::get_file_extension: two level extension" {
  run bfl::get_file_extension "path/to/file/test.tar.bz2"
  assert_success
  assert_output "tar.bz2"
}

# ---------------------------------------------------------------------------- #
# bfl::get_canonical_path                                                      #
# ---------------------------------------------------------------------------- #

@test "bfl::get_canonical_path" {
    run bfl::get_canonical_path
    assert_success
    if [[ -d /usr/local/Cellar/ ]]; then
        assert_output --regexp "^/usr/local/Cellar/bats-core/[0-9]\.[0-9]\.[0-9]"
    elif [[ -d /opt/homebrew/Cellar ]]; then
        assert_output --regexp "^/opt/homebrew/Cellar/bats-core/[0-9]\.[0-9]\.[0-9]"
    fi
}

# ---------------------------------------------------------------------------- #
# bfl::get_files_list                                                          #
# ---------------------------------------------------------------------------- #

_testListFiles_() {
  @test "bfl::get_files_list: glob" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run bfl::get_files_list g "yestest*.txt" "${TESTDIR}"

    assert_success
    assert_output --partial "yestest1.txt"
    refute_output --partial "notest1.txt"
  }

  @test "bfl::get_files_list: regex" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run bfl::get_files_list regex ".*notest[0-9]\.txt" "${TESTDIR}"

    assert_success
    refute_output --partial "yestest1.txt"
    assert_output --partial "notest1.txt"
  }

  @test "_listFiles: fail no args" {
    run bfl::get_files_list
    assert_failure
  }

  @test "_listFiles: fail one arg" {
    run bfl::get_files_list "g"
    assert_failure
  }

  @test "_listFiles: fail when no files found" {
    run bfl::get_files_list regex ".*notest[0-9]\.txt" "${TESTDIR}"
    assert_failure
  }
}

# ---------------------------------------------------------------------------- #
# bfl::parse_yaml                                                              #
# ---------------------------------------------------------------------------- #

_testParseYAML_() {

  @test "bfl::parse_yaml: success" {
    run bfl::parse_yaml_ "$YAML1" ""
    assert_success
    assert_output "$( cat "$YAML1parse")"
  }

  @test "bfl::parse_yaml_: empty file" {
    touch empty.yaml
    run bfl::parse_yaml_ "empty.yaml"
    assert_failure
  }

  @test "bfl::parse_yaml_: no file" {
    run bfl::parse_yaml_ "empty.yaml"
    assert_failure
  }
}

# ---------------------------------------------------------------------------- #
# bfl::get_unique_filename                                                     #
# ---------------------------------------------------------------------------- #

@test "bfl::get_unique_filename: no extension" {
  touch "test"

  run bfl::get_unique_filename "test"
  assert_output --regexp ".*/test\.1$"
}

@test "bfl::get_unique_filename: no extension - internal integer" {
  touch "test"
  touch "test.1"

  run bfl::get_unique_filename -i "test"
  assert_output --regexp ".*/test\.2$"
}

@test "bfl::get_unique_filename: Count to 3" {
  touch "test.txt"
  touch "test.txt.1"
  touch "test.txt.2"

  run bfl::get_unique_filename "test.txt"
  assert_output --regexp ".*/test\.txt\.3$"
}

@test "bfl::get_unique_filename: internal integer" {
  touch "test.txt"
  touch "test.1.txt"
  touch "test.2.txt"

  run bfl::get_unique_filename -i "test.txt"
  assert_output --regexp ".*/test\.3\.txt$"
}

@test "bfl::get_unique_filename: two extensions" {
  touch "test.tar.gz"
  touch "test.1.tar.gz"
  touch "test.2.tar.gz"

  run bfl::get_unique_filename -i "test.tar.gz"
  assert_output --regexp ".*/test\.3\.tar.gz$"
}

@test "bfl::get_unique_filename: Don't confuse existing numbers" {
  touch "test-2.txt"

  run bfl::get_unique_filename "test-2.txt"
  assert_output --regexp ".*/test-2\.txt\.1$"
}

@test "bfl::get_unique_filename: User specified separator" {
  touch "test.txt"

  run bfl::get_unique_filename "test.txt" " "
  assert_output --regexp ".*/test\.txt 1$"
}

@test "bfl::get_unique_filename: failure" {
  run bfl::get_unique_filename

  assert_failure
}

# ---------------------------------------------------------------------------- #
# bfl::file_contains                                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::file_contains: No match" {
  echo "some text" > "./test.txt"
  run bfl::file_contains "./test.txt" "nothing here"
  assert_failure
}

@test "bfl::file_contains: Pattern matched" {
  echo "some text" > "./test.txt"
  run bfl::file_contains "./test.txt" "some*"
  assert_success
}

# ---------------------------------------------------------------------------- #
# bfl::get_file_part                                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::get_file_part: match case-insensitive" {
  run bfl::get_file_part -i "^#+ orange1" "^#+$" "${TEXT}"
  assert_success
  assert_line --index 0 "############ Orange1 ############"
  assert_line --index 1 "# 1"
  assert_line --index 2 "# 2"
  assert_line --index 3 "# 3"
  assert_line --index 4 "# 4"
  assert_line --index 5 "#################################"
  refute_output --regexp "Grape|Orange2"
}

@test "bfl::get_file_part: match case-insensitive - greedy" {
  run bfl::get_file_part -ig "^#+ orange" "##" "${TEXT}"
  assert_success
  assert_line --index 0 "############ Orange1 ############"
  assert_line --index 1 "# 1"
  assert_line --index 2 "# 2"
  assert_line --index 3 "# 3"
  assert_line --index 4 "# 4"
  assert_line --index 5 "#################################"
  assert_line --index 6 "############ Orange2 ############"
  assert_line --index 7 "# 1"
  assert_line --index 8 "# 2"
  assert_line --index 9 "# 3"
  assert_line --index 10 "# 4"
  assert_line --index 11 "#################################"
  refute_output --regexp "Grape"
}

@test "bfl::get_file_part: no match" {
  run bfl::get_file_part "^#+ orange1" "^#+$" "${TEXT}"
  assert_failure
}

@test "bfl::get_file_part: remove lines" {
  run bfl::get_file_part -ri "^[A-Z0-9]+\(\)" "^ *}.*" "${TEXT}"
  assert_success
  assert_line --index 0 --partial "# buf :  Backup file with time stamp"
  assert_line --index 5 --regexp "^ *cp -a .*"
  refute_output --regexp "buf\(\) {"
  refute_output --regexp '}[^"_]'
  refute_output --regexp "md5Check"
}

@test "bfl::get_file_part: remove lines - greedy" {
  run bfl::get_file_part -gr "^[a-zA-Z0-9]+\(\)" "^ *}.*" "${TEXT}"
  assert_success
  assert_line --index 0 --partial "# buf :  Backup file with time stamp"
  assert_line --index 5 --regexp "^ *cp -a .*"
  refute_output --regexp "buf\(\) {"
  assert_line --index 29 --regexp "^ *fi.*"
  assert_output --regexp "md5Check"
}

_testListFiles_
_testParseYAML_
