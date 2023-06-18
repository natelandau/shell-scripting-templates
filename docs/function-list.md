## Bash Function Library
[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / [Installation](installation.md) / [Description](description.md) / Coding / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Function List

* [bfl::declare_ansi_escape_sequences](#bfldeclare_ansi_escape_sequences)
* [bfl::die](#bfldie)
* [bfl::error](#bflerror)
* [bfl::find_nearest_integer](#bflfind_nearest_integer)
* [bfl::generate_password](#bflgenerate_password)
* [bfl::get_directory_path](#bflget_directory_path)
* [bfl::get_file_directory](#bflget_file_directory)
* [bfl::get_file_extension](#bflget_file_extension)
* [bfl::get_file_name](#bflget_file_name)
* [bfl::get_file_basename](#bflget_file_basename)
* [bfl::get_file_path](#bflget_file_path)
* [bfl::inform](#bflinform)
* [bfl::is_apache_vhost](#bflis_apache_vhost)
* [bfl::is_blank](#bflis_blank)
* [bfl::is_empty](#bflis_empty)
* [bfl::is_integer](#bflis_integer)
* [bfl::is_positive_integer](#bflis_positive_integer)
* [bfl::join](#bfljoin)
* [bfl::lorem](#bfllorem)
* [bfl::print_args](#bflprint_args)
* [bfl::repeat](#bflrepeat)
* [bfl::send_mail_msg](#bflsend_mail_msg)
* [bfl::send_sms_msg](#bflsend_sms_msg)
* [bfl::time_convert_s_to_hhmmss](#bfltime_convert_s_to_hhmmss)
* [bfl::transliterate](#bfltransliterate)
* [bfl::trim](#bfltrim)
* [bfl::urlencode](#bflurlencode)
* [bfl::verify_arg_count](#bflverify_arg_count)
* [bfl::verify_dependencies](#bflverify_dependencies)
* [bfl::warn](#bflwarn)

## bfl::declare_ansi_escape_sequences

Declares ANSI escape sequences.

**Returns**

global string $bfl_aes_black
>ANSI escape sequence for black.

global string $bfl_aes_black_bold
>ANSI escape sequence for black + bold.

global string $bfl_aes_black_faint
>ANSI escape sequence for black + faint.

global string $bfl_aes_black_underline
>ANSI escape sequence for black + underline.

global string $bfl_aes_black_blink
>ANSI escape sequence for black + blink.

global string $bfl_aes_black_reverse
>ANSI escape sequence for black + reverse.

global string $bfl_aes_red
>ANSI escape sequence for red.

global string $bfl_aes_red_bold
>ANSI escape sequence for red + bold.

global string $bfl_aes_red_faint
>ANSI escape sequence for red + faint.

global string $bfl_aes_red_underline
>ANSI escape sequence for red + underline.

global string $bfl_aes_red_blink
>ANSI escape sequence for red + blink.

global string $bfl_aes_red_reverse
>ANSI escape sequence for red + reverse.

global string $bfl_aes_green
>ANSI escape sequence for green.

global string $bfl_aes_green_bold
>ANSI escape sequence for green + bold.

global string $bfl_aes_green_faint
>ANSI escape sequence for green + faint.

global string $bfl_aes_green_underline
>ANSI escape sequence for green + underline.

global string $bfl_aes_green_blink
>ANSI escape sequence for green + blink.

global string $bfl_aes_green_reverse
>ANSI escape sequence for green + reverse.

global string $bfl_aes_yellow
>ANSI escape sequence for yellow.

global string $bfl_aes_yellow_bold
>ANSI escape sequence for yellow + bold.

global string $bfl_aes_yellow_faint
>ANSI escape sequence for yellow + faint.

global string $bfl_aes_yellow_underline
>ANSI escape sequence for yellow + underline.

global string $bfl_aes_yellow_blink
>ANSI escape sequence for yellow + blink.

global string $bfl_aes_yellow_reverse
>ANSI escape sequence for yellow + reverse.

global string $bfl_aes_blue
>ANSI escape sequence for blue.

global string $bfl_aes_blue_bold
>ANSI escape sequence for blue + bold.

global string $bfl_aes_blue_faint
>ANSI escape sequence for blue + faint.

global string $bfl_aes_blue_underline
>ANSI escape sequence for blue + underline.

global string $bfl_aes_blue_blink
>ANSI escape sequence for blue + blink.

global string $bfl_aes_blue_reverse
>ANSI escape sequence for blue + reverse.

global string $bfl_aes_magenta
>ANSI escape sequence for magenta.

global string $bfl_aes_magenta_bold
>ANSI escape sequence for magenta + bold.

global string $bfl_aes_magenta_faint
>ANSI escape sequence for magenta + faint.

global string $bfl_aes_magenta_underline
>ANSI escape sequence for magenta + underline.

global string $bfl_aes_magenta_blink
>ANSI escape sequence for magenta + blink.

global string $bfl_aes_magenta_reverse
>ANSI escape sequence for magenta + reverse.

global string $bfl_aes_cyan
>ANSI escape sequence for cyan.

global string $bfl_aes_cyan_bold
>ANSI escape sequence for cyan + bold.

global string $bfl_aes_cyan_faint
>ANSI escape sequence for cyan + faint.

global string $bfl_aes_cyan_underline
>ANSI escape sequence for cyan + underline.

global string $bfl_aes_cyan_blink
>ANSI escape sequence for cyan + blink.

global string $bfl_aes_cyan_reverse
>ANSI escape sequence for cyan + reverse.

global string $bfl_aes_white
>ANSI escape sequence for white.

global string $bfl_aes_white_bold
>ANSI escape sequence for white + bold.

global string $bfl_aes_white_faint
>ANSI escape sequence for white + faint.

global string $bfl_aes_white_underline
>ANSI escape sequence for white + underline.

global string $bfl_aes_white_blink
>ANSI escape sequence for white + blink.

global string $bfl_aes_white_reverse
>ANSI escape sequence for white + reverse.

**Example**

```bash
bfl::declare_ansi_escape_sequences
```

## bfl::die

Prints a fatal error message to stderr, then exits with status code 1.

**Parameter**

string $msg (optional)
>The message.

**Example**

```bash
bfl::error "The foo is bar."
```

## bfl::error

Prints an error message to stderr.

**Parameter**

string $msg (optional)
>The message.

**Example**

```bash
bfl::error "The foo is bar."
```

## bfl::find_nearest_integer

Finds the nearest integer to a target integer from a list of integers.

**Parameters**

string $target
>The target integer.

string $list
>A list of integers.

**Return**

string $nearest
>Integer in list that is nearest to the target.

**Example**

```bash
bfl::find_nearest_integer "4" "0 3 6 9 12"
```

## bfl::generate_password

Generates a random password.

**Parameter**

int $pswd_length
>The length of the desired password.

**Return**

string $password
>A random password

**Example**

```bash
bfl::generate_password "16"
```

## bfl::get_directory_path

Gets the canonical path to a directory.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $canonical_directory_path
>The canonical path to the directory.

**Example**

```bash
bfl::get_directory_path "./foo"
```

## bfl::get_file_directory

Gets the canonical path to the directory in which a file resides.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $canonical_directory_path
>The canonical path to the directory in which a file resides.

**Example**

```bash
bfl::get_file_directory "./foo/bar.txt"
```

## bfl::get_file_extension

Gets the file extension.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $file_extension
>The file extension, excluding the preceding period.

**Example**

```bash
bfl::get_file_extension "./foo/bar.txt"
```

## bfl::get_file_name

Gets the file name, including extension.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $file_name
>The file name, including extension.

**Example**

```bash
bfl::get_file_name "./foo/bar.text"
```

## bfl::get_file_basename

Gets the file name, excluding extension.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $file_basename
>The file name, excluding extension.

**Example**

```bash
bfl::get_file_basename "./foo/bar.txt"
```

## bfl::get_file_path

Gets the canonical path to a file.

**Parameter**

string $path
>A relative path, absolute path, or symbolic link.

**Return**

string $canonical_file_path
>The canonical path to the file.

**Example**

```bash
bfl::get_file_path "./foo/bar.text"
```

## bfl::inform

Prints an informational message to stderr.

**Parameter**

string $msg (optional)
>The message. A blank line will be printed if no message is provided.

**Example**

```bash
bfl::inform "The foo is bar."
```

## bfl::is_apache_vhost

Checks if the given path is the root of an Apache virtual host.

**Parameters**

string $path
>A relative path, absolute path, or symbolic link.

string $sites_enabled [optional]
>Absolute path to Apache's "sites-enabled" directory.

**Examples**

```bash
bfl::is_apache_vhost "./foo"
bfl::is_apache_vhost "./foo" "/etc/apache2/sites-enabled"
```

## bfl::is_blank

Checks if a string is whitespace, empty (""), or null.

**Parameter**

string $str
>The string to check.

**Example**

```bash
bfl::is_blank "foo"
```

## bfl::is_empty

Checks if a string is empty ("") or null.

**Parameter**

string $str
>The string to check.

**Example**

```bash
bfl::is_empty "foo"
```

## bfl::is_integer

Determines if the argument is an integer.

**Parameter**

string $value_to_test
>The value to be tested.

**Example**

```bash
bfl::is_integer "8675309"
```

## bfl::is_positive_integer

Determines if the argument is a positive integer.

**Parameter**

string $value_to_test
>The value to be tested.

**Example**

```bash
bfl::is_positive_integer "8675309"
```

## bfl::join

Joins multiple strings into a single string, separated by another string.

**Parameters**

string $glue
>The character or characters that will be used to glue the strings together.

list $pieces
>The list of strings to be combined.

**Return**

string $joined_string
>The joined string.

**Example**

```bash
bfl::join "," "foo" "bar" "baz"
```

## bfl::lorem

Randomly extracts one or more sequential paragraphs from a given resource.

**Parameters**

int $paragraphs (optional)
>The number of paragraphs to extract (default: 1).

string $resource (optional)
>The resource from which to extract the paragraphs (default: muir).

**Return**

string $text
>The extracted paragraphs.

**Examples**

```bash
bfl::lorem
bfl::lorem 2
bfl::lorem 3 burroughs
bfl::lorem 3 darwin
bfl::lorem 3 mills
bfl::lorem 3 muir
bfl::lorem 3 virgil
```

## bfl::print_args

Prints the arguments passed to this function.

**Parameter**

list $arguments
>One or more arguments.

**Example**

```bash
bfl::print_args "foo" "bar" "baz"
```

## bfl::repeat

Repeats a string.

**Parameters**

string $str
>The string to be repeated.

int $multiplier
>Number of times the string will be repeated.

**Return**

string $str_repeated
>The repeated string.

**Example**

```bash
bfl::repeat "=" "10"
```

## bfl::send_mail_msg

Sends an email message via sendmail.

**Parameters**

string $to
>Message recipient or recipients.

string $from
>Message sender.

string $envelope_from
>Envelope sender address.

string $subject
>Message subject.

string $body
>Message body.

**Example**

```bash
bfl::send_mail_msg "a@b.com" "x@y.com" "x@y.com" "Test" "Line 1.\nLine 2."
```

## bfl::send_sms_msg

Sends an SMS message via Amazon Simple Notification Service (SNS).

**Parameters**

string $phone_number
>Recipient's phone number, including country code.

string $message
>Example: "This is line one.\nThis is line two.\n"

**Example**

```bash
bfl::send_sms_msg "+12065550100" "Line 1.\nLine 2."
```

## bfl::time_convert_s_to_hhmmss

Converts seconds to the hh:mm:ss format.

**Parameter**

int $seconds
>The number of seconds to convert.

**Return**

string $hhmmss
>The number of seconds in hh:mm:ss format.

**Example**

```bash
bfl::time_convert_s_to_hhmmss "3661"
```

## bfl::transliterate

Transliterates a string.

**Parameter**

string $str
>The string to transliterate.

**Return**

string $str_transliterated
>The transliterated string.

**Example**

```bash
bfl::transliterate "_Olé Über! "
```

## bfl::trim

Removes leading and trailing whitespace, including blank lines, from string.

**Parameter**

string $str
>The string to be trimmed.

**Return**

string $str_trimmed
>The trimmed string.

**Example**

```bash
bfl::trim " foo "
```

## bfl::urlencode

Percent-encodes a URL.

**Parameter**

string $str
>The string to be encoded.

**Return**

string $str_encoded
>The encoded string.

**Example**

```bash
bfl::urlencode "foo bar"
```

## bfl::verify_arg_count

Verifies the number of arguments received against expected values.

**Parameters**

int $actual_arg_count
>Actual number of arguments received.

int $expected_arg_count_min
>Minimum number of arguments expected.

int $expected_arg_count_max
>Maximum number of arguments expected.

**Example**

```bash
bfl::verify_arg_count "$#" 2 3
```

## bfl::verify_dependencies

Verifies that dependencies are installed.

**Parameter**

array $apps
>One dimensional array of applications, executables, or commands.

**Example**

```bash
bfl::verify_dependencies "curl" "wget" "git"
```

## bfl::warn

Prints a warning message to stderr.

**Parameter**

string $msg (optional)
>The message.

**Example**

```bash
bfl::warn "The foo is bar."
```

---
*Last updated: 2020-06-20T15:38:20-04:00.*
