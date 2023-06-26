#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::parse_date().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Takes a string as input and attempts to find a date within it to parse into component parts (day, month, year).
#
# @param String $str
#   A string.
#
# @return Boolean   $value
#   0 / 1   (true / false)
#   If a date was found, the following variables are set:
#       $PARSE_DATE_FOUND      - The date found in the string
#       $PARSE_DATE_YEAR       - The year
#       $PARSE_DATE_MONTH      - The number month
#       $PARSE_DATE_MONTH_NAME - The name of the month
#       $PARSE_DATE_DAY        - The day
#       $PARSE_DATE_HOUR       - The hour (if avail)
#       $PARSE_DATE_MINUTE     - The minute (if avail)
#
# @example
#   if bfl::parse_date "[STRING]"; then ...
#     This function only recognizes dates from the year 2000 to 202
#     Will recognize dates in the following formats separated by '-_ ./'
#         * YYYY-MM-DD      * Month DD, YYYY    * DD Month, YYYY
#         * Month, YYYY     * Month, DD YY      * MM-DD-YYYY
#         * MMDDYYYY        * YYYYMMDD          * DDMMYYYY
#         * YYYYMMDDHHMM    * YYYYMMDDHH        * DD-MM-YYYY
#         * DD MM YY        * MM DD YY
# TODO:   Impelemt the following date formats
#               * MMDDYY          * YYMMDD            * mon-DD-YY
# TODO:  Simplify and reduce the number of regex checks
#------------------------------------------------------------------------------
bfl::parse_date() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  PARSE_DATE_FOUND="" PARSE_DATE_YEAR="" PARSE_DATE_MONTH="" PARSE_DATE_MONTH_NAME=""
  PARSE_DATE_DAY="" PARSE_DATE_HOUR="" PARSE_DATE_MINUTE=""

  #shellcheck disable=SC2064
  trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
  shopt -s nocasematch                  # Use case-insensitive regex

  bfl::writelog_debug "bfl::parse_date() input: $1"

  # YYYY MM DD or YYYY-MM-DD
  if [[ "$1" =~ (.*[^0-9]|^)((20[0-2][0-9])[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2}))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
      PARSE_DATE_YEAR=$((10#${BASH_REMATCH[3]}))
      PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_DAY=$((10#${BASH_REMATCH[5]}))
      bfl::writelog_debug "regex match: YYYY-MM-DD "

  # Month DD, YYYY
  elif [[ "$1" =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[1]:-}"
      PARSE_DATE_MONTH=$(bfl::get_month_number_by_caption "${BASH_REMATCH[2]:-}")
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "${PARSE_DATE_MONTH:-}")"
      PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]:-}))
      PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]:-}))
      bfl::writelog_debug "regex match: Month DD, YYYY"

  # Month DD, YY
  elif [[ "$1" =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+([0-9]{2}))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[1]}"
      PARSE_DATE_MONTH=$(bfl::get_month_number_by_caption "${BASH_REMATCH[2]}")
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
      PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
      bfl::writelog_debug "regex match: Month DD, YY"

  #  DD Month YYYY
  elif [[ "$1" =~ (.*[^0-9]|^)(([0-9]{2})[-\./_ ]+(january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
      PARSE_DATE_DAY=$((10#"${BASH_REMATCH[3]}"))
      PARSE_DATE_MONTH="$(bfl::get_month_number_by_caption "${BASH_REMATCH[4]}")"
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_YEAR=$((10#"${BASH_REMATCH[5]}"))
      bfl::writelog_debug "regex match: DD Month, YYYY"

  # MM-DD-YYYY  or  DD-MM-YYYY
  elif [[ "$1" =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then

      if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
          $((10#${BASH_REMATCH[4]})) -gt 12 &&
          $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
          bfl::writelog_debug "regex match: MM-DD-YYYY"
      elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
          $((10#${BASH_REMATCH[3]})) -lt 32 &&
          $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
          bfl::writelog_debug "regex match: DD-MM-YYYY"
      elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
          $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
          bfl::writelog_debug "regex match: MM-DD-YYYY"
      else
          shopt -u nocasematch
          return 1
      fi

  elif [[ "$1" =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{2}))([^0-9].*|$) ]]; then

      if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
          $((10#${BASH_REMATCH[4]})) -gt 12 &&
          $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
          bfl::writelog_debug "regex match: MM-DD-YYYY"
      elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
          $((10#${BASH_REMATCH[3]})) -lt 32 &&
          $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
          bfl::writelog_debug "regex match: DD-MM-YYYY"
      elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
          $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
          bfl::writelog_debug "regex match: MM-DD-YYYY"
      else
          shopt -u nocasematch
          return 1
      fi

  # Month, YYYY
  elif [[ "$1" =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[1]}"
      PARSE_DATE_DAY="1"
      PARSE_DATE_MONTH="$(bfl::get_month_number_by_caption "${BASH_REMATCH[2]}")"
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
      bfl::writelog_debug "regex match: Month, YYYY"

  # YYYYMMDDHHMM
  elif [[ "$1" =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
      PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
      PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
      PARSE_DATE_HOUR="$((10#${BASH_REMATCH[6]}))"
      PARSE_DATE_MINUTE="$((10#${BASH_REMATCH[7]}))"
      bfl::writelog_debug "regex match: YYYYMMDDHHMM"

  # YYYYMMDDHH            1      2        3         4         5         6
  elif [[ "$1" =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
      PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
      PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
      PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
      PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
      PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
      PARSE_DATE_HOUR="${BASH_REMATCH[6]}"
      PARSE_DATE_MINUTE="00"
      bfl::writelog_debug "regex match: YYYYMMDDHHMM"

  # MMDDYYYY or YYYYMMDD or DDMMYYYY
  #                        1     2    3         4         5         6
  elif [[ "$1" =~ (.*[^0-9]|^)(([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then

      # MMDDYYYY
      if [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
          $((10#${BASH_REMATCH[3]})) -lt 13 &&
          $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_DAY="$((10#${BASH_REMATCH[4]}))"
          PARSE_DATE_MONTH="$((10#${BASH_REMATCH[3]}))"
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_YEAR="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
          bfl::writelog_debug "regex match: MMDDYYYY"
      # DDMMYYYY
      elif [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
          $((10#${BASH_REMATCH[3]})) -gt 12 &&
          $((10#${BASH_REMATCH[3]})) -lt 32 &&
          $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_DAY="$((10#${BASH_REMATCH[3]}))"
          PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_YEAR="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
          bfl::writelog_debug "regex match: DDMMYYYY"
      # YYYYMMDD
      elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
          $((10#${BASH_REMATCH[6]})) -gt 12 &&
          $((10#${BASH_REMATCH[6]})) -lt 32 &&
          $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_DAY="$((10#${BASH_REMATCH[6]}))"
          PARSE_DATE_MONTH="$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
          bfl::writelog_debug "regex match: YYYYMMDD"
      # YYYYDDMM
      elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
          $((10#${BASH_REMATCH[5]})) -gt 12 &&
          $((10#${BASH_REMATCH[5]})) -lt 32 &&
          $((10#${BASH_REMATCH[6]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH="$((10#${BASH_REMATCH[6]}))"
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
          bfl::writelog_debug "regex match: YYYYMMDD"
      # Assume YYYMMDD
      elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
          $((10#${BASH_REMATCH[6]})) -lt 32 &&
          $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
          ; then
          PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
          PARSE_DATE_DAY="$((10#${BASH_REMATCH[6]}))"
          PARSE_DATE_MONTH="$((10#${BASH_REMATCH[5]}))"
          PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
          PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
          bfl::writelog_debug "regex match: YYYYMMDD"
      else
          shopt -u nocasematch
          return 1
      fi

  # # MMDD or DDYY
  # elif [[ "$1" =~ .*(([0-9]{2})([0-9]{2})).* ]]; then
  #     bfl::writelog_debug "regex match: MMDD or DDMM"
  #     PARSE_DATE_FOUND="${BASH_REMATCH[1]}"

  #    # Figure out if days are months or vice versa
  #     if [[ $(( 10#${BASH_REMATCH[2]} )) -gt 12 \
  #        && $(( 10#${BASH_REMATCH[2]} )) -lt 32 \
  #        && $(( 10#${BASH_REMATCH[3]} )) -lt 13 \
  #       ]]; then
  #             PARSE_DATE_DAY="$(( 10#${BASH_REMATCH[2]} ))"
  #             PARSE_DATE_MONTH="$(( 10#${BASH_REMATCH[3]} ))"
  #             PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
  #             PARSE_DATE_YEAR="$(date +%Y )"
  #     elif [[ $(( 10#${BASH_REMATCH[2]} )) -lt 13 \
  #          && $(( 10#${BASH_REMATCH[3]} )) -lt 32 \
  #          ]]; then
  #             PARSE_DATE_DAY="$(( 10#${BASH_REMATCH[3]} ))"
  #             PARSE_DATE_MONTH="$(( 10#${BASH_REMATCH[2]} ))"
  #             PARSE_DATE_MONTH_NAME="$(bfl::get_month_caption_by_number "$PARSE_DATE_MONTH")"
  #             PARSE_DATE_YEAR="$(date +%Y )"
  #     else
  #       shopt -u nocasematch
  #       return 1
  #     fi
  else
      shopt -u nocasematch
      return 1
  fi

  [[ -z ${PARSE_DATE_YEAR:-} ]] && {
      shopt -u nocasematch
      return 1
  }
  ((PARSE_DATE_MONTH >= 1 && PARSE_DATE_MONTH <= 12)) || {
      shopt -u nocasematch
      return 1
  }
  ((PARSE_DATE_DAY >= 1 && PARSE_DATE_DAY <= 31)) || {
      shopt -u nocasematch
      return 1
  }

  bfl::writelog_debug "\$PARSE_DATE_FOUND:     $PARSE_DATE_FOUND"
  bfl::writelog_debug "\$PARSE_DATE_YEAR:      $PARSE_DATE_YEAR"
  bfl::writelog_debug "\$PARSE_DATE_MONTH:     $PARSE_DATE_MONTH"
  bfl::writelog_debug "\$PARSE_DATE_MONTH_NAME: $PARSE_DATE_MONTH_NAME"
  bfl::writelog_debug "\$PARSE_DATE_DAY:       $PARSE_DATE_DAY"
  [[ -z ${PARSE_DATE_HOUR:-} ]] || bfl::writelog_debug "\$PARSE_DATE_HOUR:     $PARSE_DATE_HOUR"
  [[ -z ${PARSE_DATE_MINUTE:-} ]] || bfl::writelog_debug "\$PARSE_DATE_MINUTE:   $PARSE_DATE_MINUTE"

  shopt -u nocasematch

  return 0
  }
