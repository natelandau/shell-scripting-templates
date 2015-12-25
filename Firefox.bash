#! /dev/null/bash

function Firefox_places_sqlite3 ()
{
    declare ent opts sqls opt_done
    declare places="$(
        ls -1rt ~/Library/'Application Support'/Firefox/Profiles/*/places.sqlite |
        tail -1
    )"
    opts=()
    sqls=()
    opt_done=0
    for ent in "${@}"
    do
        if [[ "${ent}" == '--' ]]
        then
            opt_done=1
            continue
        fi
        if [[ "${opt_done}" -gt 0 ]]
        then
            sqls[${#sqls[@]}]="${ent}"
        else
            opts[${#opts[@]}]="${ent}"
        fi
    done
    sqlite3 "${opts[@]}" "${places}" "${sqls[@]}"
}
