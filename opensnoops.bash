#! /dev/null/bash

function opensnoops ()
{
    declare {{O,G}_ARGS,ARG,FLG}=
    O_ARGS=()
    G_ARGS=()
    for ARG in ${@:+"${@}"}
    do
        [ "${ARG}" == "--" ] && FLG="G" && continue
        [ "${FLG}" == "G" ] \
            && G_ARGS[${#G_ARGS[@]}]="${ARG}" \
            || O_ARGS[${#O_ARGS[@]}]="${ARG}"
    done
    sudo opensnoop ${O_ARGS[*]:+"${O_ARGS[@]}"} 2>&1 |
        grep --line-buffered "${G_ARGS[@]:-}"
}
