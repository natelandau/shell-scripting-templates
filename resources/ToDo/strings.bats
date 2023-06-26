# ---------------------------------------------------------------------------- #
# String::contains                                                             #
# ---------------------------------------------------------------------------- #

@test "String::contains -> If STRING contains SUBSTRING, the function should return 0, otherwise 1" {
  run String::contains "abcd" "ab"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "bc"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "cd"
  [ "${status}" -eq 0 ]

  # The string contains itself
  run String::contains "abcd" "abcd"
  [ "${status}" -eq 0 ]

  # Each string contains the empty string
  run String::contains "abcd" ""
  [ "${status}" -eq 0 ]

  # The empty string contains the empty string
  run String::contains "" ""
  [ "${status}" -eq 0 ]

  # If no SUBSTRING is specified, an empty string is assumed
  run String::contains "abcd"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "e"
  [ "${status}" -eq 1 ]
}

@test "String::contains: success" {
  run String::contains "hello world!" "lo"
  assert_success
}

@test "String::contains: failure" {
  run String::contains "hello world!" "LO"
  assert_failure
}

@test "String::contains: success, case insensitive" {
  run String::contains -i "hello world!" "LO"
  assert_success
}


# ---------------------------------------------------------------------------- #
# String::starts_with                                                          #
# ---------------------------------------------------------------------------- #

@test "String::starts_with -> If STRING starts with PREFIX, the function should return 0, otherwise 1" {
  # String completely upper case
  run String::starts_with "foobar" "foo"
  [ "${status}" -eq 0 ]

  # String partly upper case
  run String::starts_with "foobar" "FOO"
  [ "${status}" -eq 1 ]

  # String partly upper case
  run String::starts_with "foobar" "fooo"
  [ "${status}" -eq 1 ]

    # String completely lower case
  run String::starts_with "foobar"
  [ "${status}" -eq 0 ]

  # No argument
  run String::starts_with
  [ "${status}" -eq 0 ]
}


# ---------------------------------------------------------------------------- #
# String::to_lowercase                                                         #
# ---------------------------------------------------------------------------- #

@test "String::to_lowercase -> Should return STRING converted to lower case" {
  # String completely upper case
  run String::to_lowercase "FOOBAR"
  [ "${output}" == "foobar" ]

  # String partly upper case
  run String::to_lowercase "FOObar"
  [ "${output}" == "foobar" ]

    # String completely lower case
  run String::to_lowercase "foobar"
  [ "${output}" == "foobar" ]

  # No argument
  run String::to_lowercase
  [ "${output}" == "" ]
}

@test "_lower" {
  local text="$(echo "MAKE THIS LOWERCASE" | _lower_)"

  run echo "$text"
  assert_output "make this lowercase"
}


# ---------------------------------------------------------------------------- #
# String::to_uppercase                                                         #
# ---------------------------------------------------------------------------- #

@test "String::to_uppercase -> Should return STRING converted to upper case" {
  # String completely upper case
  run String::to_uppercase "foobar"
  [ "${output}" == "FOOBAR" ]

  # String partly upper case
  run String::to_uppercase "FOObar"
  [ "${output}" == "FOOBAR" ]

    # String completely lower case
  run String::to_uppercase "FOOBAR"
  [ "${output}" == "FOOBAR" ]

  # No argument
  run String::to_uppercase
  [ "${output}" == "" ]
}

@test "_upper_" {
  local text="$(echo "make this uppercase" | _upper_)"

  run echo "$text"
  assert_output "MAKE THIS UPPERCASE"
}


# ---------------------------------------------------------------------------- #
# _stringRegex_                                                                #
# ---------------------------------------------------------------------------- #

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


# ---------------------------------------------------------------------------- #
# _regexCapture_                                                               #
# ---------------------------------------------------------------------------- #

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
