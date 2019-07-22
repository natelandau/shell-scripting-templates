# Bash Function Library - Documentation

## Table of Contents

* [lib::declare_global_display_constants](#lib_declare_global_display_constants)
* [lib::echo_args](#lib_echo_args)
* [lib::err](#lib_err)
* [lib::find_nearest_integer](#lib_find_nearest_integer)
* [lib::generate_password](#lib_generate_password)
* [lib::get_file_directory](#lib_get_file_directory)
* [lib::get_file_extension](#lib_get_file_extension)
* [lib::get_file_name](#lib_get_file_name)
* [lib::get_file_name_without_extension](#lib_get_file_name_without_extension)
* [lib::get_file_path](#lib_get_file_path)
* [lib::implode](#lib_implode)
* [lib::is_empty](#lib_is_empty)
* [lib::is_integer](#lib_is_integer)
* [lib::send_mail_msg](#lib_send_mail_msg)
* [lib::send_sms_msg](#lib_send_sms_msg)
* [lib::str_repeat](#lib_str_repeat)
* [lib::transliterate](#lib_transliterate)
* [lib::trim](#lib_trim)
* [lib::validate_arg_count](#lib_validate_arg_count)
* [lib::verify_dependencies](#lib_verify_dependencies)

<a id="lib_declare_global_display_constants"></a>

## lib::declare_global_display_constants

Declares global display constants.

**@return** global string $red  
**@return** global string $light_red  
**@return** global string $green  
**@return** global string $light_green  
**@return** global string $blue  
**@return** global string $light_blue  
**@return** global string $purple  
**@return** global string $light_purple  
**@return** global string $cyan  
**@return** global string $light_cyan  
**@return** global string $brown  
**@return** global string $yellow  
**@return** global string $black  
**@return** global string $dark_gray  
**@return** global string $light_gray  
**@return** global string $white  
**@return** global string $blinking  
**@return** global string $bold  
**@return** global string $reverse_video  
**@return** global string $underline  
**@return** global string $reset  

<a id="lib_echo_args"></a>

## lib::echo_args

Echoes the arguments passed to this function. This is a debugging tool.

**@param** array $parameters  
  One dimensional array of arguments passed to this function.  

<a id="lib_err"></a>

## lib::err

Prints message to stderr.

**@param** string $message  
  Message to be printed.  

<a id="lib_find_nearest_integer"></a>

## lib::find_nearest_integer

Finds the nearest integer to a target integer from a list of integers.

**@param** string $target  
  The target integer.  
**@param** string $list  
  List of integers.  

**@return** string $nearest  
  Integer in list that is nearest to the target.  

<a id="lib_generate_password"></a>

## lib::generate_password

Generates a random password.

**@param** integer $password_length  
  The length of the desired password.  

**@return** string $password  
  A random password  

<a id="lib_get_file_directory"></a>

## lib::get_file_directory

Gets the canonical path to the directory in which a file resides.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $canonical_directory_path  
  The canonical path to the directory in which a file resides.  

<a id="lib_get_file_extension"></a>

## lib::get_file_extension

Gets the file extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_extension  
  The file extension, excluding the preceding period.  

<a id="lib_get_file_name"></a>

## lib::get_file_name

Gets the file name, including extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_name  
  The file name, including extension.  

<a id="lib_get_file_name_without_extension"></a>

## lib::get_file_name_without_extension

Gets the file name, excluding extension.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $file_name_without_extension  
  The file name, excluding extension.  

<a id="lib_get_file_path"></a>

## lib::get_file_path

Gets the canonical path to a file.

**@param** string $path  
  A relative path, absolute path, or symlink.  

**@return** string $canonical_file_path  
  The canonical path to the file.  

<a id="lib_implode"></a>

## lib::implode

Combines multiple strings into a single string, separated by another string.

**@param** string $glue  
  The character or characters that will be used to glue the strings together.  
**@param** array $pieces  
  One dimensional array of strings to be combined.  

**@return** string $imploded_string  
  Example: "This is,a,test."  

<a id="lib_is_empty"></a>

## lib::is_empty

Determines if the supplied argument is an empty string.

**@param** string $value_to_test  
  The value to be tested.  

<a id="lib_is_integer"></a>

## lib::is_integer

Determines if the supplied argument is an integer.

**@param** string $value_to_test  
  The value to be tested.  

<a id="lib_send_mail_msg"></a>

## lib::send_mail_msg

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

<a id="lib_send_sms_msg"></a>

## lib::send_sms_msg

Sends an SMS message via Amazon Simple Notification Service (SNS).

**@param** string $phone_number  
  Recipient's phone number, including country code.  
**@param** string $message  
  The message.  

<a id="lib_str_repeat"></a>

## lib::str_repeat

Repeats a string.

**@param** string $input  
  The string to be repeated.  
**@param** int $multiplier  
  Number of times the string will be repeated.  

**@return** string $result  
  The repeated string.  

<a id="lib_transliterate"></a>

## lib::transliterate

Transliterates a string.

**@param** string $input  
  String to lib::transliterate (example: "_Foo Bar@  BAz").  

**@return** string $output  
  Transliterated string (example: "foo-bar-baz")  

<a id="lib_trim"></a>

## lib::trim

Removes leading and trailing whitespace from a string.

**@param** string $input  
  The string to be trimmed.  

**@return** string $output  
  The trimmed string.  

<a id="lib_validate_arg_count"></a>

## lib::validate_arg_count

Validates the number of arguments received against expected values.

**@param** integer $actual_arg_count  
  Actual number of arguments received.  
**@param** integer $expected_arg_count_min  
  Minimum number of arguments expected.  
**@param** integer $expected_arg_count_max  
  Maximum number of arguments expected.  

<a id="lib_verify_dependencies"></a>

## lib::verify_dependencies

Verifies that dependencies are installed.

**@param** array $apps  
  One dimensional array of applications, executables, or commands.  

---
*Last updated: 2019-07-21T21:59:56-04:00.*
