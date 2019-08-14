# Bash Function Library

## Function List

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
* [bfl::send_mail_msg](#bfl_send_mail_msg)
* [bfl::send_sms_msg](#bfl_send_sms_msg)
* [bfl::str_repeat](#bfl_str_repeat)
* [bfl::time_convert_s_to_hhmmss](#bfl_time_convert_s_to_hhmmss)
* [bfl::transliterate](#bfl_transliterate)
* [bfl::trim](#bfl_trim)
* [bfl::verify_arg_count](#bfl_verify_arg_count)
* [bfl::verify_dependencies](#bfl_verify_dependencies)
* [bfl::warn](#bfl_warn)

<a id="bfl_declare_global_display_constants"></a>

## bfl::declare_global_display_constants

Declares global display constants.

**@return** string $black (global)  
**@return** string $black_bold (global)  
**@return** string $black_faint (global)  
**@return** string $black_underline (global)  
**@return** string $black_blink (global)  
**@return** string $black_reverse (global)  
**@return** string $red (global)  
**@return** string $red_bold (global)  
**@return** string $red_faint (global)  
**@return** string $red_underline (global)  
**@return** string $red_blink (global)  
**@return** string $red_reverse (global)  
**@return** string $green (global)  
**@return** string $green_bold (global)  
**@return** string $green_faint (global)  
**@return** string $green_underline (global)  
**@return** string $green_blink (global)  
**@return** string $green_reverse (global)  
**@return** string $yellow (global)  
**@return** string $yellow_bold (global)  
**@return** string $yellow_faint (global)  
**@return** string $yellow_underline (global)  
**@return** string $yellow_blink (global)  
**@return** string $yellow_reverse (global)  
**@return** string $blue (global)  
**@return** string $blue_bold (global)  
**@return** string $blue_faint (global)  
**@return** string $blue_underline (global)  
**@return** string $blue_blink (global)  
**@return** string $blue_reverse (global)  
**@return** string $magenta (global)  
**@return** string $magenta_bold (global)  
**@return** string $magenta_faint (global)  
**@return** string $magenta_underline (global)  
**@return** string $magenta_blink (global)  
**@return** string $magenta_reverse (global)  
**@return** string $cyan (global)  
**@return** string $cyan_bold (global)  
**@return** string $cyan_faint (global)  
**@return** string $cyan_underline (global)  
**@return** string $cyan_blink (global)  
**@return** string $cyan_reverse (global)  
**@return** string $white (global)  
**@return** string $white_bold (global)  
**@return** string $white_faint (global)  
**@return** string $white_underline (global)  
**@return** string $white_blink (global)  
**@return** string $white_reverse (global)  

<a id="bfl_die"></a>

## bfl::die

Prints error message to stderr and exits with status code 1.

**@param** string $msg (optional)  
  The error message.  

<a id="bfl_echo_args"></a>

## bfl::echo_args

Echoes the arguments passed to this function. This is a debugging tool.

**@param** array $parameters  
  One dimensional array of arguments passed to this function.  

<a id="bfl_find_nearest_integer"></a>

## bfl::find_nearest_integer

Finds the nearest integer to a target integer from a list of integers.

**@param** string $target  
  The target integer.  
**@param** string $list  
  List of integers.  

**@return** string $nearest  
  Integer in list that is nearest to the target.  

<a id="bfl_generate_password"></a>

## bfl::generate_password

Generates a random password.

**@param** integer $password_length  
  The length of the desired password.  

**@return** string $password  
  A random password  

<a id="bfl_get_file_directory"></a>

## bfl::get_file_directory

Gets the canonical path to the directory in which a file resides.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $canonical_directory_path  
  The canonical path to the directory in which a file resides.  

<a id="bfl_get_file_extension"></a>

## bfl::get_file_extension

Gets the file extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_extension  
  The file extension, excluding the preceding period.  

<a id="bfl_get_file_name"></a>

## bfl::get_file_name

Gets the file name, including extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_name  
  The file name, including extension.  

<a id="bfl_get_file_name_without_extension"></a>

## bfl::get_file_name_without_extension

Gets the file name, excluding extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_name_without_extension  
  The file name, excluding extension.  

<a id="bfl_get_file_path"></a>

## bfl::get_file_path

Gets the canonical path to a file.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $canonical_file_path  
  The canonical path to the file.  

<a id="bfl_implode"></a>

## bfl::implode

Combines multiple strings into a single string, separated by another string.

**@param** string $glue  
  The character or characters that will be used to glue the strings together.  
**@param** array $pieces  
  One dimensional array of strings to be combined.  

**@return** string $imploded_string  
  Example: "This is,a,test."  

<a id="bfl_is_empty"></a>

## bfl::is_empty

Determines if the supplied argument is an empty string.

**@param** string $value_to_test  
  The value to be tested.  

<a id="bfl_is_integer"></a>

## bfl::is_integer

Determines if the supplied argument is an integer.

**@param** string $value_to_test  
  The value to be tested.  

<a id="bfl_send_mail_msg"></a>

## bfl::send_mail_msg

Sends an email message via sendmail.

**@param** string $to  
  Message recipient or recipients.  
**@param** string $from  
  Message sender.  
**@param** string $envelope_from  
  Envelope sender address.  
**@param** string $subject  
  Message subject.  
**@param** string $body (optional)  
  Message body.  

<a id="bfl_send_sms_msg"></a>

## bfl::send_sms_msg

Sends an SMS message via Amazon Simple Notification Service (SNS).

**@param** string $phone_number  
  Recipient's phone number, including country code.  
**@param** string $message  
  The message.  

<a id="bfl_str_repeat"></a>

## bfl::str_repeat

Repeats a string.

**@param** string $input  
  The string to be repeated.  
**@param** int $multiplier  
  Number of times the string will be repeated.  

**@return** string $result  
  The repeated string.  

<a id="bfl_time_convert_s_to_hhmmss"></a>

## bfl::time_convert_s_to_hhmmss

Converts seconds to the hh:mm:ss format.

**@param** integer $seconds  
  The number of seconds to convert.  

**@return** string $hhmmss  
  The number of seconds in hh:mm:ss format.  

<a id="bfl_transliterate"></a>

## bfl::transliterate

Transliterates a string.

**@param** string $input  
  String to bfl::transliterate (example: "_Foo Bar@  BAz").  

**@return** string $output  
  Transliterated string (example: "foo-bar-baz")  

<a id="bfl_trim"></a>

## bfl::trim

Removes leading and trailing whitespace, including blank lines, from string.

**@param** string $input  
  The string to be trimmed.  

**@return** string $output  
  The trimmed string.  

<a id="bfl_verify_arg_count"></a>

## bfl::verify_arg_count

Verifies the number of arguments received against expected values.

**@param** integer $actual_arg_count  
  Actual number of arguments received.  
**@param** integer $expected_arg_count_min  
  Minimum number of arguments expected.  
**@param** integer $expected_arg_count_max  
  Maximum number of arguments expected.  

<a id="bfl_verify_dependencies"></a>

## bfl::verify_dependencies

Verifies that dependencies are installed.

**@param** array $apps  
  One dimensional array of applications, executables, or commands.  

<a id="bfl_warn"></a>

## bfl::warn

Prints warning message to stdout.

**@param** string $msg (optional)  
  The warning message.  

---
*Last updated: 2019-08-15T00:23:33-04:00.*
