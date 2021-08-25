# Transform text using these functions
# Some were adapted from https://github.com/jmcantrell/bashful

_cleanString_() {
    # DESC:   Cleans a string of text
    # ARGS:   $1 (Required) - String to be cleaned
    #         $2 (optional) - Specific characters to be removed (separated by commas,
    #                         escape regex special chars)
    # OPTS:   -l  Forces all text to lowercase
    #         -u  Forces all text to uppercase
    #         -a  Removes all non-alphanumeric characters except for spaces and dashes
    #         -p  Replace one character with another (separated by commas) (escape regex characters)
    #         -s  In combination with -a, replaces characters with a space
    # OUTS:   Prints result to STDOUT
    # USAGE:  _cleanString_ [OPT] [STRING] [CHARS TO REMOVE]
    #         _cleanString_ -lp " ,-" [STRING] [CHARS TO REMOVE]
    # NOTES:  Always cleaned:
    #           - leading white space
    #           - trailing white space
    #           - multiple spaces become a single space
    #           - remove spaces before and after -_

    local opt
    local lc=false
    local uc=false
    local alphanumeric=false
    local replace=false
    local us=false

    local OPTIND=1
    while getopts ":lLuUaAsSpP" opt; do
        case $opt in
            l | L) lc=true ;;
            u | U) uc=true ;;
            a | A) alphanumeric=true ;;
            s | S) us=true ;;
            p | P)
                shift
                local pairs=()
                IFS=',' read -r -a pairs <<<"$1"
                replace=true
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

    [[ $# -lt 1 ]] && fatal 'Missing required argument to _cleanString_()!'

    local string="${1}"
    local userChars="${2:-}"

    local arrayToClean=()
    IFS=',' read -r -a arrayToClean <<<"${userChars}"

    # trim trailing/leading white space and duplicate spaces/tabs
    string="$(echo "${string}" | awk '{$1=$1};1')"

    local i
    for i in "${arrayToClean[@]}"; do
        debug "cleaning: $i"
        string="$(echo "${string}" | sed "s/$i//g")"
    done

    ("${lc}") \
        && string="$(echo "${string}" | tr '[:upper:]' '[:lower:]')"

    ("${uc}") \
        && string="$(echo "${string}" | tr '[:lower:]' '[:upper:]')"

    if "${alphanumeric}" && "${us}"; then
        string="$(echo "${string}" | tr -c '[:alnum:]_ -' ' ')"
    elif "${alphanumeric}"; then
        string="$(echo "${string}" | sed "s/[^a-zA-Z0-9_ \-]//g")"
    fi

    if "${replace}"; then
        string="$(echo "${string}" | sed -E "s/${pairs[0]}/${pairs[1]}/g")"
    fi

    # trim trailing/leading white space and duplicate dashes
    string="$(echo "${string}" | tr -s '-' | tr -s '_')"
    string="$(echo "${string}" | sed -E 's/([_\-]) /\1/g' | sed -E 's/ ([_\-])/\1/g')"
    string="$(echo "${string}" | awk '{$1=$1};1')"

    echo "${string}"

}

_stopWords_() {
    # DESC:   Removes common stopwords from a string
    # ARGS:   $1 (Required) - String to parse
    #         $2 (Optional) - Additional stopwords (comma separated)
    # OUTS:   Prints cleaned string to STDOUT
    # USAGE:  cleanName="$(_stopWords_ "[STRING]" "[MORE,STOP,WORDS]")"
    # NOTE:   Requires a stopwords file in sed format (expected at: ~/.sed/stopwords.sed)

    [[ $# -lt 1 ]] && {
        warning 'Missing required argument to _stripCommonWords_!'
        return 1
    }

    if command -v gsed &>/dev/null; then
        local SED_COMMAND="gsed"
    elif sed --version | grep GNU &>/dev/null; then
        local SED_COMMAND="sed"
    else
        error "Can not continue without gnu sed.  Use '${YELLOW}brew install gnu-sed${reset} on a Mac or install with your package manager'"
        return 1
    fi

    local string="${1}"
    local sedFile="${HOME}/.sed/stopwords.sed"
    if [ -f "${sedFile}" ]; then
        string="$(echo "${string}" | ${SED_COMMAND} -f "${sedFile}")"
    else
        debug "Missing sedfile in _stopWords_()"
    fi

    declare -a localStopWords=()
    IFS=',' read -r -a localStopWords <<<"${2:-}"

    if [[ ${#localStopWords[@]} -gt 0 ]]; then
        for w in "${localStopWords[@]}"; do
            string="$(echo "${string}" | ${SED_COMMAND} -E "s/\b${w}\b//gI")"
        done
    fi

    # Remove double spaces and trim left/right
    string="$(echo "${string}" | ${SED_COMMAND} -E 's/[ ]{2,}/ /g' | _ltrim_ | _rtrim_)"

    echo "${string}"

}

_escape_() {
    # DESC:   Escapes a string by adding \ before special chars
    # ARGS:   $@ (Required) - String to be escaped
    # OUTS:   Prints output to STDOUT
    # USAGE:  _escape_ "Some text here"

    # shellcheck disable=2001
    echo "${@}" | sed 's/[]\.|$[ (){}?+*^]/\\&/g'
}

_htmlDecode_() {
    # DESC:   Decode HTML characters with sed
    # ARGS:   $1 (Required) - String to be decoded
    # OUTS:   Prints output to STDOUT
    # USAGE:  _htmlDecode_ <string>
    # NOTE:   Must have a sed file containing replacements

    [[ $# -lt 1 ]] && {
        error 'Missing required argument to _htmlDecode_()!'
        return 1
    }

    local sedFile
    sedFile="${HOME}/.sed/htmlDecode.sed"

    [ -f "${sedFile}" ] \
        && { echo "${1}" | sed -f "${sedFile}"; } \
        || return 1
}

_htmlEncode_() {
    # DESC:   Encode HTML characters with sed
    # ARGS:   $1 (Required) - String to be encoded
    # OUTS:   Prints output to STDOUT
    # USAGE:  _htmlEncode_ <string>
    # NOTE:   Must have a sed file containing replacements

    [[ $# -lt 1 ]] && {
        error 'Missing required argument to _htmlEncode_()!'
        return 1
    }

    local sedFile
    sedFile="${HOME}/.sed/htmlEncode.sed"

    [ -f "${sedFile}" ] \
        && { echo "${1}" | sed -f "${sedFile}"; } \
        || return 1
}

_lower_() {
    # DESC:   Convert a string to lowercase
    # ARGS:   None
    # OUTS:   None
    # USAGE:  text=$(_lower_ <<<"$1")
    #         echo "STRING" | _lower_
    tr '[:upper:]' '[:lower:]'
}

_upper_() {
    # DESC:   Convert a string to uppercase
    # ARGS:   None
    # OUTS:   None
    # USAGE:  text=$(_upper_ <<<"$1")
    #         echo "STRING" | _upper_
    tr '[:lower:]' '[:upper:]'
}

_ltrim_() {
    # DESC:   Removes all leading whitespace (from the left)
    # ARGS:   None
    # OUTS:   None
    # USAGE:  text=$(_ltrim_ <<<"$1")
    #         echo "STRING" | _ltrim_
    local char=${1:-[:space:]}
    sed "s%^[${char//%/\\%}]*%%"
}

_regex_() {
    # DESC:   Use regex to validate and parse strings
    # ARGS:   $1 (Required) - Input String
    #         $2 (Required) - Regex pattern
    # OUTS:   Prints string matching regex
    #         Returns error if no part of string did not match regex
    # USAGE:  _regex_ "#FFFFFF" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'
    # NOTE:   This example only prints the first matching group. When using multiple capture
    #         groups some modification is needed.
    #         https://github.com/dylanaraps/pure-bash-bible
    if [[ $1 =~ $2 ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
        return 0
    else
        return 1
    fi
}

_rtrim_() {
    # DESC:   Removes all leading whitespace (from the right)
    # ARGS:   None
    # OUTS:   None
    # USAGE:  text=$(_rtrim_ <<<"$1")
    #         echo "STRING" | _rtrim_
    local char=${1:-[:space:]}
    sed "s%[${char//%/\\%}]*$%%"
}

_trim_() {
    # DESC:   Removes all leading/trailing whitespace
    # ARGS:   None
    # OUTS:   None
    # USAGE:  text=$(_trim_ <<<"$1")
    #         echo "STRING" | _trim_
    awk '{$1=$1;print}'
}

_urlEncode_() {
    # DESC:   URL encode a string
    # ARGS:   $1 (Required) - String to be encoded
    # OUTS:   Prints output to STDOUT
    # USAGE:  _urlEncode_ <string>
    # NOTE:   https://gist.github.com/cdown/1163649

    [[ $# -lt 1 ]] && {
        error 'Missing required argument to _urlEncode_()!'
        return 1
    }

    local LANG=C
    local i

    for ((i = 0; i < ${#1}; i++)); do
        if [[ ${1:i:1} =~ ^[a-zA-Z0-9\.\~_-]$ ]]; then
            printf "${1:i:1}"
        else
            printf '%%%02X' "'${1:i:1}"
        fi
    done
}

_urlDecode_() {
    # DESC:   Decode a URL encoded string
    # ARGS:   $1 (Required) - String to be decoded
    # OUTS:   Prints output to STDOUT
    # USAGE:  _urlDecode_ <string>

    [[ $# -lt 1 ]] && {
        error 'Missing required argument to _urlDecode_()!'
        return 1
    }

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}
