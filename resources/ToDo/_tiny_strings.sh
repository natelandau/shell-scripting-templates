#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------


_lower_() {
    # USAGE:  text=$(_lower_ <<<"$1")
    #         printf "STRING" | _lower_
    tr '[:upper:]' '[:lower:]'
}


_trim_() {
    # ARGS:   $1 (Required) - String to be trimmed
    # USAGE:  text=$(_trim_ <<<"$1")
    #         printf "%s" "STRING" | _trim_
    awk '{$1=$1;print}'
}

_upper_() {
    # DESC:   Convert a string to uppercase. Used through a pipe or here string.
    # USAGE:  text=$(_upper_ <<<"$1")
    #         printf "%s" "STRING" | _upper_
    tr '[:lower:]' '[:upper:]'
}
