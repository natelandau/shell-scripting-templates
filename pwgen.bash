#! /dev/null/bash

function pwgen_wip ()
{
    declare vars=(
        ent
        pw_len
        pw_cnt
        flg_cap
        flg_num
        flg_sym
        flg_sec
        flg_amb
        flg_vwl
        flg_col
        flg_help
    )
    declare ${vars[*]}

    for ent in "${@}"
    do

        declare -p ent

        if [[ "${ent}" =~ ^-[^-] ]]
        then

            while [[ -n "${ent}" ]]
            do

                ent="${ent:1}"

            done

        fi

    done

    return

    {RGX,STR,LEN,TMP}=
    LEN="${1:-8}"
    CNT=0
    RGX='^[0-9a-z]$'
    while read -n1 TMP; do
        [[ "${TMP}" =~ ${RGX} ]] || continue
        STR="${STR}${TMP}"
        [ "${#STR}" -lt "${LEN}" ] || break
    done < /dev/urandom
    echo "${STR}"

    printf '%s' '
Usage: pwgen [ OPTIONS ] [ pw_length ] [ num_pw ]

Options supported by pwgen:
  -c or --capitalize
    Include at least one capital letter in the password
  -A or --no-capitalize
    Don't include capital letters in the password
  -n or --numerals
    Include at least one number in the password
  -0 or --no-numerals
    Don't include numbers in the password
  -y or --symbols
    Include at least one special symbol in the password
  -s or --secure
    Generate completely random passwords
  -B or --ambiguous
    Don't include ambiguous characters in the password
  -h or --help
    Print a help message
  -C
    Print the generated passwords in columns
  -1
    Don't print the generated passwords in columns
  -v or --no-vowels
    Do not use any vowels so as to avoid accidental nasty words
'

}
