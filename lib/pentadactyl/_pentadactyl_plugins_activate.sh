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
# Defines function: bfl::pentadactyl_plugins_activate().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ................................
#
# @example
#   bfl::pentadactyl_plugins_activate
#------------------------------------------------------------------------------
bfl::pentadactyl_plugins_activate() {
  local ENT
  cd ${HOME}/.pentadactyl/plugins/load/ || return 1

  for ENT in $( find ../../plugins_* -type f -a -name "*.js" -a -print ); do
      {   printf "\n### %s ###\n\n" "${ENT#*/plugins_}"
          read -p "? " -n1
          echo
          [[ "${REPLY}" != [yY] ]] || ln -vnfs "${ENT}"
      } 1>&2
  done
  }
