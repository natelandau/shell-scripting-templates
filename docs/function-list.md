# Bash Function Library

## Function List

     ---
* [bfl::declare_global_display_constants](#bfl_declare_global_display_constants)
* [bfl::die](#bfl_die)
* [bfl::echo_args](#bfl_echo_args)
* [bfl::find_nearest_integer](#bfl_find_nearest_integer)
* [bfl::generate_password](#bfl_generate_password)
* [bfl::get_file_directory](#bfl_get_file_directory)
* [bfl::get_file_extension](#bfl_get_file_extension)
* [bfl::get_file_name](#bfl_get_file_name)
* [bfl::get_file_name_without_extension](#bfl_get_file_name_without_extension)
* [bfl::get_file_path](#bfl_get_file_path)
* [bfl::implode](#bfl_implode)
* [bfl::is_empty](#bfl_is_empty)
* [bfl::is_integer](#bfl_is_integer)
* [bfl::repeat](#bfl_repeat)
* [bfl::send_mail_msg](#bfl_send_mail_msg)
* [bfl::send_sms_msg](#bfl_send_sms_msg)
* [bfl::time_convert_s_to_hhmmss](#bfl_time_convert_s_to_hhmmss)
* [bfl::transliterate](#bfl_transliterate)
* [bfl::trim](#bfl_trim)
* [bfl::urlencode](#bfl_urlencode)
* [bfl::verify_arg_count](#bfl_verify_arg_count)
* [bfl::verify_dependencies](#bfl_verify_dependencies)
* [bfl::warn](#bfl_warn)
<a id="bfl_declare_global_display_constants"></a>

## bfl::declare_global_display_constants

Declares global display constants.

#### Returns

string $black (global)

string $black_bold (global)

string $black_faint (global)

string $black_underline (global)

string $black_blink (global)

string $black_reverse (global)

string $red (global)

string $red_bold (global)

string $red_faint (global)

string $red_underline (global)

string $red_blink (global)

string $red_reverse (global)

string $green (global)

string $green_bold (global)

string $green_faint (global)

string $green_underline (global)

string $green_blink (global)

string $green_reverse (global)

string $yellow (global)

string $yellow_bold (global)

string $yellow_faint (global)

string $yellow_underline (global)

string $yellow_blink (global)

string $yellow_reverse (global)

string $blue (global)

string $blue_bold (global)

string $blue_faint (global)

string $blue_underline (global)

string $blue_blink (global)

string $blue_reverse (global)

string $magenta (global)

string $magenta_bold (global)

string $magenta_faint (global)

string $magenta_underline (global)

string $magenta_blink (global)

string $magenta_reverse (global)

string $cyan (global)

string $cyan_bold (global)

string $cyan_faint (global)

string $cyan_underline (global)

string $cyan_blink (global)

string $cyan_reverse (global)

string $white (global)

string $white_bold (global)

string $white_faint (global)

string $white_underline (global)

string $white_blink (global)

string $white_reverse (global)
>

#### Example

```bash
bfl::declare_global_display_constants
```

<a id="bfl_die"></a>

## bfl::die

Prints error message to stderr and exits with status code 1.

#### Parameter

string $msg (optional)
>The error message.

#### Example

```bash
bfl::error "Error: the foo is bar."
```

<a id="bfl_echo_args"></a>

## bfl::echo_args

Echoes the arguments passed to this function. This is a debugging tool.

#### Parameter

array $parameters
>One dimensional array of arguments passed to this function.

#### Example

```bash
bfl::echo_args "foo" "bar" "baz"
```

<a id="bfl_find_nearest_integer"></a>

## bfl::find_nearest_integer

Finds the nearest integer to a target integer from a list of integers.

#### Parameters

string $target
>The target integer.

string $list
>A list of integers.

#### Return

string $nearest
>Integer in list that is nearest to the target.

#### Example

```bash
bfl::find_nearest_integer "4" "0 3 6 9 12"
```

<a id="bfl_generate_password"></a>

## bfl::generate_password

Generates a random password.

#### Parameter

integer $password_length
>The length of the desired password.

#### Return

string $password
>A random password

#### Example

```bash
bfl::generate_password "16"
```

<a id="bfl_get_file_directory"></a>

## bfl::get_file_directory

Gets the canonical path to the directory in which a file resides.

#### Parameter

string $path
>A relative path, absolute path, or symlink.

#### Return

string $canonical_directory_path
>The canonical path to the directory in which a file resides.

#### Example

```bash
bfl::get_file_directory "./foo/bar.txt"
```

<a id="bfl_get_file_extension"></a>

## bfl::get_file_extension

Gets the file extension.

#### Parameter

string $path
>A relative path, absolute path, or symlink.

#### Return

string $file_extension
>The file extension, excluding the preceding period.

#### Example

```bash
bfl::get_file_extension "./foo/bar.txt"
```

<a id="bfl_get_file_name"></a>

## bfl::get_file_name

Gets the file name, including extension.

#### Parameter

string $path
>A relative path, absolute path, or symlink.

#### Return

string $file_name
>The file name, including extension.

#### Example

```bash
bfl::get_file_name "./foo/bar.text"
```

<a id="bfl_get_file_name_without_extension"></a>

## bfl::get_file_name_without_extension

Gets the file name, excluding extension.

#### Parameter

string $path
>A relative path, absolute path, or symlink.

#### Return

string $file_name_without_extension
>The file name, excluding extension.

#### Example

```bash
bfl::get_file_name_without_extension "./foo/bar.txt"
```

<a id="bfl_get_file_path"></a>

## bfl::get_file_path

Gets the canonical path to a file.

#### Parameter

string $path
>A relative path, absolute path, or symlink.

#### Return

string $canonical_file_path
>The canonical path to the file.

#### Example

```bash
bfl::get_file_path "./foo/bar.text"
```

<a id="bfl_implode"></a>

## bfl::implode

Combines multiple strings into a single string, separated by another string.

#### Parameters

string $glue
>The character or characters that will be used to glue the strings together.

array $piece
>One dimensional array of strings to be combined.

#### Return

string $imploded_string
>Example: "This is,a,test."

#### Example

```bash
bfl::implode "," "foo" "bar" "baz"
```

<a id="bfl_is_empty"></a>

## bfl::is_empty

Determines if the argument is empty.

#### Parameter

string $argument
>The value to be tested.

#### Example

```bash
bfl::is_empty "foo"
```

<a id="bfl_is_integer"></a>

## bfl::is_integer

Determines if the argument is an integer.

#### Parameter

string $value_to_test
>The value to be tested.

#### Example

```bash
bfl::is_integer "8675309"
```

<a id="bfl_repeat"></a>

## bfl::repeat

Repeats a string.

#### Parameters

string $input
>The string to be repeated.

int $multiplier
>Number of times the string will be repeated.

#### Return

string $result
>The repeated string.

#### Example

```bash
bfl::repeat "=" "10"
```

<a id="bfl_send_mail_msg"></a>

## bfl::send_mail_msg

Sends an email message via sendmail.

#### Parameters

string $to
>Message recipient or recipients.

string $from
>Message sender.

string $envelope_from
>Envelope sender address.

string $subject
>Message subject.

string $body (optional)
>Message body.

#### Example

```bash
bfl::send_mail_msg "a@b.com" "x@y.com" "x@y.com" "Test" "Hello world."
```

<a id="bfl_send_sms_msg"></a>

## bfl::send_sms_msg

Sends an SMS message via Amazon Simple Notification Service (SNS).

#### Parameters

string $phone_number
>Recipient's phone number, including country code.

string $message
>Example: "This is line one.\nThis is line two.\n"

#### Example

```bash
bfl::send_sms_msg "+12065550100" "Line one.\nLine two.\n"
```

<a id="bfl_time_convert_s_to_hhmmss"></a>

## bfl::time_convert_s_to_hhmmss

Converts seconds to the hh:mm:ss format.

#### Parameter

integer $seconds
>The number of seconds to convert.

#### Return

string $hhmmss
>The number of seconds in hh:mm:ss format.

#### Example

```bash
bfl::time_convert_s_to_hhmmss "3661"
```

<a id="bfl_transliterate"></a>

## bfl::transliterate

Transliterates a string.

#### Parameter

string $input
>The string to transliterate.

#### Return

string $output
>The transliterated string.

#### Example

```bash
bfl::transliterate "_Olé Über! "
```

<a id="bfl_trim"></a>

## bfl::trim

Removes leading and trailing whitespace, including blank lines, from string.

#### Parameter

string $input
>The string to be trimmed.

#### Return

string $output
>The trimmed string.

#### Example

```bash
bfl::trim " foo "
```

<a id="bfl_urlencode"></a>

## bfl::urlencode

Percent-encodes a URL per https://tools.ietf.org/html/rfc3986#section-2.1.

#### Parameter

string $str
>The string to be encoded.

#### Return

string $str_encoded
>The encoded string.

#### Example

```bash
bfl::urlencode "foo bar"
```

<a id="bfl_verify_arg_count"></a>

## bfl::verify_arg_count

Verifies the number of arguments received against expected values.

#### Parameters

integer $actual_arg_count
>Actual number of arguments received.

integer $expected_arg_count_min
>Minimum number of arguments expected.

integer $expected_arg_count_max
>Maximum number of arguments expected.

#### Example

```bash
bfl::verify_arg_count "$#" 2 3
```

<a id="bfl_verify_dependencies"></a>

## bfl::verify_dependencies

Verifies that dependencies are installed.

#### Parameter

array $apps
>One dimensional array of applications, executables, or commands.

#### Example

```bash
bfl::verify_dependencies "curl" "wget" "git"
```

<a id="bfl_warn"></a>

## bfl::warn

Prints warning message to stdout.

#### Parameter

string $msg (optional)
>The warning message.

#### Example

```bash
bfl::warn "Warning: the foo is bar."
```



     ---
*Last updated: 2019-08-17T16:52:32-04:00.*