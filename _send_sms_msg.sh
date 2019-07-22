#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::send_sms_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sends an SMS message via Amazon Simple Notification Service (SNS).
#
# @param string $phone_number
#   Recipient's phone number, including country code.
#   Example: +12065550100
# @param string $message
#   The message.
#   Example: "This is line one.\nThis is line two.\nThis is line three."
#------------------------------------------------------------------------------
lib::send_sms_msg() {
  lib::verify_dependencies "aws" || return 1
  lib::validate_arg_count "$#" 2 2 || return 1

  declare -r phone_number="$1"
  declare -r message="$2"
  declare -r phone_number_regex="^\\+[0-9]{6,}$"
  declare err_msg
  declare interpreted_message

   if lib::is_empty "${phone_number}"; then
    lib::err "Error: the recipient's phone number was not specified."
    return 1
  fi

  if lib::is_empty "${message}"; then
    lib::err "Error: the message was not specified."
    return 1
  fi

  # Make sure phone number is properly formatted.
  if [[ ! "${phone_number}" =~ ${phone_number_regex} ]]; then
    err_msg=$(cat<<EOT
Error: the recipient's phone number is improperly formatted. Expected a
plus sign followed by six or more digits, received "${phone_number}."
EOT
    )
    lib::err "${err_msg}"
    return 1
  fi

  # Backslash escapes such as \n (newline) in the message string must be
  # interpreted before sending the message.
  interpreted_message=$(echo -e "${message}")

  # Send the message.
  aws sns publish --phone-number "${phone_number}" --message "${interpreted_message}" || return 1
}
