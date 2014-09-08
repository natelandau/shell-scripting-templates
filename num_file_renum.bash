#! /dev/null/bash

function num_file_renum ()
{

    declare file file_d file_n file_b I J diff files

    [ -n "${1}" -a "${#}" -gt 1 ] || return 1

    diff="${1}"
    shift
    files=("${@}")

    for file in "${files[@]}"
    do

        file_d="${file%/*}"
        [ "${file_d}" != "${file}" ] || file_d=

        file_n="${file##*/}"

        I="${file_n%%_*}"
        file_b="${file_n#*_}"

        printf -v J %02d "$(( I + diff ))"

        command mv -vi "${file}" "${file_d:+${file_d}/}${J}_${file_b}"

    done
}
