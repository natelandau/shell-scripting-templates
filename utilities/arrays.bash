# Functions for manipulating arrays

_dedupeArray_() {
    # DESC:
    #         Removes duplicate array elements
    # ARGS:
    #         $1 (Required) - Input array
    # OUTS:
    #         stdout: Prints de-duped elements
    # USAGE:
    #         mapfile -t newarray < <(_dedupeArray_ "${array[@]}")
    # NOTE:
    #         List order may not stay the same
    # CREDIT:
    #         https://github.com/dylanaraps/pure-bash-bible

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    declare -A _tmpArray
    declare -a _uniqueArray
    local _i
    for _i in "$@"; do
        { [[ -z ${_i} || -n ${_tmpArray[${_i}]:-} ]]; } && continue
        _uniqueArray+=("${_i}") && _tmpArray[${_i}]=x
    done
    printf '%s\n' "${_uniqueArray[@]}"
}

_forEachDo_() {
    # DESC:
    #					Iterates over elements and passes each to a function
    # ARGS:
    #					$1 (Required) - Function name to pass each item to
    # OUTS:
    #					0 - Success
    #					Return code of called function
    #					stdout: Output of called function
    # USAGE:
    #					printf "%s\n" "${arr1[@]}" | _forEachDo_ "test_func"
    #         _forEachDo_ "test_func" < <(printf "%s\n" "${arr1[@]}") #alternative approach
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _func="${1}"
    local IFS=$'\n'
    local _it

    while read -r _it; do
        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            if declare -f "${_func}" &>/dev/null; then
                eval "${_func}" "'${_it}'"
            else
                fatal "${FUNCNAME[0]} could not find function ${_func}"
            fi
        fi
        declare -i _ret="$?"

        if [[ ${_ret} -ne 0 ]]; then
            return "${_ret}"
        fi
    done
}

_forEachValidate_() {
    # DESC:
    #					Iterates over elements and passes each to a function for validation. Iteration stops when the function returns 1.
    # ARGS:
    #					$1 (Required) - Function name to pass each item to for validation. (Must return 0 on success)
    # OUTS:
    #					0 - Success
    #					1 - Iteratee function fails
    # USAGE:
    #					printf "%s\n" "${array[@]}" | _forEachValidate_ "_isAlpha_"
    #         _forEachValidate_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _func="${1}"
    local IFS=$'\n'
    local _it

    while read -r _it; do
        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            if ! declare -f "${_func}"; then
                fatal "${FUNCNAME[0]} could not find function ${_func}"
            else
                eval "${_func}" "'${_it}'"
            fi
        fi
        declare -i _ret="$?"

        if [[ ${_ret} -ne 0 ]]; then
            return 1
        fi
    done
}

_forEachFind_() {
    # DESC:
    #					Iterates over elements, returning success and printing the first value that is validated by a function
    # ARGS:
    #					$1 (Required) - Function name to pass each item to for validation. (Must return 0 on success)
    # OUTS:
    #					0 - If successful
    #					1 - If iteratee function fails
    #					stdout:  First value that is validated by the function
    # USAGE:
    #					printf "%s\n" "${array[@]}" | _forEachFind_ "_isAlpha_"
    #         _forEachFind_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    declare _func="${1}"
    declare IFS=$'\n'
    while read -r _it; do

        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            eval "${_func}" "'${_it}'"
        fi
        declare -i _ret="$?"
        if [[ ${_ret} == 0 ]]; then
            printf "%s" "${_it}"
            return 0
        fi
    done

    return 1
}

_forEachFilter_() {
    # DESC:
    #					Iterates over elements, returning only those that are validated by a function
    # ARGS:
    #					$1 (Required) - Function name to pass each item to for validation. (Must return 0 on success)
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: Values matching the validation function
    # USAGE:
    #					printf "%s\n" "${array[@]}" | _forEachFind_ "_isAlpha_"
    #         _forEachFilter_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _func="${1}"
    local IFS=$'\n'
    while read -r _it; do
        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            eval "${_func}" "'${_it}'"
        fi
        declare -i _ret="$?"
        if [[ ${_ret} == 0 ]]; then
            printf "%s\n" "${_it}"
        fi
    done
}

