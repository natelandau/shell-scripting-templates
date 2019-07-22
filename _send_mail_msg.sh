#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::send_mail_msg().
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
lib::send_mail_msg() {
  lib::verify_dependencies "sendmail" || return 1
  lib::validate_arg_count "$#" 4 5 || return 1

  declare -r to="$1"
  declare -r from="$2"
  declare -r envelope_from="$3"
  declare -r subject="$4"
  declare -r body="${5:-}"
  declare interpreted_body
  declare message

  if lib::is_empty "${to}"; then
    lib::err "Error: the message recipient was not specified."
    return 1
  fi

  if lib::is_empty "${from}"; then
    lib::err "Error: the message sender was not specified."
    return 1
  fi

  if lib::is_empty "${envelope_from}"; then
    lib::err "Error: the envelope sender address was not specified."
    return 1
  fi

  if lib::is_empty "${subject}"; then
    lib::err "Error: the message subject was not specified."
    return 1
  fi

  # Backslash escapes such as \n (newline) in the message body must be
  # interpreted before sending the message.
  interpreted_body=$(echo -e "${body}")

  # Format the message.
  message=$(printf "To: %s\\nFrom: %s\\nSubject: %s\\n\\n%s" \
    "${to}" \
    "${from}" \
    "${subject}" \
    "${interpreted_body}")

  # Send the message.
  echo "$message" | sendmail -f "$envelope_from" "$to" || return 1
}
