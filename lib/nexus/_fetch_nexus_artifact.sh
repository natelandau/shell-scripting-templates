#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the software repository manager Sonatype Nexus
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::fetch_nexus_artifact().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Downloads an artifact from Nexus.
#
# @param String   USER
#
# @param String   PASSWORD
#
# @param String   SERVER
#
# @param String   REPOSITORY
#
# @param String   GROUP
#
# @param String   ARTIFACT
#
# @param String   VERSION
#
# @param String   EXTENSION
#
# @param String   TARGET
#
# @example
#   bfl::fetch_nexus_artifact ....
#------------------------------------------------------------------------------
bfl::fetch_nexus_artifact() {
  bfl::verify_arg_count "$#" 9 9 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 9"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r USER="${1:-}"
  local -r PASSWORD="${2:-}"
  local -r SERVER="${3:-}"
  local -r REPOSITORY="${4:-}"
  local -r GROUP="${5:-}"
  local -r ARTIFACT="${6:-}"
  local -r VERSION="${7:-}"
  local -r EXTENSION="${8:-}"
  local target="${9:-$ARTIFACT-$VERSION.$EXTENSION}"

  [[ -d "$target" ]] && target="$target/$ARTIFACT-$VERSION.$EXTENSION"

  local -r URL="$(bfl::get_nexus_artifact_url $SERVER $REPOSITORY $GROUP $ARTIFACT $VERSION $EXTENSION)"
  wget --quiet --no-check-certificate --user="$USER" --password="$PASSWORD" "$URL" --output-document="$target"
  }