_forEachReject_() {
    # DESC:
    #					The opposite of _forEachFilter_. Iterates over elements, returning only those that are not validated by a function
    # ARGS:
    #					$1 (Required) - Function name to pass each item to for validation. (Must return 0 on success, 1 on failure)
    # OUTS:
    #					0 - Success
    #					stdout:  Values NOT matching the validation function
    # USAGE:
    #					printf "%s\n" "${array[@]}" | _forEachReject_ "_isAlpha_"
    #         _forEachReject_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _func="${1}"
    local IFS=$'\n'
    while read -r _it; do
        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            eval "${_func}" "'${_it}'"
        fi
        declare -i _ret=$?
        if [[ ${_ret} -ne 0 ]]; then
            printf "%s\n" "${_it}"
        fi
    done
}

_forEachSome_() {
    # DESC:
    #					Iterates over elements, returning true if any of the elements validate as true from the function.
    # ARGS:
    #         $1 (Required) - Function name to pass each item to for validation. (Must return 0 on success, 1 on failure)
    # OUTS:
    #					0 If match successful
    #					1 If no match found
    # USAGE:
    #					printf "%s\n" "${array[@]}" | _forEachSome_ "_isAlpha_"
    #         _forEachSome_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _func="${1}"
    local IFS=$'\n'
    while read -r _it; do

        if [[ ${_func} == *"$"* ]]; then
            eval "${_func}"
        else
            eval "${_func}" "'${_it}'"
        fi

        declare -i _ret=$?
        if [[ ${_ret} -eq 0 ]]; then
            return 0
        fi
    done

    return 1
}

_inArray_() {
    # DESC:
    #         Determine if a value is in an array.  Default is case sensitive.
    #         Pass -i flag to ignore case.
    # ARGS:
    #         $1 (Required) - Value to search for
    #         $2 (Required) - Array written as ${ARRAY[@]}
    # OPTIONS:
    #         -i (Optional) - Ignore case
    # OUTS:
    #         0 if true
    #         1 if untrue
    # USAGE:
    #         if _inArray_ "VALUE" "${ARRAY[@]}"; then ...
    #         if _inArray_  -i "VALUE" "${ARRAY[@]}"; then ...
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local opt
    local OPTIND=1
    while getopts ":iI" opt; do
        case ${opt} in
            i | I)
                #shellcheck disable=SC2064
                trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
                shopt -s nocasematch                  # Use case-insensitive regex
                ;;
            *) fatal "Unrecognized option '${1}' passed to ${FUNCNAME[0]}. Exiting." ;;
        esac
    done
    shift $((OPTIND - 1))

    local _array_item
    local _value="${1}"
    shift
    for _array_item in "$@"; do
        [[ ${_array_item} =~ ^${_value}$ ]] && return 0
    done
    return 1
}

