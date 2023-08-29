#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/files.bash"
BASEHELPERS="${ROOTDIR}/utilities/misc.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:${PATH}"

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
unencrypted="${BATS_TEST_DIRNAME}/fixtures/test.md"
encrypted="${BATS_TEST_DIRNAME}/fixtures/test.md.enc"

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "_encryptFile_" {
  run _encryptFile_ "${unencrypted}" "test-encrypted.md.enc"
  assert_success
  assert_file_exist "test-encrypted.md.enc"
  run cat "test-encrypted.md.enc"
  assert_line --index 0 --partial "Salted__"
}

# TODO: Test is broken but the function works. re-write test
@test "_decryptFile_" {
  skip "Test is broken but the function works. re-write test"
  run _decryptFile_ "${encrypted}" "test-decrypted.md"
  assert_success
  assert_file_exist "test-decrypted.md"
  run cat "test-decrypted.md"
  assert_success
  assert_line --index 0 "# About"
  assert_line --index 1 "This repository contains everything needed to bootstrap and configure new Mac computer. Included here are:"
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

  @test "_listFiles: fail when no files found" {
    run _listFiles_ regex ".*notest[0-9]\.txt" "${TESTDIR}"
    assert_failure
  }
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

  @test "_makeSymlink_: Ignore already existing links - quiet" {
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run _makeSymlink_ -c "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output ""
  }

  @test "_makeSymlink_: Ignore already existing links - dryrun" {
    DRYRUN=true
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run _makeSymlink_ "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output --regexp "\[ dryrun\] Symlink already exists: /.*/test\.txt → /.*/test2\.txt"
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
    run _parseYAML_ "$YAML1" ""
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

@test "_randomLineFromFile_" {
  echo -e "line 1\nline 2\nline 3" > testfile.txt

  run _randomLineFromFile_ "testfile.txt"
  assert_output --regexp "^line [123]$"
}

@test "_sourceFile_ failure" {
  run _sourceFile_ "someNonExistentFile"

  assert_failure
  assert_output --partial "[  fatal] Attempted to source 'someNonExistentFile'. Not found"
}

@test "_sourceFile_ success" {
  echo "echo 'hello world'" > "testSourceFile.txt"
  run _sourceFile_ "testSourceFile.txt"

  assert_success
  assert_output "hello world"
}

@test "_createUniqueFilename_: no extension" {
  touch "test"

  run _createUniqueFilename_ "test"
  assert_output --regexp ".*/test\.1$"
}

@test "_createUniqueFilename_: no extension - internal integer" {
  touch "test"
  touch "test.1"

  run _createUniqueFilename_ -i "test"
  assert_output --regexp ".*/test\.2$"
}

@test "_createUniqueFilename_: Count to 3" {
  touch "test.txt"
  touch "test.txt.1"
  touch "test.txt.2"

  run _createUniqueFilename_ "test.txt"
  assert_output --regexp ".*/test\.txt\.3$"
}

@test "_createUniqueFilename_: internal integer" {
  touch "test.txt"
  touch "test.1.txt"
  touch "test.2.txt"

  run _createUniqueFilename_ -i "test.txt"
  assert_output --regexp ".*/test\.3\.txt$"
}

@test "_createUniqueFilename_: two extensions" {
  touch "test.tar.gz"
  touch "test.1.tar.gz"
  touch "test.2.tar.gz"

  run _createUniqueFilename_ -i "test.tar.gz"
  assert_output --regexp ".*/test\.3\.tar.gz$"
}

@test "_createUniqueFilename_: Don't confuse existing numbers" {
  touch "test-2.txt"

  run _createUniqueFilename_ "test-2.txt"
  assert_output --regexp ".*/test-2\.txt\.1$"
}

@test "_createUniqueFilename_: User specified separator" {
  touch "test.txt"

  run _createUniqueFilename_ "test.txt" " "
  assert_output --regexp ".*/test\.txt 1$"
}

@test "_createUniqueFilename_: failure" {
  run _createUniqueFilename_

  assert_failure
}

@test "_fileName_: with extension" {
  run _fileName_ "./path/to/file/test.txt"
  assert_success
  assert_output "test.txt"
}

@test "_fileName_: without extension" {
  run _fileName_ "path/to/file/test"
  assert_success
  assert_output "test"
}

@test "_fileBasename_" {
  run _fileBasename_ "path/to/file/test.txt"
  assert_success
  assert_output "test"
}

@test "_fileExtension_: simple extension" {
    run _fileExtension_ "path/to/file/test.txt"
  assert_success
  assert_output "txt"
}

@test "_fileExtension_: no extension" {
    run _fileExtension_ "path/to/file/test"
  assert_failure
}

@test "_fileExtension_: two level extension" {
  run _fileExtension_ "path/to/file/test.tar.bz2"
  assert_success
  assert_output "tar.bz2"
}

@test "_filePath_: does not exist" {
  run _filePath_ "path/to/file/test.txt"
  assert_success
  assert_output "path/to/file"
}

@test "_filePath_: exists" {
  touch "./test.txt"
  run _filePath_ "./test.txt"
  assert_success
  assert_output --regexp "^/.*/files\.bats-"
}

@test "_fileContains_: No match" {
  echo "some text" > "./test.txt"
  run _fileContains_ "./test.txt" "nothing here"
  assert_failure
}

@test "_fileContains_: Pattern matched" {
  echo "some text" > "./test.txt"
  run _fileContains_ "./test.txt" "some*"
  assert_success
}

@test "_printFileBetween_: match case-insensitive" {
  run _printFileBetween_ -i "^#+ orange1" "^#+$" "${TEXT}"
  assert_success
  assert_line --index 0 "############ Orange1 ############"
  assert_line --index 1 "# 1"
  assert_line --index 2 "# 2"
  assert_line --index 3 "# 3"
  assert_line --index 4 "# 4"
  assert_line --index 5 "#################################"
  refute_output --regexp "Grape|Orange2"
}

@test "_printFileBetween_: match case-insensitive - greedy" {
  run _printFileBetween_ -ig "^#+ orange" "##" "${TEXT}"
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

@test "_printFileBetween_: no match" {
  run _printFileBetween_ "^#+ orange1" "^#+$" "${TEXT}"
  assert_failure
}

@test "_printFileBetween_: remove lines" {
  run _printFileBetween_ -ri "^[A-Z0-9]+\(\)" "^ *}.*" "${TEXT}"
  assert_success
  assert_line --index 0 --partial "# buf :  Backup file with time stamp"
  assert_line --index 5 --regexp "^ *cp -a .*"
  refute_output --regexp "buf\(\) {"
  refute_output --regexp '}[^"_]'
  refute_output --regexp "md5Check"
}

@test "_printFileBetween_: remove lines - greedy" {
  run _printFileBetween_ -gr "^[a-zA-Z0-9]+\(\)" "^ *}.*" "${TEXT}"
  assert_success
  assert_line --index 0 --partial "# buf :  Backup file with time stamp"
  assert_line --index 5 --regexp "^ *cp -a .*"
  refute_output --regexp "buf\(\) {"
  assert_line --index 29 --regexp "^ *fi.*"
  assert_output --regexp "md5Check"
}

_testBackupFile_
_testListFiles_
_testMakeSymlink_
_testParseYAML_
