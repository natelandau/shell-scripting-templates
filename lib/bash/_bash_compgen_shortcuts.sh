#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Bash
#
# @author  A. River
#
# @file
# Defines function: bfl::bash_compgen_shortcuts().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   This is just a temporary function that generates the compgen shortcut functions.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::bash_compgen_shortcuts
#------------------------------------------------------------------------------
bfl::bash_compgen_shortcuts() {

  declare {acts,act,cmd,tag}=
  acts=(
      alias:a
      arrayvar:ary
      binding:bnd
      builtin:b
      command:c
      directory:d
      disabled:dis
      enabled:enb
      export:e
      file:fi
      function:f
      group:g
      helptopic:hlp
      hostname:h
      job:j
      keyword:k
      running:r
      service:svc
      setopt:set
      shopt:sho
      signal:sig
      stopped:stp
      user:u
      variable:v
    )

  for act in ${acts[*]}; do
      tag="${act#*:}"
      act="${act%:*}"
      printf -v cmd 'function compg%s () { local i; for i in ${@:+"${@}"}; do compgen -A %s "${i}"; done; }' "${tag}" "${act}"
      eval "${cmd}"
  done

  return 0
  }

#bfl::bash_compgen_shortcuts 1>&2
#unset -f ___tmp
