# Transform text using these functions
# Some were adapted from https://github.com/jmcantrell/bashful

_cleanString_() {
    # DESC:
    #         Cleans a string of text
    # ARGS:
    #         $1 (Required) - String to be cleaned
    #         $2 (optional) - Specific characters to be removed (separated by commas,
    #                         escape regex special chars)
    # OPTS:
    #         -l:  Forces all text to lowercase
    #         -u:  Forces all text to uppercase
    #         -a:  Removes all non-alphanumeric characters except for spaces and dashes
    #         -p:  Replace one character with another (separated by commas) (escape regex characters)
    #         -s:  In combination with -a, replaces characters with a space
    # OUTS:
    #         stdout: Prints cleaned string
    # USAGE:
    #         _cleanString_ [OPT] [STRING] [CHARS TO REMOVE]
    #         _cleanString_ -lp " ,-" [STRING] [CHARS TO REMOVE]
    # NOTES:
    #         Always cleaned:
    #           - leading white space
    #           - trailing white space
    #           - multiple spaces become a single space
    #           - remove spaces before and after -_

    local opt
    local _lc=false
    local _uc=false
    local _alphanumeric=false
    local _replace=false
    local _us=false

    local OPTIND=1
    while getopts ":lLuUaAsSpP" opt; do
        case ${opt} in
            l | L) _lc=true ;;
            u | U) _uc=true ;;
            a | A) _alphanumeric=true ;;
            s | S) _us=true ;;
            p | P)
                shift
                declare -a _pairs=()
                IFS=',' read -r -a _pairs <<<"$1"
                _replace=true
                ;;
            *)
                {
                    error "Unrecognized option '$1' passed to _execute. Exiting."
                    return 1
                }
                ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _string="${1}"
    local _userChars="${2:-}"

    declare -a _arrayToClean=()
    IFS=',' read -r -a _arrayToClean <<<"${_userChars}"

    # trim trailing/leading white space and duplicate spaces/tabs
    _string="$(printf "%s" "${_string}" | awk '{$1=$1};1')"

    local i
    for i in "${_arrayToClean[@]}"; do
        debug "cleaning: ${i}"
        _string="$(printf "%s" "${_string}" | sed "s/${i}//g")"
    done

    ("${_lc}") \
        && _string="$(printf "%s" "${_string}" | tr '[:upper:]' '[:lower:]')"

    ("${_uc}") \
        && _string="$(printf "%s" "${_string}" | tr '[:lower:]' '[:upper:]')"

    if "${_alphanumeric}" && "${_us}"; then
        _string="$(printf "%s" "${_string}" | tr -c '[:alnum:]_ -' ' ')"
    elif "${_alphanumeric}"; then
        _string="$(printf "%s" "${_string}" | sed "s/[^a-zA-Z0-9_ \-]//g")"
    fi

    if "${_replace}"; then
        _string="$(printf "%s" "${_string}" | sed -E "s/${_pairs[0]}/${_pairs[1]}/g")"
    fi

    # trim trailing/leading white space and duplicate dashes & spaces
    _string="$(printf "%s" "${_string}" | tr -s '-' | tr -s '_')"
    _string="$(printf "%s" "${_string}" | sed -E 's/([_\-]) /\1/g' | sed -E 's/ ([_\-])/\1/g')"
    _string="$(printf "%s" "${_string}" | awk '{$1=$1};1')"

    printf "%s\n" "${_string}"

}

_decodeHTML_() {
    # DESC:
    #         Decode HTML characters with sed. Utilizes a sed file for speed.
    # ARGS:
    #         $1 (Required) - String to be decoded
    # OUTS:
    #         0 - Success
    #         1 - Error
    #         stdout: Prints decoded output
    # USAGE:
    #         _decodeHTML_ <string>
    # NOTE:
    #         Must have a sed file containing replacements. See: ../sedfiles/htmlDecode.sed

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _sedFile
    _sedFile="${HOME}/.sed/htmlDecode.sed"

    [ -f "${_sedFile}" ] \
        && { printf "%s\n" "${1}" | sed -f "${_sedFile}"; } \
        || return 1
}

_decodeURL_() {
    # DESC:
    #         Decode a URL encoded string
    # ARGS:
    #         $1 (Required) - String to be decoded
    # OUTS:
    #         Prints output to STDOUT
    # USAGE:
    #         _decodeURL_ <string>

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _url_encoded="${1//+/ }"
    printf '%b' "${_url_encoded//%/\\x}"
}