_isEmptyArray_() {
    # DESC:
    #         Checks if an array is empty
    # ARGS:
    #         $1 (Required) - Input array
    # OUTS:
    #         0 if empty
    #         1 if not empty
    # USAGE:
    #         _isEmptyArray_ "${array[@]}"
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    declare -a _array=("$@")
    if [ ${#_array[@]} -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

_joinArray_() {
    # DESC:
    #         Joins items together with a user specified separator
    # ARGS:
    #           $1 (Required) - Separator
    #           $@ (Required) - Array or space separated items to be joined
    # OUTS:
    #           stdout:  Prints joined terms
    # USAGE:
    #           _joinArray_ , a "b c" d #a,b c,d
    #           _joinArray_ / var local tmp #var/local/tmp
    #           _joinArray_ , "${foo[@]}" #a,b,c
    # CREDIT:
    #           http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
    #           https://github.com/labbots/bash-utility

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _delimiter="${1}"
    shift
    printf "%s" "${1}"
    shift
    printf "%s" "${@/#/${_delimiter}}"
}

_mergeArrays_() {
    # DESC:
    #         Merges two arrays together
    # ARGS:
    #         $1 (Required) - Array 1
    #			    $2 (Required) - Array 2
    # OUTS:
    #         stdout: Prints result
    # USAGE:
    #         newarray=($(_mergeArrays_ "array1[@]" "array2[@]"))
    # NOTE:
    #         Note that the arrays must be passed in as strings
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# -ne 2 ]] && fatal 'Missing required argument to _mergeArrays_'
    declare -a _arr1=("${!1}")
    declare -a _arr2=("${!2}")
    declare _outputArray=("${_arr1[@]}" "${_arr2[@]}")
    printf "%s\n" "${_outputArray[@]}"
}

_reverseSortArray_() {
    # DESC:
    #           Sorts an array from lowest to highest (z-a9-0)
    # ARGS:
    #           $1 (Required) - Input array
    # OUTS:
    #           stdout: Prints result
    # USAGE:
    #           _reverseSortArray_ "${array[@]}"
    # NOTE:
    #           input=("c" "b" "4" "1" "2" "3" "a")
    #           _reverseSortArray_ "${input[@]}"
    #           c b a 4 3 2 1
    # CREDIT:
    #           https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    declare -a _array=("$@")
    declare -a _sortedArray
    mapfile -t _sortedArray < <(printf '%s\n' "${_array[@]}" | sort -r)
    printf "%s\n" "${_sortedArray[@]}"
}

_randomArrayElement_() {
    # DESC:
    #         Selects a random item from an array
    # ARGS:
    #         $1 (Required) - Input array
    # OUTS:
    #         stdout: Prints one random element
    # USAGE:
    #         _randomArrayElement_ "${array[@]}"
    # CREDIT:
    #         https://github.com/dylanaraps/pure-bash-bible

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    declare -a _array
    local _array=("$@")
    printf '%s\n' "${_array[RANDOM % $#]}"
}

_setDiff_() {
    # DESC:
    #         Return items that exist in ARRAY1 that are do not exist in ARRAY2
    # ARGS:
    #         $1 (Required) - Array 1 (in format ARRAY[@])
    #         $2 (Required) - Array 2 (in format ARRAY[@])
    # OUTS:
    #         0 if unique elements found
    #         1 if arrays are the same
    #         stdout: Prints unique elements
    # USAGE:
    #         _setDiff_ "array1[@]" "array2[@]"
    #         mapfile -t NEW_ARRAY < <(_setDiff_ "array1[@]" "array2[@]")
    # NOTE:
    #         Note that the arrays must be passed in as strings
    # CREDIT:
    #         http://stackoverflow.com/a/1617303/142339

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _skip
    local _a
    local _b
    declare -a _setdiffA=("${!1}")
    declare -a _setdiffB=("${!2}")
    declare -a _setdiffC=()

    for _a in "${_setdiffA[@]}"; do
        _skip=0
        for _b in "${_setdiffB[@]}"; do
            if [[ ${_a} == "${_b}" ]]; then
                _skip=1
                break
            fi
        done
        [[ ${_skip} -eq 1 ]] || _setdiffC=("${_setdiffC[@]}" "${_a}")
    done

    if [[ ${#_setdiffC[@]} == 0 ]]; then
        return 1
    else
        printf "%s\n" "${_setdiffC[@]}"
    fi
}

_sortArray_() {
    # DESC:
    #           Sorts an array from lowest to highest (0-9 a-z)
    # ARGS:
    #           $1 (Required) - Input array
    # OUTS:
    #           stdout: Prints result
    # USAGE:
    #           _sortArray_ "${array[@]}"
    # NOTE:
    #           input=("c" "b" "4" "1" "2" "3" "a")
    #           _sortArray_ "${input[@]}"
    #           1 2 3 4 a b c
    # CREDIT:
    #           https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    declare -a _array=("$@")
    declare -a _sortedArray
    mapfile -t _sortedArray < <(printf '%s\n' "${_array[@]}" | sort)
    printf "%s\n" "${_sortedArray[@]}"
}
