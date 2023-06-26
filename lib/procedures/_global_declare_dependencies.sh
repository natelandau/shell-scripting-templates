#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of internal library functions
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::global_declare_dependencies().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Declare whole list dependencies
#
# @example
#   bfl::global_declare_dependencies
#------------------------------------------------------------------------------
bfl::global_declare_dependencies() {
#  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1..1999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

# grep -rnw lib/* -e 'bfl::verify_dependencies' | sed -n '/^[^:]*_verify_dependencies.sh:/!p' | sed 's/#.*$//' | sed 's/#.*$//' | sed 's/^.*bfl::verify_dependencies \([^|]*\) ||.*$/\1/' | sed 's/^.*bfl::verify_dependencies \([^\&]*\) \&\&.*$/\1/' | sed 's/^"\(.*\)"[ ]*$/\1/' | sort | uniq
  local f h
  for f in aws brew compgen curl dpkg find git grep iconv ifconfig javaws jq ldapsearch opensnoop openssl pbcopy pbpaste perl proxychains4 pwgen python ruby screencapture sed sendmail shuf speedtest-cli sqlite3 ssh tput uname vcsh; do
      h="${f/-/_}"; h="_BFL_HAS_${h^^}"
      [[ ${!h} -eq 1 ]] && continue

      bfl::verify_dependencies "$f" && declare -gr ${h}=1 # || declare -gr ${h}=0
  done

  return 0
  }
