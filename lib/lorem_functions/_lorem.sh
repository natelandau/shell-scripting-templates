#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://github.com/jmooring/bash-function-library.git -----------
# @file
# Defines function: bfl::lorem().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Randomly extracts one or more sequential paragraphs from a given resource.
#
# The resources are located in the resources/lorem directory. Each resource
# contains one paragraph per line. The resources were created from books
# downloaded from Project Gutenberg (https://www.gutenberg.org), and then
# edited to remove:
#
#   1) Front matter
#   2) Back matter
#   3) Footnotes
#   4) Cross references
#   5) Captions
#   6) Any paragraph less than or equal to 200 characters.
#
# @param int $paragraphs (optional)
#   The number of paragraphs to extract (default: 1).
# @param string $resource (optional)
#   The resource from which to extract the paragraphs (default: muir).
#   Valid resources:
#   - burroughs (The Breath of Life by John Burroughs)
#   - darwin (The Origin of Species by Charles Darwin)
#   - mills (The Rocky Mountain Wonderland by Enos Mills)
#   - muir (Our National Parks by John Muir)
#   - virgil (The Aeneid by Virgil)
#
# @return string $text
#   The extracted paragraphs.
#
# @example
#   bfl::lorem
# @example
#   bfl::lorem 2
# @example
#   bfl::lorem 3 burroughs
# @example
#   bfl::lorem 3 darwin
# @example
#   bfl::lorem 3 mills
# @example
#   bfl::lorem 3 muir
# @example
#   bfl::lorem 3 virgil
#------------------------------------------------------------------------------
bfl::lorem() {
  bfl::verify_arg_count "$#" 0 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0..2]"; return 1; } # Verify argument count.
  bfl::verify_dependencies "shuf" || { bfl::writelog_fail "${FUNCNAME[0]}: dependency shuf not found" ; return 1; } # Verify dependencies.

  # Declare positional arguments (readonly, sorted by position).
  declare -r paragraphs="${1:-1}"
  declare -r resource="${2:-muir}"

  # Verify argument values.
  bfl::is_positive_integer "${paragraphs}" || { bfl::writelog_fail "${FUNCNAME[0]}: paragraph count must be a positive integer."; return 1; }

  # Declare return value.
  declare text

  # Declare all other variables (sorted by name).
  declare first_paragraph_number
  declare last_paragraph_number
  declare maximum_first_paragraph_number
  declare msg
  declare resource_directory
  declare resource_file
  declare resource_paragraph_count

  # Set the resource directory path.
  resource_directory=$(dirname "${BASH_FUNCTION_LIBRARY}")/resources/lorem || { bfl::writelog_fail "${FUNCNAME[0]}: unable to determine resource directory."; return 1; }

  # Select the resource file from which to extract paragraphs.
  case "${resource}" in
    "burroughs" )
      resource_file=${resource_directory}/the-breath-of-life-by-john-burroughs.txt
      ;;
    "darwin" )
      resource_file=${resource_directory}/the-origin-of-species-by-charles-darwin.txt
      ;;
    "mills" )
      resource_file=${resource_directory}/the-rocky-mountain-wonderland-by-enos-mills.txt
      ;;
    "muir" )
      resource_file=${resource_directory}/our-national-parks-by-john-muir.txt
      ;;
    "virgil" )
      resource_file=${resource_directory}/the-aeneid-by-virgil.txt
      ;;
    * )
      bfl::writelog_fail "${FUNCNAME[0]}: unknown resource." && return 1
      ;;
  esac

  # Determine number of paragraphs in the resource file (assumes one per line).
  resource_paragraph_count=$(wc -l < "${resource_file}") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to determine number of paragraphs in source file."; return 1; }

  # Make sure number of requested paragraphs does not exceed maximum.
  if [[ "${paragraphs}" -gt "${resource_paragraph_count}" ]]; then
    msg=$(cat <<EOT
The number of paragraphs requested ($paragraphs) exceeds
the number of paragraphs available (${resource_paragraph_count}) in the specified resource (${resource}).
EOT
    )
    bfl::writelog_fail "${FUNCNAME[0]}: $msg" && return 1
  fi

  # Determine the highest paragraph number from which we can begin extraction.
  maximum_first_paragraph_number=$((resource_paragraph_count - paragraphs + 1))

  # Determine the range of paragraphs to extract.
  first_paragraph_number=$(shuf -i 1-"${maximum_first_paragraph_number}" -n 1) || { bfl::writelog_fail "${FUNCNAME[0]}: unable to generate random paragraph number."; return 1; }
  last_paragraph_number=$((first_paragraph_number + paragraphs - 1))

  # Extract sequential paragraphs.
  text=$(sed -n "${first_paragraph_number}","${last_paragraph_number}"p "${resource_file}") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to extract paragraphs."; return 1; }
  # Add a blank line between each paragraph to create proper markdown.
  text=$(awk '{print $0"\n"}' <<< "$text") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to add additional newline to each paragraph."; return 1; }

  # Print the return value.
  printf "%s" "$text"
  }