#! /dev/null/bash

function pbc4env ()
{
    printf %s "${PBENV}" | pbcopy
}

function pbp2env ()
{
    unset PBENV
    export PBENV="$( pbpaste )"
    printf "%s=%q\n" PBENV "${PBENV}"
}

function pbp2env_flat ()
{
    unset PBENV
    export PBENV="$( pbpaste | tr -s "[:space:]" " " )"
    printf "%s=%q\n" PBENV "${PBENV}"
}

function pbpaste_flat ()
{
    pbpaste | tr -s '[:space:]' ' '
}
