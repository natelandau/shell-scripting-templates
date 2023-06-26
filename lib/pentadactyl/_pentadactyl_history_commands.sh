#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to pentadactyl
#
# @author  A. River
#
# @file
# Defines function: bfl::pentadactyl_history_commands().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ................................
#
# @example
#   bfl::pentadactyl_history_commands
#------------------------------------------------------------------------------
bfl::pentadactyl_history_commands() {
  eval "$( bfl::pentadactyl_common_source )"

  declare {tmp,ent,cmd,prv,val,dts}=
  tmp="${TMPDIR:-/tmp}/.pentadactyl.history.tmp"
  find "${tmp}" -mmin +1 -ls -exec rm -f "{}" \; 1>&2 2>/dev/null
  [[ -f "${tmp}" ]] || {
      for ent in ~/.pentadactyl/info/*/command-history; do
          json2path < "${ent}" >> "${tmp}"
      done
      }

  while read -r ent; do
      [[ "${ent}" =~ ^/command\[([0-9]+)\]/(privateData|value|timestamp)=(.*) ]] || continue
      [[ "${BASH_REMATCH[1]}" == "${cmd}" ]] || { cmd="${BASH_REMATCH[1]}"; prv=; val=; dts=; }
      case "${BASH_REMATCH[2]}" in
          privateData ) prv="${BASH_REMATCH[3]}";;
          value )       val="${BASH_REMATCH[3]%\"}"
                        val="${val#\"}" ;;
          timestamp )   dts="${BASH_REMATCH[3]}";;
      esac
      [ -z "${prv}" -o -z "${val}" -o -z "${dts}" ] || printf "%s\t%s\t%s\n" "${dts}" "${prv}" "${val}"
  done < "${tmp}"
  }
