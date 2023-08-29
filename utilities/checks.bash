# Functions for validating common use-cases

_commandExists_() {
    # DESC:
    #         Check if a binary exists in the search PATH
    # ARGS:
    #         $1 (Required) - Name of the binary to check for existence
    # OUTS:
    #         0 if true
    #         1 if false
    # USAGE:
    #         (_commandExists_ ffmpeg ) && [SUCCESS] || [FAILURE]

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    if ! command -v "$1" >/dev/null 2>&1; then
        debug "Did not find dependency: '${1}'"
        return 1
    fi
    return 0
}

_functionExists_() {
    # DESC:
    #         Tests if a function exists in the current scope
    # ARGS:
    #         $1 (Required) - Function name
    # OUTS:
    #         0 if function exists
    #         1 if function does not exist

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _testFunction
    _testFunction="${1}"

    if declare -f "${_testFunction}" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

_isAlpha_() {
    # DESC:
    #					Validate that a given input is entirely alphabetic characters
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is only alphabetic characters
    #					1 - Input contains non-alphabetic characters
    # USAGE:
    #					_isAlpha_ "${var}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _re='^[[:alpha:]]+$'
    if [[ ${1} =~ ${_re} ]]; then
        return 0
    fi
    return 1
}

_isAlphaNum_() {
    # DESC:
    #					Validate that a given input is entirely alpha-numeric characters
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is only alpha-numeric characters
    #					1 - Input contains alpha-numeric characters
    # USAGE:
    #					_isAlphaNum_ "${var}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _re='^[[:alnum:]]+$'
    if [[ ${1} =~ ${_re} ]]; then
        return 0
    fi
    return 1
}

_isAlphaDash_() {
    # DESC:
    #					Validate that a given input contains only alpha-numeric characters, as well as dashes and underscores.
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is only alpha-numeric or dash or underscore characters
    #					1 - Input is not only alpha-numeric or dash or underscore characters
    # USAGE:
    #					_isAlphaDash_ "${var}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _re='^[[:alnum:]_-]+$'
    if [[ ${1} =~ ${_re} ]]; then
        return 0
    fi
    return 1
}

_isEmail_() {
    # DESC:
    #					Validates that input is a valid email address
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Is valid email
    #					1 - Is not valid email
    # USAGE:
    #					_isEmail_ "somename+test@gmail.com"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    #shellcheck disable=SC2064
    trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
    shopt -s nocasematch                  # Use case-insensitive regex

    local _emailRegex
    _emailRegex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
    [[ ${1} =~ ${_emailRegex} ]] && return 0 || return 1
}

_isFQDN_() {
    # DESC:
    #					Determines if a given input is a fully qualified domain name
    # ARGS:
    #					$1 (Required):	String to validate
    # OUTS:
    #					0:  Successfully validated as FQDN
    #					1:  Failed to validate as FQDN
    # USAGE:
    #					_isFQDN_ "some.domain.com"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _input="${1}"

    if printf "%s" "${_input}" | grep -Pq '(?=^.{4,253}$)(^(?:[a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+([a-zA-Z]{2,}|xn--[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])$)'; then
        return 0
    else
        return 1
    fi
}

_isInternetAvailable_() {
    # DESC:
    #         Check if internet connection is available
    # ARGS:
    #         None
    # OUTS:
    #					0 - Success: Internet connection is available
    #					1 - Failure: Internet connection is not available
    #					stdout:
    # USAGE:
    #					_isInternetAvailable_

    local _checkInternet
    if [[ -t 1 || -z ${TERM} ]]; then
        _checkInternet="$(sh -ic 'exec 3>&1 2>/dev/null; { curl --compressed -Is google.com 1>&3; kill 0; } | { sleep 10; kill 0; }' || :)"
    else
        _checkInternet="$(curl --compressed -Is google.com -m 10)"
    fi
    if [[ -z ${_checkInternet-} ]]; then
        return 1
    fi
}

_isIPv4_() {
    # DESC:
    #					Validates that input is a valid IP version 4 address
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Is valid IPv4 address
    #					1 - Is not valid IPv4 address
    # USAGE:
    #					_isIPv4_ "192.168.1.1"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _ip="${1}"
    local IFS=.
    # shellcheck disable=SC2206
    declare -a _a=(${_ip})
    [[ ${_ip} =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
    # Test values of quads
    local _quad
    for _quad in {0..3}; do
        [[ ${_a[${_quad}]} -gt 255 ]] && return 1
    done
    return 0
}

_isFile_() {
    # DESC:
    #					Validate that a given input points to a valid file
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is a valid file
    #					1 - Input is not a valid file
    # USAGE:
    #					_varIsFile_ "${var}"
    # NOTES:
    #

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [[ -f ${1} ]] && return 0 || return 1
}

_isDir_() {
    # DESC:
    #					Validate that a given input points to a valid directory
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is a directory
    #					1 - Input is not a directory
    # USAGE:
    #         _varIsDir_ "${var}"
    #         (_isDir_ "${var}") && printf "Is a directory" || printf "Not a directory"
    # NOTES:
    #

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [[ -d ${1} ]] && return 0 || return 1
}

_isNum_() {
    # DESC:
    #					Validate that a given input is entirely numeric characters
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Input is only numeric characters
    #					1 - Input contains numeric characters
    # USAGE:
    #					_isNum_ "${var}"
    # NOTES:
    #

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _re='^[[:digit:]]+$'
    if [[ ${1} =~ ${_re} ]]; then
        return 0
    fi
    return 1
}

_isTerminal_() {
    # DESC:
    #					Check is script is run in an interactive terminal
    # ARGS:
    #					None
    # OUTS:
    #					0 - Script is run in a terminal
    #					1 - Script is not run in a terminal
    # USAGE:
    #					_isTerminal_

    [[ -t 1 || -z ${TERM} ]] && return 0 || return 1
}

_rootAvailable_() {
    # DESC:
    #         Validate we have superuser access as root (via sudo if requested)
    # ARGS:
    #         $1 (optional): Set to any value to not attempt root access via sudo
    # OUTS:
    #         0 if true
    #         1 if false
    # CREDIT:
    #         https://github.com/ralish/bash-script-template

    local _superuser

    if [[ ${EUID} -eq 0 ]]; then
        _superuser=true
    elif [[ -z ${1-} ]]; then
        debug 'Sudo: Updating cached credentials ...'
        if sudo -v; then
            if [[ $(sudo -H -- "${BASH}" -c 'printf "%s" "$EUID"') -eq 0 ]]; then
                _superuser=true
            else
                _superuser=false
            fi
        else
            _superuser=false
        fi
    fi

    if [[ ${_superuser} == true ]]; then
        debug 'Successfully acquired superuser credentials.'
        return 0
    else
        debug 'Unable to acquire superuser credentials.'
        return 1
    fi
}

_varIsTrue_() {
    # DESC:
    #					Check if a given variable is true
    # ARGS:
    #					$1 (required): Variable to check
    # OUTS:
    #					0 - Variable is true
    #					1 - Variable is false
    # USAGE
    #					_varIsTrue_ "${var}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [[ ${1,,} == "true" || ${1} == 0 ]] && return 0 || return 1
}

_varIsFalse_() {
    # DESC:
    #					Check if a given variable is false
    # ARGS:
    #					$1 (required): Variable to check
    # OUTS:
    #					0 - Variable is false
    #					1 - Variable is true
    # USAGE
    #					_varIsFalse_ "${var}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [[ ${1,,} == "false" || ${1} == 1 ]] && return 0 || return 1
}

_varIsEmpty_() {
    # DESC:
    #					Check if given variable is empty or null.
    # ARGS:
    #					$1 (required): Variable to check
    # OUTS:
    #					0 - Variable is empty or null
    #					1 - Variable is not empty or null
    # USAGE
    #					_varIsEmpty_ "${var}"

    [[ -z ${1-} || ${1-} == "null" ]] && return 0 || return 1
}

_isIPv6_() {
    # DESC:
    #					Validates that input is a valid IP version 46address
    # ARGS:
    #					$1 (required): Input to check
    # OUTS:
    #					0 - Is valid IPv6 address
    #					1 - Is not valid IPv6 address
    # USAGE:
    #					_isIPv6_ "2001:db8:85a3:8d3:1319:8a2e:370:7348"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _ip="${1}"
    local _re="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|\
([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|\
([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|\
([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|\
:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|\
::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|\
(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|\
(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"

    [[ ${_ip} =~ ${_re} ]] && return 0 || return 1
}
