#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/files.bash"
BASEHELPERS="${ROOTDIR}/utilities/baseHelpers.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"

if test -f "${SOURCEFILE}" >&2; then
  source "${SOURCEFILE}"
else
  echo "Sourcefile not found: ${SOURCEFILE}" >&2
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

if test -f "${ALERTS}" >&2; then
  source "${ALERTS}"
else
  echo "Sourcefile not found: ${ALERTS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAUL FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false
  PASS=123

}

teardown() {
  popd &>/dev/null
  temp_del "${TESTDIR}"
}

######## FIXTURES ########
YAML1="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml"
YAML1parse="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml.txt"
unencrypted="${BATS_TEST_DIRNAME}/fixtures/test.md"
encrypted="${BATS_TEST_DIRNAME}/fixtures/test.md.enc"

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "_decryptFile_" {
  run _decryptFile_ "${encrypted}" "test-decrypted.md"
  assert_success
  assert_file_exist "test-decrypted.md"
  run cat "test-decrypted.md"
  assert_success
  assert_line --index 0 "# About"
  assert_line --index 1 "This repository contains everything needed to bootstrap and configure new Mac computer. Included here are:"
}

@test "_encryptFile_" {
  run _encryptFile_ "${unencrypted}" "test-encrypted.md.enc"
  assert_success
  assert_file_exist "test-encrypted.md.enc"
  run cat "test-encrypted.md.enc"
  assert_line --index 0 --partial "Salted__"
}

_testBackupFile_() {

  @test "_backupFile_: no source" {
    run _backupFile_ "testfile"

    assert_failure
  }

  @test "_backupFile_: simple backup" {
    touch "testfile"
    run _backupFile_ "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
  }

  @test "_backupFile_: backup and unique name" {
    touch "testfile"
    touch "testfile.bak"
    run _backupFile_ "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
    assert_file_exist "testfile.bak.1"
  }

  @test "_backupFile_: move" {
    touch "testfile"
    run _backupFile_ -m "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_not_exist "testfile"
  }

  @test "_backupFile_: directory" {
    touch "testfile"
    run _backupFile_ -d "testfile"

    assert_success
    assert_file_exist "backup/testfile"
    assert_file_exist "testfile"
  }

  @test "_backupFile_: move to directory w/ custom name" {
    touch "testfile"
    run _backupFile_ -dm "testfile" "dir"

    assert_success
    assert_file_exist "dir/testfile"
    assert_file_not_exist "testfile"
  }

}

_testListFiles_() {
  @test "_listFiles_: glob" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run _listFiles_ g "yestest*.txt" "${TESTDIR}"

    assert_success
    assert_output --partial "yestest1.txt"
    refute_output --partial "notest1.txt"
  }

  @test "_listFiles_: regex" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run _listFiles_ regex ".*notest[0-9]\.txt" "${TESTDIR}"

    assert_success
    refute_output --partial "yestest1.txt"
    assert_output --partial "notest1.txt"
  }

  @test "_listFiles: fail no args" {
    run _listFiles_
    assert_failure
  }

  @test "_listFiles: fail one arg" {
    run _listFiles_ "g"
    assert_failure
  }
}

_testParseFilename_() {

  @test "_parseFilename_: fail with no file" {
    run _parseFilename_ "somenonexistantfile"
    assert_failure
    assert_output --partial "Can't locate a file to parse"
  }

  @test "_parseFilename_: file with one extension" {
    touch "testfile.txt"
    VERBOSE=true
    run _parseFilename_ "testfile.txt"

    assert_success
    assert_line --index 0 --regexp "\[  debug\].*{PARSE_FULL}: /.*testfile\.txt$"
    assert_line --index 1 --regexp "\[  debug\].*${PARSE_BASE}: testfile\.txt$"
    assert_line --index 2 --regexp "\[  debug\].*${PARSE_PATH}: /.*"
    assert_line --index 3 --regexp "\[  debug\].*${PARSE_EXT}: txt$"
    assert_line --index 4 --regexp "\[  debug\].*${PARSE_BASENOEXT}: testfile$"
  }

  @test "_parseFilename_: file with dots in name" {
    touch "testfile.for.testing.txt"
    VERBOSE=true
    run _parseFilename_ "testfile.for.testing.txt"

    assert_success
    assert_line --index 0 --regexp "\[  debug\].*{PARSE_FULL}: /.*testfile\.for\.testing\.txt$"
    assert_line --index 1 --regexp "\[  debug\].*${PARSE_BASE}: testfile\.for\.testing\.txt$"
    assert_line --index 2 --regexp "\[  debug\].*${PARSE_PATH}: /.*"
    assert_line --index 3 --regexp "\[  debug\].*${PARSE_EXT}: txt$"
    assert_line --index 4 --regexp "\[  debug\].*${PARSE_BASENOEXT}: testfile\.for\.testing$"
  }

  @test "_parseFilename_: file with no extension" {
    touch "testfile"
    VERBOSE=true
    run _parseFilename_ "testfile"

    assert_success
    assert_line --index 0 --regexp "\[  debug\].*{PARSE_FULL}: /.*testfile$"
    assert_line --index 1 --regexp "\[  debug\].*${PARSE_BASE}: testfile$"
    assert_line --index 2 --regexp "\[  debug\].*${PARSE_PATH}: /.*"
    assert_line --index 3 --regexp "\[  debug\].*${PARSE_EXT}: $"
    assert_line --index 4 --regexp "\[  debug\].*${PARSE_BASENOEXT}: testfile$"
  }

  @test "_parseFilename_: file with tar.gz" {
    touch "testfile.tar.gz"
    VERBOSE=true
    run _parseFilename_ "testfile.tar.gz"

    assert_success
    assert_line --index 0 --regexp "\[  debug\].*{PARSE_FULL}: /.*testfile\.tar\.gz$"
    assert_line --index 1 --regexp "\[  debug\].*${PARSE_BASE}: testfile\.tar\.gz$"
    assert_line --index 2 --regexp "\[  debug\].*${PARSE_PATH}: /.*"
    assert_line --index 3 --regexp "\[  debug\].*${PARSE_EXT}: tar\.gz$"
    assert_line --index 4 --regexp "\[  debug\].*${PARSE_BASENOEXT}: testfile$"
  }

  @test "_parseFilename_: file with three extensions" {
    touch "testfile.tar.gzip.bzip"
    VERBOSE=true
    run _parseFilename_ -n3 "testfile.tar.gzip.bzip"

    assert_success
    assert_line --index 0 --regexp "\[  debug\].*{PARSE_FULL}: /.*testfile\.tar\.gzip\.bzip$"
    assert_line --index 1 --regexp "\[  debug\].*${PARSE_BASE}: testfile\.tar\.gzip\.bzip$"
    assert_line --index 2 --regexp "\[  debug\].*${PARSE_PATH}: /.*"
    assert_line --index 3 --regexp "\[  debug\].*${PARSE_EXT}: tar\.gzip\.bzip$"
    assert_line --index 4 --regexp "\[  debug\].*${PARSE_BASENOEXT}: testfile$"
  }

  # _parseFilename_ "test.tar.gz"
  # _parseFilename_ "test.tar.gzip"
}

