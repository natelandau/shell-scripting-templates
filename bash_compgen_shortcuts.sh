#! /dev/null/bash

# This is just a temporary function that generates the compgen shortcut functions.
function ___tmp ()
{
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
    for act in ${acts[*]}
    do
        tag="${act#*:}"
        act="${act%:*}"
        printf -v cmd 'function compg%s () { declare I; for I in ${@:+"${@}"}; do compgen -A %s "${I}"; done; }' "${tag}" "${act}"
        eval "${cmd}"
    done
}
___tmp 1>&2
unset -f ___tmp
