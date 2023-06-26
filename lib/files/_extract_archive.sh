#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::extract_archive().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Extracts a compressed file.
#
# @param String $file
#   Input file.
#
# @option String  'v'
#   Input 'v' to show verbose output.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::extract_archive "file.zip"
#------------------------------------------------------------------------------
bfl::extract_archive() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local _vv=""
  [[ ${2:-} == "v" ]] && _vv="v"

  case "$1" in
      *.tar.bz2 | *.tbz | *.tbz2) tar "x${_vv}jf" "$1" ;;
      *.tar.gz | *.tgz)           tar "x${_vv}zf" "$1" ;;
      *.tar.xz) xz --decompress "$1"
                set -- "$@" "${1:0:-3}"
                ;;
      *.tar.Z)  uncompress "$1"
                set -- "$@" "${1:0:-2}"
                ;;
      *.tar)    tar "x${_vv}f" "$1" ;;
      *.bz2)    bunzip2 "$1" ;;
      *.deb)    dpkg-deb -x"${_vv}" "$1" "${1:0:-4}" ;;
      *.pax.gz) gunzip "$1"
                set -- "$@" "${1:0:-3}"
                ;;
      *.gz)     gunzip "$1" ;;
      *.pax)    pax -r -f "$1" ;;
      *.pkg)    pkgutil --expand "$1" "${1:0:-4}" ;;
      *.rar)    unrar x "$1" ;;
      *.rpm)    rpm2cpio "$1" | cpio -idm"${_vv}" ;;
      *.txz)    mv "$1" "${1:0:-4}.tar.xz"
                set -- "$@" "${1:0:-4}.tar.xz"
                ;;
      *.xz)     xz --decompress "$1" ;;
      *.zip | *.war | *.jar) unzip "$1" ;;
      *.Z)      uncompress "$1" ;;
      *.7z)     7za x "$1" ;;
      *)  bfl::writelog_fail "${FUNCNAME[0]}: archive format is not recognized!"
          return 1 ;;
  esac

  return 0
  }