_testMakeSymlink_() {

  @test "_makeSymlink_: Fail with no source fire" {
    run _makeSymlink_ "sourceFile" "destFile"

    assert_failure
  }

  @test "_makeSymlink_: fail with no specified destination" {
    touch "test.txt"
    run _makeSymlink_ "test.txt"

    assert_failure
  }

  @test "_makeSymlink_: make link" {
    touch "test.txt"
    touch "test2.txt"
    run _makeSymlink_ "${TESTDIR}/test.txt" "${TESTDIR}/test2.txt"

    assert_success
    assert_output --regexp "\[   info\] symlink /.*/test\.txt → /.*/test2\.txt"
    assert_link_exist "test2.txt"
    assert_file_exist "test2.txt.bak"
  }

  @test "_makeSymlink_: Ignore already existing links" {
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run _makeSymlink_ "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output --regexp "\[   info\] Symlink already exists: /.*/test\.txt → /.*/test2\.txt"
  }

  @test "_makeSymlink_: Don't make backup" {
    touch "test.txt"
    touch "test2.txt"
    run _makeSymlink_ -n "${TESTDIR}/test.txt" "${TESTDIR}/test2.txt"

    assert_success
    assert_output --regexp "\[   info\] symlink /.*/test\.txt → /.*/test2\.txt"
    assert_link_exist "test2.txt"
    assert_file_not_exist "test2.txt.bak"
  }

}

_testParseYAML_() {

  @test "_parseYAML: success" {
    run _parseYAML_ "$YAML1"
    assert_success
    assert_output "$( cat "$YAML1parse")"
  }

  @test "_parseYAML_: empty file" {
    touch empty.yaml
    run _parseYAML_ "empty.yaml"
    assert_failure
  }

  @test "_parseYAML_: no file" {
    run _parseYAML_ "empty.yaml"
    assert_failure
  }
}

@test "_readFile_: Failure" {
  run _readFile_ "testfile.txt"
  assert_failure
}

@test "_readFile_: Reads files line by line" {
  echo -e "line 1\nline 2\nline 3" > testfile.txt

  run _readFile_ "testfile.txt"
  assert_line --index 0 'line 1'
  assert_line --index 2 'line 3'
}

@test "_sourceFile_ failure" {
  run _sourceFile_ "someNonExistantFile"

  assert_failure
  assert_output --partial "[  fatal] Attempted to source 'someNonExistantFile'. Not found"
}

@test "_sourceFile_ success" {
  echo "echo 'hello world'" > "testSourceFile.txt"
  run _sourceFile_ "testSourceFile.txt"

  assert_success
  assert_output "hello world"
}

@test "_uniqueFileName_: Count to 3" {
  touch "test.txt"
  touch "test.txt.1"
  touch "test.txt.2"

  run _uniqueFileName_ "test.txt"
  assert_output --regexp ".*/test\.txt\.3$"
}

@test "_uniqueFileName_: Don't confuse existing numbers" {
  touch "test-2.txt"

  run _uniqueFileName_ "test-2.txt"
  assert_output --regexp ".*/test-2\.txt\.1$"
}

@test "_uniqueFileName_: User specified separator" {
  touch "test.txt"

  run _uniqueFileName_ "test.txt" " "
  assert_output --regexp ".*/test\.txt 1$"
}

@test "_uniqueFileName_: failure" {
  run _uniqueFileName_

  assert_failure
}

_testBackupFile_
_testListFiles_
_testParseFilename_
_testMakeSymlink_
_testParseYAML_
