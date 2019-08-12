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
# @param string $body (optional)
#   Message body.
#------------------------------------------------------------------------------
bfl::send_mail_msg() {
  bfl::verify_arg_count "$#" 4 5 || exit 1
  bfl::verify_dependencies "sendmail"

  declare -r to="$1"
  declare -r from="$2"
  declare -r envelope_from="$3"
  declare -r subject="$4"
  declare -r body="${5:-}"
  declare message

  if bfl::is_empty "${to}"; then
    bfl::die "Error: the message recipient was not specified."
  fi

  if bfl::is_empty "${from}"; then
    bfl::die "Error: the message sender was not specified."
  fi

  if bfl::is_empty "${envelope_from}"; then
    bfl::die "Error: the envelope sender address was not specified."
  fi

  if bfl::is_empty "${subject}"; then
    bfl::die "Error: the message subject was not specified."
  fi

  # Format the message.
  message=$(printf "To: %s\\nFrom: %s\\nSubject: %s\\n\\n%b" \
    "${to}" \
    "${from}" \
    "${subject}" \
    "${body}") || bfl::die

  # Send the message.
  echo "$message" | sendmail -f "$envelope_from" "$to" || bfl::die
}
