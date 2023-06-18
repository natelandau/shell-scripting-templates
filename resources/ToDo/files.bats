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

@test "bfl::read_file: Failure" {
  run bfl::read_file "testfile.txt"
  assert_failure
}

@test "bfl::read_file: Reads files line by line" {
  echo -e "line 1\nline 2\nline 3" > testfile.txt

  run bfl::read_file "testfile.txt"
  assert_line --index 0 'line 1'
  assert_line --index 2 'line 3'
}

@test "bfl::source_file failure" {
  run bfl::source_file "someNonExistantFile"

  assert_failure
  assert_output --partial "[  fatal] Attempted to source 'someNonExistantFile'. Not found"
}

@test "bfl::source_file success" {
  echo "echo 'hello world'" > "testSourceFile.txt"
  run bfl::source_file "testSourceFile.txt"

  assert_success
  assert_output "hello world"
}
