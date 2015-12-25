#! /dev/null/bash

function grab2file ()
{

    declare file=~/Documents/Screenies/"grab2file_$( date '+%Y-%m-%d_%H-%M-%S' ).png"

    mkdir -p "${file%/*}"

    printf '\n# Interactive capture to ( %s )\n\n' "${file}"

    screencapture -io "${file}"

}

function grab2clip ()
{

    printf '\n'
    screencapture -h 2>&1 | sed '1,/^ *-i /d;/^ *-m /,$d;s/^             //'
    printf '\n'

    screencapture -cio

}
