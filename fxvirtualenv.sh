#! /dev/null/bash

function fxvirtualenv ()
{
    local sdir vhom vdir venv vflg
    sdir="${PWD}"
    vhom="${WORKON_HOME:-${VIRTUALENVWRAPPER_HOOK_DIR}}"
    vdir="${VIRTUAL_ENV}"
    venv="${1}"
    if [[ -n "${venv}" ]]; then
        vflg=0
        vdir="${vhom}/${venv}"
        if [[ ! -e "${vdir}" ]]; then
            vdir=
        fi
    else
        vflg=1
    fi
    if [[ -z "${vdir}" ]]; then
        workon
        return "${?}"
    fi
    venv="${vdir##*/}"
    deactivate > /dev/null 2>&1
    find -L "${vdir}" -type l -exec rm -vf '{}' \
    cd "${vdir}"
    virtualenv .
    cd "${sdir}"
    if [[ "${vflg}" -ne 0 ]]; then
        workon "${venv}"
    fi
}
