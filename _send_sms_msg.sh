#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::send_sms_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sends an SMS message via Amazon Simple Notification Service (SNS).
#
# @param string $phone_number
#   Recipient's phone number, including country code.
# @param string $message
#   Example: "This is line one.\\nThis is line two.\\n"
#
# @example
#   bfl::send_sms_msg "+12065550100" "Line 1.\\nLine 2."
#------------------------------------------------------------------------------
bfl::send_sms_msg() {
  bfl::verify_arg_count "$#" 2 2 || exit 1
  bfl::verify_dependencies "aws"

  declare -r phone_number="$1"
  declare -r message="$2"
  declare -r phone_number_regex="^\\+[0-9]{6,}$"
  declare error_msg

   if bfl::is_empty "${phone_number}"; then
    bfl::die "The recipient's phone number was not specified."
  fi

  if bfl::is_empty "${message}"; then
    bfl::die "The message was not specified."
  fi

  # Make sure phone number is properly formatted.
  if [[ ! "${phone_number}" =~ ${phone_number_regex} ]]; then
    error_msg="The recipient's phone number is improperly formatted.\\n"
    error_msg+="Expected a plus sign followed by six or more digits, "
    error_msg+="received ${phone_number}."
    bfl::die "${error_msg}"
  fi

  # Backslash escapes such as \n (newline) in the message string must be
  # interpreted before sending the message.
  interpreted_message=$(printf "%b" "${message}") || bfl::die

  # Send the message.
  aws sns publish --phone-number "${phone_number}" \
                  --message "${interpreted_message}" || bfl::die
}
