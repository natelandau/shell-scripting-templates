#!/usr/bin/env bash

# Library of functions related to bash arrays
#
# @author  Michael Strache


# Checks, if the array contains the element
# Invocation: Array::contains_element ARRAY[@] "${ELEMENT}"
#
# @param Array    ARRAY           The array to test (technically it is a string and the name of the array)
# @param Object   ELEMENT         The element to find
#
# @return Boolean  true if the ARRAY contains ELEMENT, otherwise false
function Array::contains_element() {
  local -r -a ARRAY=( "${!1:-}" ); shift
  local -r ELEMENT="${1:-}"; shift

  for i in "${ARRAY[@]}"; do
    [[ "${i}" == "${ELEMENT}" ]] && return 0
  done

  return 1
}


# Intersects ARRAY_1 and ARRAY_2
# Invocation: Array::intersect ARRAY_1[@] ARRAY_2[@]
#
# @param Array    ARRAY_1           The array to intersect
# @param Array    ARRAY_2           The array to intersect ARRAY_1 with
function Array::intersect() {
  local -r -a ARRAY_1=( "${!1:-}" ); shift
  local -r -a ARRAY_2=( "${!1:-}" ); shift

  #ARRAY_3=($(comm -12 <(printf '%s\n' "${!ARRAY_1}" | LC_ALL=C sort) <(printf '%s\n' "${!ARRAY_2}" | LC_ALL=C sort)))
  #echo ${ARRAY_3[@]}

  return 0
}


# Checks, if ARRAY_1 and ARRAY_2 have one or more elements in common
# Invocation: Array::intersects ARRAY_1[@] ARRAY_2[@]
#
# @param Array    ARRAY_1           The array to test
# @param Array    ARRAY_2           The array to test
#
# @return Boolean  true if the ARRAY_1 and ARRAY_2 have one or more elements in common, otherwise false
function Array::intersects() {
  local -r -a ARRAY_1=( "${!1:-}" ); shift
  local -r -a ARRAY_2=( "${!1:-}" ); shift

  for i in "${ARRAY_1[@]}"; do
    for j in "${ARRAY_2[@]}"; do
      [[ $i == "$j" ]] && return 0
    done
  done

  return 1
}


# Returns a String composed of the array elements joined together with a the specified delimiter.
# Invocation: array_containsElement ARRAY[@] "${DELIMITER}"
#
# @param Array    ARRAY           The array to join together
# @param String   DELIMITER       A sequence of characters that is used to separate each of the elements in the resulting String (default: ",")
#
# @return String  String with all elements of ARRAY joined
function Array::join() {
  ( [ -z ${1+x} ] || [ -z "${1}" ] ) && return 1

  local -r -a ARRAY=( "${!1:-}" ); shift
  local -r DELIMITER="${1:-,}"; shift

  # Concatenate the array elements, using wit DELIMITER as prefix to _every_ element
  result="$( printf "${DELIMITER}%s" "${ARRAY[@]}" )"

  # Remove leading DELIMITER
  result="${result:${#DELIMITER}}"

  echo "${result}"
  return 0
}
