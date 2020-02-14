#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::send_mail_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sends an email message via sendmail.
#
# @param string $to
#   Message recipient or recipients.
#   Examples:
#   - foo@example.com
#   - foo@example.com, bar@example.com
#   - Foo <foo@example.com>
#   - Foo <foo@example.com>, Bar <bar@example.com>
# @param string $from
#   Message sender.
#   Examples:
#   - foo@example.
#   - Foo <foo@example.com>
# @param string $envelope_from
#   Envelope sender address.
#   Example: foo@example.com
# @param string $subject
#   Message subject.
# @param string $body
#   Message body.
#   Example: "This is line one.\\nThis is line two.\\n"
#
# @example
#   bfl::send_mail_msg "a@b.com" "x@y.com" "x@y.com" "Test" "Line 1.\\nLine 2."
#------------------------------------------------------------------------------
bfl::send_mail_msg() {
  bfl::verify_arg_count "$#" 5 5 || exit 1
  bfl::verify_dependencies "sendmail"

  declare -r to="$1"
  declare -r from="$2"
  declare -r envelope_from="$3"
  declare -r subject="$4"
  declare -r body="$5"
  declare message

  bfl::is_empty "${to}" \
    && bfl::die "The message recipient was not specified."
  bfl::is_empty "${from}" \
    && bfl::die "The message sender was not specified."
  bfl::is_empty "${envelope_from}" \
    && bfl::die "The envelope sender address was not specified."
  bfl::is_empty "${subject}" \
    && bfl::die "The message subject was not specified."
  bfl::is_empty "${body}" \
    && bfl::die "The message body was not specified."

  # Format the message.
  message=$(printf "To: %s\\nFrom: %s\\nSubject: %s\\n\\n%b" \
    "${to}" \
    "${from}" \
    "${subject}" \
    "${body}") || bfl::die

  # Send the message.
  echo "$message" | sendmail -f "$envelope_from" "$to" || bfl::die
}
