#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://github.com/jmooring/bash-function-library.git -----------
#
# Library of email functions
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::send_mail_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sends an email message via sendmail.
#
# @param String $to
#   Message recipient or recipients.
#   Examples:
#   - foo@example.com
#   - foo@example.com, bar@example.com
#   - Foo <foo@example.com>
#   - Foo <foo@example.com>, Bar <bar@example.com>
# @param String $from
#   Message sender.
#   Examples:
#   - foo@example.
#   - Foo <foo@example.com>
# @param String $envelope_from
#   Envelope sender address.
#   Example: foo@example.com
# @param String $subject
#   Message subject.
# @param String $body
#   Message body.
#   Example: "This is line one.\\nThis is line two.\\n"
#
# @example
#   bfl::send_mail_msg "a@b.com" "x@y.com" "x@y.com" "Test" "Line 1.\\nLine 2."
#------------------------------------------------------------------------------
bfl::send_mail_msg() {
  bfl::verify_arg_count "$#" 5 5   || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 5";            return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_SENDMAIL} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sendmail' not found."; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  # Verify arguments
  bfl::is_empty "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: The message recipient was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_empty "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: The message sender was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_empty "$3" && { bfl::writelog_fail "${FUNCNAME[0]}: The envelope sender address was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_empty "$4" && { bfl::writelog_fail "${FUNCNAME[0]}: The message subject was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_empty "$5" && { bfl::writelog_fail "${FUNCNAME[0]}: The message body was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  declare message # Format the message.                       to from subject body
  message=$(printf "To: %s\\nFrom: %s\\nSubject: %s\\n\\n%b" "$1" "$2" "$4" "$5") || { bfl::writelog_fail "${FUNCNAME[0]}: Cannot generate message."; return 1; }

  # Send the message   envelope_from  to
  echo "$message" | sendmail -f "$3" "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: Cannot send email from $3 to $1."; return 1; }
  }