_encodeHTML_() {
    # DESC:
    #         Encode HTML characters with sed
    # ARGS:
    #         $1 (Required) - String to be encoded
    # OUTS:
    #         0 - Success
    #         1 - Error
    #         stdout: Prints encoded output
    # USAGE:
    #         _encodeHTML_ <string>
    # NOTE:
    #         Must have a sed file containing replacements. See: ../sedfiles/htmlEncode.sed

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _sedFile
    _sedFile="${HOME}/.sed/htmlEncode.sed"

    [ -f "${_sedFile}" ] \
        && { printf "%s" "${1}" | sed -f "${_sedFile}"; } \
        || return 1
}

_encodeURL_() {
    # DESC:
    #         URL encode a string
    # ARGS:
    #         $1 (Required) - String to be encoded
    # OUTS:
    #         Prints output to STDOUT
    # USAGE:
    #         _encodeURL_ <string>
    # CREDIT:
    #         https://gist.github.com/cdown/1163649

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local LANG=C
    local i

    for ((i = 0; i < ${#1}; i++)); do
        if [[ ${1:i:1} =~ ^[a-zA-Z0-9\.\~_-]$ ]]; then
            printf "%s" "${1:i:1}"
        else
            printf '%%%02X' "'${1:i:1}"
        fi
    done
}

_escapeString_() {
    # DESC:
    #         Escapes a string by adding \ before special chars
    # ARGS:
    #         $@ (Required) - String to be escaped
    # OUTS:
    #         stdout: Prints escaped output
    # USAGE:
    #         _escapeString_ "Some text here"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    printf "%s\n" "${@}" | sed 's/[]\.|$[ (){}?+*^]/\\&/g'
}

_lower_() {
    # DESC:
    #         Convert a string to lowercase. Used through a pipe or here string.
    # ARGS:
    #         None
    # OUTS:
    #         None
    # USAGE:
    #         text=$(_lower_ <<<"$1")
    #         printf "STRING" | _lower_
    tr '[:upper:]' '[:lower:]'
}

_ltrim_() {
    # DESC:
    #         Removes all leading whitespace (from the left). Used through a pipe or here string.
    # ARGS:
    #         $1 (Optional) - Character to trim. Defaults to [:space:]
    # OUTS:
    #         None
    # USAGE:
    #         text=$(_ltrim_ <<<"$1")
    #         printf "STRING" | _ltrim_
    local _char=${1:-[:space:]}
    sed "s%^[${_char//%/\\%}]*%%"
}

_regexCapture_() {
    # DESC:
    #         Use regex to capture a group of text from a string
    # ARGS:
    #         $1 (Required) - Input String
    #         $2 (Required) - Regex pattern
    # OPTIONS:
    #         -i (Optional) - Ignore case
    # OUTS:
    #         0 - Regex matched
    #         1 - Regex did not match
    #         stdout: Prints string matching regex
    # USAGE:
    #         HEXCODE=$(_regexCapture_ "background-color: #FFFFFF;" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$')
    #         $ printf "%s\n" "${HEXCODE}"
    #         $ #FFFFFF
    # NOTE:
    #         This example only prints the first matching group. When using multiple capture
    #         groups some modification is needed.
    # CREDIT:
    #         https://github.com/dylanaraps/pure-bash-bible

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

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    if [[ $1 =~ $2 ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
        return 0
    else
        return 1
    fi
}

_rtrim_() {
    # DESC:
    #         Removes all leading whitespace (from the right). Used through a pipe or here string.
    # ARGS:
    #         $1 (Optional) - Character to trim. Defaults to [:space:]
    # OUTS:
    #         None
    # USAGE:
    #         text=$(_rtrim_ <<<"$1")
    #         printf "STRING" | _rtrim_
    local _char=${1:-[:space:]}
    sed "s%[${_char//%/\\%}]*$%%"
}

_splitString_() (
    # DESC:
    #					Split a string into an array based on a given delimiter
    # ARGS:
    #					$1 (Required) - String to be split
    #					$2 (Required) - Delimiter
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: Values split by delimiter separated by newline
    # USAGE:
    #					ARRAY=( $(_splitString_ "string1,string2,string3" ",") )

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    declare -a _arr=()
    local _input="${1}"
    local _delimiter="${2}"

    IFS="${_delimiter}" read -r -a _arr <<<"${_input}"

    printf '%s\n' "${_arr[@]}"
)

_stringContains_() {
    # DESC:
    #					Tests whether a string contains a substring
    # ARGS:
    #					$1 (Required) - String to be tested
    #         $2 (Required) - Substring to be tested for
    # OPTIONS:
    #          -i (Optional) - Ignore case
    # OUTS:
    #					0 - Search pattern found
    #					1 - Pattern not found
    # USAGE:
    #					_stringContains_ "Hello World!" "lo"

    local opt
    local OPTIND=1
    while getopts ":iI" opt; do
        case ${opt} in
            i | I)
                #shellcheck disable=SC2064
                trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
                shopt -s nocasematch                  # Use case-insensitive searching
                ;;
            *) fatal "Unrecognized option '${1}' passed to ${FUNCNAME[0]}. Exiting." ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    if [[ ${1} == *${2}* ]]; then
        return 0
    else
        return 1
    fi
}

_stringRegex_() {
    # DESC:
    #					Tests whether a string matches a regex pattern
    # ARGS:
    #					$1 (Required) - String to be tested
    #         $2 (Required) - Regex pattern to be tested for
    # OPTIONS:
    #          -i (Optional) - Ignore case
    # OUTS:
    #					0 - Search pattern found
    #					1 - Pattern not found
    # USAGE:
    #					_stringContains_ "HELLO" "^[A-Z]*$"
    #         _stringContains_ -i "HELLO" "^[a-z]*$"

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

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    if [[ ${1} =~ ${2} ]]; then
        return 0
    else
        return 1
    fi
}

_stripStopwords_() {
    # DESC:
    #         Removes common stopwords from a string using a list of sed replacements located
    #         in an external file.  Additional stopwords can be added in arg2
    # ARGS:
    #         $1 (Required) - String to parse
    #         $2 (Optional) - Additional stopwords (comma separated)
    # OUTS:
    #         0 - Success
    #         1 - Error
    #         stdout: Prints string cleaned of stopwords
    # USAGE:
    #         CLEAN_WORD="$(_stripStopwords_ "[STRING]" "[MORE,STOP,WORDS]")"
    # NOTE:
    #         Must have a sed file containing replacements. See: ../sedfiles/stopwords.sed

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    if ! sed --version | grep GNU &>/dev/null; then
        fatal "_stripStopwords_: Required GNU sed not found. Exiting."
    fi

    local _string="${1}"
    local _sedFile="${HOME}/.sed/stopwords.sed"
    local _w

    if [ -f "${_sedFile}" ]; then
        _string="$(printf "%s" "${_string}" | sed -f "${_sedFile}")"
    else
        fatal "_stripStopwords_: Missing sedfile expected at: ${_sedFile}"
    fi

    declare -a _localStopWords=()
    IFS=',' read -r -a _localStopWords <<<"${2:-}"

    if [[ ${#_localStopWords[@]} -gt 0 ]]; then
        for _w in "${_localStopWords[@]}"; do
            _string="$(printf "%s" "${_string}" | sed -E "s/\b${_w}\b//gI")"
        done
    fi

    # Remove double spaces and trim left/right
    _string="$(printf "%s" "${_string}" | sed -E 's/[ ]{2,}/ /g' | _trim_)"

    printf "%s\n" "${_string}"

}

_stripANSI_() {
    # DESC:
    #					Strips ANSI escape sequences from a string
    # ARGS:
    #					$1 (Required) - String to be cleaned
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout:  Prints string with ANSI escape sequences removed
    # USAGE:
    #					_stripANSI_ "\e[1m\e[91mThis is bold red text\e(B\e[m.\e[92mThis is green text.\e(B\e[m"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _tmp
    local _esc
    local _tpa
    local _re
    _tmp="${1}"
    _esc=$(printf "\x1b")
    _tpa=$(printf "\x28")
    _re="(.*)${_esc}[\[${_tpa}][0-9]*;*[mKB](.*)"
    while [[ ${_tmp} =~ ${_re} ]]; do
        _tmp="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
    done
    printf "%s" "${_tmp}"
}

_trim_() {
    # DESC:
    #         Removes all leading/trailing whitespace and reduces internal duplicate spaces
    #         to a single space.
    # ARGS:
    #         $1 (Required) - String to be trimmed
    # OUTS:
    #         stdout: Prints string with leading/trailing whitespace removed
    # USAGE:
    #         text=$(_trim_ <<<"$1")
    #         printf "%s" "STRING" | _trim_
    # NOTE:
    #         Used through a pipe or here string.

    awk '{$1=$1;print}'
}

_upper_() {
    # DESC:
    #         Convert a string to uppercase. Used through a pipe or here string.
    # ARGS:
    #         None
    # OUTS:
    #         None
    # USAGE:
    #         text=$(_upper_ <<<"$1")
    #         printf "%s" "STRING" | _upper_
    tr '[:lower:]' '[:upper:]'
}
