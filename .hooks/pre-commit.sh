#!/usr/bin/env bash

_mainScript_() {

    GITROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    _setPATH_ "/usr/local/bin" "${HOME}/bin"
    LOGFILE="${HOME}/logs/$(_fileName_ "${GITROOT}")-$(basename "$0").log"

    _gitStopWords_() {
        # DESC:
        #					Check if any specified stop words are in the commit diff.  If found, the pre-commit hook will exit with a non-zero exit code.
        # ARGS:
        #					$1 (Required):  Path to file
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        # USAGE:
        #					_gitStopWords_ "/path/to/file.sh"
        # NOTE:
        #         Requires a file located at `~/.git_stop_words` containing one stopword per line.

        [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

        local _gitDiffTmp="${TMP_DIR}/diff.txt"

        if [ -f "${STOP_WORD_FILE}" ]; then

            if [[ $(basename "${STOP_WORD_FILE}") == "$(basename "${1}")" ]]; then
                debug "$(basename "${1}"): Don't check stop words file for stop words."
                return 0
            fi
            debug "$(basename "${1}"): Checking for stop words..."

            # remove blank lines from stopwords file
            cat "${STOP_WORD_FILE}" | sed '/^$/d' >"${TMP_DIR}/pattern_file.txt"

            # Add diff to a temporary file
            git diff --cached -- "${1}" | grep '^+' >"${_gitDiffTmp}"

            if grep --file="${TMP_DIR}/pattern_file.txt" "${_gitDiffTmp}"; then
                return 1
            else
                return 0
            fi
        else
            notice "Could not find git stopwords file expected at '${STOP_WORD_FILE}'. Continuing..."
            return 0
        fi
    }

    _ignoreSymlinks_() {
        # DESC:
        #					Ensures that no symlinks have been committed to the repository.  If the symlink
        #         has not yet been staged, it will be added to the .gitignore file.
        # ARGS:
        #					NONE
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        # USAGE:
        #					_ignoreSymlinks_

        local _gitIgnore="${GITROOT}/.gitignore"
        local _haveSymlink=false
        local _f

        debug "Checking for symlinks..."

        # Work on files not yet staged
        for _f in $(git status --porcelain | grep '^??' | sed 's/^?? //'); do
            if [ -L "${_f}" ]; then
                if ! grep "${_f}" "${_gitIgnore}"; then
                    if printf "\n%s" "${_f}" >>"${_gitIgnore}"; then
                        notice "Added unstaged symlink '${_f}' to .gitignore"
                    else
                        fatal "Could not add symlink '${_f}' to .gitignore"
                    fi
                fi
                _haveSymlink=true
            fi
        done

        # Work on files that were mistakenly staged
        for f in $(git status --porcelain | grep '^A' | sed 's/^A //'); do
            if [ -L "${_f}" ]; then
                if ! grep "${_f}" "${_gitIgnore}"; then
                    if printf "\n%s" "${_f}" >>"${_gitIgnore}"; then
                        notice "Added unstaged symlink '${_f}' to .gitignore"
                    else
                        fatal "Could not add symlink '${_f}' to .gitignore"
                    fi
                fi
                _haveSymlink=true
            fi
        done

        if [[ ${_haveSymlink} == true ]]; then
            return 1
        else
            return 0
        fi
    }

    _lintYAML_() {
        # DESC:
        #					Lint YAML files staged for commit.
        #         Requires either 'yaml-lint 'or 'yamllint' be installed.
        # ARGS:
        #					$1 (Required):  Path to file
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        # USAGE:
        #					_lintYAML_ "/path/to/file.yaml"

        [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

        local _filename="$(_fileName_ "${1}")"

        if command -v yaml-lint >/dev/null; then
            debug "${_filename}: Linting YAML..."
            if yaml-lint "${1}"; then
                return 0
            else
                return 1
            fi
        elif command -v yamllint >/dev/null; then
            debug "${_filename}: Linting YAML..."
            if [ -f "$(git rev-parse --show-toplevel)/.yamllint.yml" ]; then
                if yamllint -c "$(git rev-parse --show-toplevel)/.yamllint.yml" "${1}"; then
                    return 0
                else
                    return 1
                fi
            else
                if yamllint "${1}"; then
                    return 0
                else
                    return 1
                fi
            fi
        else
            notice "No YAML linter found. Continuing..."
            return 0
        fi
    }

    _lintShellscripts_() {
        # DESC:
        #					Lint shell scripts staged for commit.
        # ARGS:
        #					$1 (Required):	Path to file
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        #					stdout:
        # USAGE:
        #					_lintShellscripts_ "/path/to/file.sh"

        [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

        local _filename="$(_fileName_ "${1}")"

        if command -v shellcheck >/dev/null; then
            debug "${_filename}: Linting shellscript..."
            if shellcheck --exclude=2016,2059,2001,2002,2148,1090,2162,2005,2034,2154,2086,2155,2181,2164,2120,2119,1083,1117,2207,1091 "${1}"; then
                return 0
            else
                return 1
            fi
        else
            notice "Shellcheck not installed.  Continuing..."
            return 0
        fi
    }

    _BATS_() {
        # DESC:
        #					Runs BATS unit tests on bash scripts.  Requires bats to be installed.
        # ARGS:
        #					$1 (Required):	Path to bats test file
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        # USAGE:
        #					_BATS_ "/path/to/file.sh"

        [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

        local _filename="$(_fileName_ "${1}")"
        debug "${_filename}: Runing bats tests..."
        if bats -t $1; then
            return 0
        else
            return 1
        fi
    }

    _lintAnsible_() {
        # DESC:
        #					Lint Ansible YMAL files staged for commit.  Requires ansible-lint to be installed.
        # ARGS:
        #					$1 (Required):  Path to file
        # OUTS:
        #					 0:  Success
        #					 1:  Failure
        # USAGE:
        #					_lintAnsible_ "/path/to/file.yml"

        [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

        local _filename="$(_fileName_ "${1}")"

        if ! command -v ansible-lint &>/dev/null; then
            notice "ansible-lint not intstalled. Continuing..."
            return 0
        fi

        ANSIBLE_COMMAND="ansible-lint -vv --parseable-severity ${1}"
        if [ -f "$(git rev-parse --show-toplevel)/.ansible-lint.yml" ]; then
            ANSIBLE_COMMAND="ansible-lint -p -c $(git rev-parse --show-toplevel)/.ansible-lint.yml ${1}"
        fi

        debug "${_filename}: Linting ansible..."
        if ${ANSIBLE_COMMAND}; then
            return 0
        else
            return 1
        fi
    }

    # RUN SCRIPT LOGIC

    # Attempt to discern if we are working on a repo that contains ansible files
    IS_ANSIBLE_REPO=false
    if find "$(git rev-parse --show-toplevel)" -mindepth 1 -maxdepth 1 -type f \
        -name "inventory.yml" \
        -o -name "ansible.cfg" \
        -o -name ".ansible-lint.yml" &>/dev/null; then

        IS_ANSIBLE_REPO=true
    fi

    if ! _ignoreSymlinks_; then
        notice "Found symlink in repository. Exiting..."
        _safeExit_ 1
    fi

    while read -r STAGED_FILE; do
        debug "$(_fileName_ "${STAGED_FILE}"): Linting..."

        if [ -f "${STAGED_FILE}" ]; then

            if _gitStopWords_ "${STAGED_FILE}"; then
                info "$(_fileName_ "${STAGED_FILE}"): Passed stopwords lint"
            else
                notice "$(_fileName_ "${STAGED_FILE}"): Failed stopwords lint"
                _safeExit_ 1
            fi

            # YAML Linting
            if [[ ${STAGED_FILE} =~ \.(yaml|yml)$ ]]; then

                if _lintYAML_ "${STAGED_FILE}"; then
                    info "$(_fileName_ "${STAGED_FILE}"): Passed yaml lint"
                else
                    notice "$(_fileName_ "${STAGED_FILE}"): Failed yaml lint"
                    _safeExit_ 1
                fi
            fi

            # Ansible Linting
            #   - Only run in Ansible repos
            #   - Only run on YAML files
            #   - Don't lint files that are not Ansible playbooks
            #   - Don't lint in directory names that are not likely to contain Ansible playbooks
            if [[ ${IS_ANSIBLE_REPO} == true ]] \
                && [[ ${STAGED_FILE} =~ \.(yaml|yml)$ ]] \
                && [[ ! $(_fileName_ "${STAGED_FILE}") =~ (^\.|^requirements|j2|vault\.yml|variables|meta|defaults?|inventory) ]] \
                && [[ ! $(_filePath_ "${STAGED_FILE}") =~ /(handlers|vars/|defaults/|meta/|molecule/|templates/|files/)/ ]]; then

                if _lintAnsible_ "${STAGED_FILE}"; then
                    info "$(_fileName_ "${STAGED_FILE}"): Passed ansible-lint"
                else
                    notice "$(_fileName_ "${STAGED_FILE}"): Failed ansible-lint"
                    _safeExit_ 1
                fi
            fi

            # Shellscript Linting
            if [[ ${STAGED_FILE} =~ \.(bash|sh)$ || "$(head -n 1 "${STAGED_FILE}")" =~ ^#!.*bash$ ]]; then
                if _lintShellscripts_ "${STAGED_FILE}"; then
                    info "$(_fileName_ "${STAGED_FILE}"): Passed shellcheck"
                else
                    notice "$(_fileName_ "${STAGED_FILE}"): Failed shellcheck"
                    _safeExit_ 1
                fi
            fi

            # Run BATS unit tests on individual files if STAGED_FILE.bats exists in test/ directory
            if [[ ${STAGED_FILE} =~ \.(sh|bash|bats|zsh)$ || "$(head -n 1 "${STAGED_FILE}")" =~ ^#!.*bash$ ]]; then

                if [ -f "${GITROOT}/test/$(_fileBasename_ "${STAGED_FILE}").bats" ]; then
                    if _BATS_ "${GITROOT}/test/$(_fileBasename_ "${STAGED_FILE}").bats"; then
                        info "$(_fileName_ "${STAGED_FILE}"): BATS passed"
                    else
                        notice "$(_fileName_ "${STAGED_FILE}"): BATS failed"
                        _safeExit_ 1
                    fi
                fi
            fi
        fi

    done < <(git diff --cached --name-only --line-prefix="$(git rev-parse --show-toplevel)/")

}
# end _mainScript_

# ################################## Flags and defaults
# Script specific
STOP_WORD_FILE="${HOME}/.git_stop_words"
shopt -s nocasematch # Case insensitive matching

# Required variables
LOGFILE="${HOME}/logs/$(basename "$0").log"
QUIET=false
LOGLEVEL=ERROR
VERBOSE=false
FORCE=false
DRYRUN=false
declare -a ARGS=()

# ################################## Custom utility functions (Pasted from repository)
_fileName_() {
    # DESC:
    #					Get only the filename from a string
    # ARGS:
    #					$1 (Required) - Input string
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: Filename with extension
    # USAGE:
    #					_fileName_ "some/path/to/file.txt" --> "file.txt"
    #					_fileName_ "some/path/to/file" --> "file"
    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    printf "%s\n" "${1##*/}"
}

_filePath_() {
    # DESC:
    #					Finds the directory name from a file path. If it exists on filesystem, print
    #         absolute path.  If a string, remove the filename and return the path
    # ARGS:
    #					$1 (Required) - Input string path
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: Directory path
    # USAGE:
    #					_fileDir_ "some/path/to/file.txt" --> "some/path/to"
    # CREDIT:
    #         https://github.com/labbots/bash-utility/

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _tmp=${1}

    if [ -e "${_tmp}" ]; then
        _tmp="$(dirname "$(realpath "${_tmp}")")"
    else
        [[ ${_tmp} != *[!/]* ]] && { printf '/\n' && return; }
        _tmp="${_tmp%%"${_tmp##*[!/]}"}"

        [[ ${_tmp} != */* ]] && { printf '.\n' && return; }
        _tmp=${_tmp%/*} && _tmp="${_tmp%%"${_tmp##*[!/]}"}"
    fi
    printf '%s' "${_tmp:-/}"
}

_fileBasename_() {
    # DESC:
    #					Gets the basename of a file from a file name
    # ARGS:
    #					$1 (Required) - Input string path
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: Filename basename (no extension or path)
    # USAGE:
    #					_fileBasename_ "some/path/to/file.txt" --> "file"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _file
    local _basename
    _file="${1##*/}"
    _basename="${_file%.*}"

    printf "%s" "${_basename}"
}
# ################################## Functions required for this template to work

_setColors_() {
    # DESC:
    #         Sets colors use for alerts.
    # ARGS:
    #         None
    # OUTS:
    #         None
    # USAGE:
    #         echo "${blue}Some text${reset}"

    if tput setaf 1 >/dev/null 2>&1; then
        bold=$(tput bold)
        underline=$(tput smul)
        reverse=$(tput rev)
        reset=$(tput sgr0)

        if [[ $(tput colors) -ge 256 ]] >/dev/null 2>&1; then
            white=$(tput setaf 231)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 11)
            tan=$(tput setaf 3)
            green=$(tput setaf 82)
            red=$(tput setaf 1)
            purple=$(tput setaf 171)
            gray=$(tput setaf 250)
        else
            white=$(tput setaf 7)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 3)
            tan=$(tput setaf 3)
            green=$(tput setaf 2)
            red=$(tput setaf 1)
            purple=$(tput setaf 13)
            gray=$(tput setaf 7)
        fi
    else
        bold="\033[4;37m"
        reset="\033[0m"
        underline="\033[4;37m"
        reverse=""
        white="\033[0;37m"
        blue="\033[0;34m"
        yellow="\033[0;33m"
        tan="\033[0;33m"
        green="\033[1;32m"
        red="\033[0;31m"
        purple="\033[0;35m"
        gray="\033[0;37m"
    fi
}

_alert_() {
    # DESC:
    #         Controls all printing of messages to log files and stdout.
    # ARGS:
    #         $1 (required) - The type of alert to print
    #                         (success, header, notice, dryrun, debug, warning, error,
    #                         fatal, info, input)
    #         $2 (required) - The message to be printed to stdout and/or a log file
    #         $3 (optional) - Pass '${LINENO}' to print the line number where the _alert_ was triggered
    # OUTS:
    #         stdout: The message is printed to stdout
    #         log file: The message is printed to a log file
    # USAGE:
    #         [_alertType] "[MESSAGE]" "${LINENO}"
    # NOTES:
    #         - The colors of each alert type are set in this function
    #         - For specified alert types, the funcstac will be printed

    local _color
    local _alertType="${1}"
    local _message="${2}"
    local _line="${3:-}" # Optional line number

    [[ $# -lt 2 ]] && fatal 'Missing required argument to _alert_'

    if [[ -n ${_line} && ${_alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}(line: ${_line}) $(_printFuncStack_)"
    elif [[ -n ${_line} && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}(line: ${_line})"
    elif [[ -z ${_line} && ${_alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}$(_printFuncStack_)"
    fi

    if [[ ${_alertType} =~ ^(error|fatal) ]]; then
        _color="${bold}${red}"
    elif [ "${_alertType}" == "info" ]; then
        _color="${gray}"
    elif [ "${_alertType}" == "warning" ]; then
        _color="${red}"
    elif [ "${_alertType}" == "success" ]; then
        _color="${green}"
    elif [ "${_alertType}" == "debug" ]; then
        _color="${purple}"
    elif [ "${_alertType}" == "header" ]; then
        _color="${bold}${white}${underline}"
    elif [ ${_alertType} == "notice" ]; then
        _color="${bold}"
    elif [ ${_alertType} == "input" ]; then
        _color="${bold}${underline}"
    elif [ "${_alertType}" = "dryrun" ]; then
        _color="${blue}"
    else
        _color=""
    fi

    _writeToScreen_() {
        ("${QUIET}") && return 0 # Print to console when script is not 'quiet'
        [[ ${VERBOSE} == false && ${_alertType} =~ ^(debug|verbose) ]] && return 0

        if ! [[ -t 1 || -z ${TERM:-} ]]; then # Don't use colors on non-recognized terminals
            _color=""
            reset=""
        fi

        if [[ ${_alertType} == header ]]; then
            printf "${_color}%s${reset}\n" "${_message}"
        else
            printf "${_color}[%7s] %s${reset}\n" "${_alertType}" "${_message}"
        fi
    }
    _writeToScreen_

    _writeToLog_() {
        [[ ${_alertType} == "input" ]] && return 0
        [[ ${LOGLEVEL} =~ (off|OFF|Off) ]] && return 0
        if [ -z "${LOGFILE:-}" ]; then
            LOGFILE="$(pwd)/$(basename "$0").log"
        fi
        [ ! -d "$(dirname "${LOGFILE}")" ] && mkdir -p "$(dirname "${LOGFILE}")"
        [[ ! -f ${LOGFILE} ]] && touch "${LOGFILE}"

        # Don't use colors in logs
        local cleanmessage="$(echo "${_message}" | sed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
        # Print message to log file
        printf "%s [%7s] %s %s\n" "$(date +"%b %d %R:%S")" "${_alertType}" "[$(/bin/hostname)]" "${cleanmessage}" >>"${LOGFILE}"
    }

    # Write specified log level data to logfile
    case "${LOGLEVEL:-ERROR}" in
        ALL | all | All)
            _writeToLog_
            ;;
        DEBUG | debug | Debug)
            _writeToLog_
            ;;
        INFO | info | Info)
            if [[ ${_alertType} =~ ^(error|fatal|warning|info|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        NOTICE | notice | Notice)
            if [[ ${_alertType} =~ ^(error|fatal|warning|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        WARN | warn | Warn)
            if [[ ${_alertType} =~ ^(error|fatal|warning) ]]; then
                _writeToLog_
            fi
            ;;
        ERROR | error | Error)
            if [[ ${_alertType} =~ ^(error|fatal) ]]; then
                _writeToLog_
            fi
            ;;
        FATAL | fatal | Fatal)
            if [[ ${_alertType} =~ ^fatal ]]; then
                _writeToLog_
            fi
            ;;
        OFF | off)
            return 0
            ;;
        *)
            if [[ ${_alertType} =~ ^(error|fatal) ]]; then
                _writeToLog_
            fi
            ;;
    esac

} # /_alert_

error() { _alert_ error "${1}" "${2:-}"; }
warning() { _alert_ warning "${1}" "${2:-}"; }
notice() { _alert_ notice "${1}" "${2:-}"; }
info() { _alert_ info "${1}" "${2:-}"; }
success() { _alert_ success "${1}" "${2:-}"; }
dryrun() { _alert_ dryrun "${1}" "${2:-}"; }
input() { _alert_ input "${1}" "${2:-}"; }
header() { _alert_ header "${1}" "${2:-}"; }
debug() { _alert_ debug "${1}" "${2:-}"; }
fatal() {
    _alert_ fatal "${1}" "${2:-}"
    _safeExit_ "1"
}

_printFuncStack_() {
    # DESC:
    #         Prints the function stack in use. Used for debugging, and error reporting.
    # ARGS:
    #         None
    # OUTS:
    #         stdout: Prints [function]:[file]:[line]
    # NOTE:
    #         Does not print functions from the alert class
    local _i
    _funcStackResponse=()
    for ((_i = 1; _i < ${#BASH_SOURCE[@]}; _i++)); do
        case "${FUNCNAME[$_i]}" in "_alert_" | "_trapCleanup_" | fatal | error | warning | notice | info | debug | dryrun | header | success) continue ;; esac
        _funcStackResponse+=("${FUNCNAME[$_i]}:$(basename ${BASH_SOURCE[$_i]}):${BASH_LINENO[_i - 1]}")
    done
    printf "( "
    printf %s "${_funcStackResponse[0]}"
    printf ' < %s' "${_funcStackResponse[@]:1}"
    printf ' )\n'
}

_safeExit_() {
    # DESC:
    #       Cleanup and exit from a script
    # ARGS:
    #       $1 (optional) - Exit code (defaults to 0)
    # OUTS:
    #       None

    if [[ -d ${SCRIPT_LOCK:-} ]]; then
        if command rm -rf "${SCRIPT_LOCK}"; then
            debug "Removing script lock"
        else
            warning "Script lock could not be removed. Try manually deleting ${tan}'${LOCK_DIR}'"
        fi
    fi

    if [[ -n ${TMP_DIR:-} && -d ${TMP_DIR:-} ]]; then
        if [[ ${1:-} == 1 && -n "$(ls "${TMP_DIR}")" ]]; then
            command rm -r "${TMP_DIR}"
        else
            command rm -r "${TMP_DIR}"
            debug "Removing temp directory"
        fi
    fi

    trap - INT TERM EXIT
    exit ${1:-0}
}

_trapCleanup_() {
    # DESC:
    #         Log errors and cleanup from script when an error is trapped.  Called by 'trap'
    # ARGS:
    #         $1:  Line number where error was trapped
    #         $2:  Line number in function
    #         $3:  Command executing at the time of the trap
    #         $4:  Names of all shell functions currently in the execution call stack
    #         $5:  Scriptname
    #         $6:  $BASH_SOURCE
    # USAGE:
    #         trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM
    # OUTS:
    #         Exits script with error code 1

    local _line=${1:-} # LINENO
    local _linecallfunc=${2:-}
    local _command="${3:-}"
    local _funcstack="${4:-}"
    local _script="${5:-}"
    local _sourced="${6:-}"

    if [[ "$(declare -f "fatal")" && "$(declare -f "_printFuncStack_")" ]]; then
        _funcstack="'$(echo "${_funcstack}" | sed -E 's/ / < /g')'"
        if [[ ${_script##*/} == "${_sourced##*/}" ]]; then
            fatal "${7:-} command: '${_command}' (line: ${_line}) [func: $(_printFuncStack_)]"
        else
            fatal "${7:-} command: '${_command}' (func: ${_funcstack} called at line ${_linecallfunc} of '${_script##*/}') (line: ${_line} of '${_sourced##*/}') "
        fi
    else
        printf "%s\n" "Fatal error trapped. Exiting..."
    fi

    if [ "$(declare -f "_safeExit_")" ]; then
        _safeExit_ 1
    else
        exit 1
    fi
}

_makeTempDir_() {
    # DESC:
    #         Creates a temp directory to house temporary files
    # ARGS:
    #         $1 (Optional) - First characters/word of directory name
    # OUTS:
    #         Sets $TMP_DIR variable to the path of the temp directory
    # USAGE:
    #         _makeTempDir_ "$(basename "$0")"

    [ -d "${TMP_DIR:-}" ] && return 0

    if [ -n "${1:-}" ]; then
        TMP_DIR="${TMPDIR:-/tmp/}${1}.${RANDOM}.${RANDOM}.$$"
    else
        TMP_DIR="${TMPDIR:-/tmp/}$(basename "$0").${RANDOM}.${RANDOM}.${RANDOM}.$$"
    fi
    (umask 077 && mkdir "${TMP_DIR}") || {
        fatal "Could not create temporary directory! Exiting."
    }
    debug "\$TMP_DIR=${TMP_DIR}"
}

_acquireScriptLock_() {
    # DESC:
    #         Acquire script lock to prevent running the same script a second time before the
    #         first instance exits
    # ARGS:
    #         $1 (optional) - Scope of script execution lock (system or user)
    # OUTS:
    #         exports $SCRIPT_LOCK - Path to the directory indicating we have the script lock
    #         Exits script if lock cannot be acquired
    # NOTE:
    #         If the lock was acquired it's automatically released in _safeExit_()

    local _lockDir
    if [[ ${1:-} == 'system' ]]; then
        _lockDir="${TMPDIR:-/tmp/}$(basename "$0").lock"
    else
        _lockDir="${TMPDIR:-/tmp/}$(basename "$0").$UID.lock"
    fi

    if command mkdir "${LOCK_DIR}" 2>/dev/null; then
        readonly SCRIPT_LOCK="${_lockDir}"
        debug "Acquired script lock: ${yellow}${SCRIPT_LOCK}${purple}"
    else
        if [ "$(declare -f "_safeExit_")" ]; then
            error "Unable to acquire script lock: ${tan}${LOCK_DIR}${red}"
            fatal "If you trust the script isn't running, delete the lock dir"
        else
            printf "%s\n" "ERROR: Could not acquire script lock. If you trust the script isn't running, delete: ${LOCK_DIR}"
            exit 1
        fi

    fi
}

_setPATH_() {
    # DESC:
    #         Add directories to $PATH so script can find executables
    # ARGS:
    #         $@ - One or more paths
    # OUTS:   Adds items to $PATH
    # USAGE:
    #         _setPATH_ "/usr/local/bin" "${HOME}/bin" "$(npm bin)"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _newPath

    for _newPath in "$@"; do
        if [ -d "${_newPath}" ]; then
            if ! echo "${PATH}" | grep -Eq "(^|:)${_newPath}($|:)"; then
                if PATH="${_newPath}:${PATH}"; then
                    debug "Added '${_newPath}' to PATH"
                else
                    return 1
                fi
            else
                debug "_setPATH_: '${_newPath}' already exists in PATH"
            fi
        else
            debug "_setPATH_: can not find: ${_newPath}"
            return 0
        fi
    done
    return 0
}

_useGNUutils_() {
    # DESC:
    #					Add GNU utilities to PATH to allow consistent use of sed/grep/tar/etc. on MacOS
    # ARGS:
    #					None
    # OUTS:
    #					0 if successful
    #         1 if unsuccessful
    #         PATH: Adds GNU utilities to the path
    # USAGE:
    #					# if ! _useGNUUtils_; then exit 1; fi
    # NOTES:
    #					GNU utilities can be added to MacOS using Homebrew

    [ ! "$(declare -f "_setPATH_")" ] && fatal "${FUNCNAME[0]} needs function _setPATH_"

    if _setPATH_ \
        "/usr/local/opt/gnu-tar/libexec/gnubin" \
        "/usr/local/opt/coreutils/libexec/gnubin" \
        "/usr/local/opt/gnu-sed/libexec/gnubin" \
        "/usr/local/opt/grep/libexec/gnubin"; then
        return 0
    else
        return 1
    fi

}

_parseOptions_() {
    # DESC:
    #					Iterates through options passed to script and sets variables. Will break -ab into -a -b
    #         when needed and --foo=bar into --foo bar
    # ARGS:
    #					$@ from command line
    # OUTS:
    #					Sets array 'ARGS' containing all arguments passed to script that were not parsed as options
    # USAGE:
    #					_parseOptions_ "$@"

    # Iterate over options
    local _optstring=h
    declare -a _options
    local _c
    local i
    while (($#)); do
        case $1 in
            # If option is of type -ab
            -[!-]?*)
                # Loop over each character starting with the second
                for ((i = 1; i < ${#1}; i++)); do
                    _c=${1:i:1}
                    _options+=("-${_c}") # Add current char to options
                    # If option takes a required argument, and it's not the last char make
                    # the rest of the string its argument
                    if [[ ${_optstring} == *"${_c}:"* && ${1:i+1} ]]; then
                        _options+=("${1:i+1}")
                        break
                    fi
                done
                ;;
            # If option is of type --foo=bar
            --?*=*) _options+=("${1%%=*}" "${1#*=}") ;;
            # add --endopts for --
            --) _options+=(--endopts) ;;
            # Otherwise, nothing special
            *) _options+=("$1") ;;
        esac
        shift
    done
    set -- "${_options[@]:-}"
    unset _options

    # Read the options and set stuff
    while [[ ${1:-} == -?* ]]; do
        case $1 in
            # Custom options

            # Common options
            -h | --help)
                _usage_
                _safeExit_
                ;;
            --loglevel)
                shift
                LOGLEVEL=${1}
                ;;
            --logfile)
                shift
                LOGFILE="${1}"
                ;;
            -n | --dryrun) DRYRUN=true ;;
            -v | --verbose) VERBOSE=true ;;
            -q | --quiet) QUIET=true ;;
            --force) FORCE=true ;;
            --endopts)
                shift
                break
                ;;
            *)
                if [ "$(declare -f "_safeExit_")" ]; then
                    fatal "invalid option: $1"
                else
                    printf "%s\n" "Invalid option: $1"
                    exit 1
                fi
                ;;
        esac
        shift
    done

    if [[ -z ${*} || ${*} == null ]]; then
        ARGS=()
    else
        ARGS+=("$@") # Store the remaining user input as arguments.
    fi
}

_usage_() {
    cat <<USAGE_TEXT

  ${bold}$(basename "$0") [OPTION]...${reset}

  This script runs a number of automated tests on files that are staged in Git prior to
  allowing them to be committed

  ${bold}Options:${reset}
    -h, --help              Display this help and exit
    --loglevel [LEVEL]      One of: FATAL, ERROR, WARN, INFO, NOTICE, DEBUG, ALL, OFF
                            (Default is 'ERROR')
    --logfile [FILE]        Full PATH to logfile.  (Default is '${HOME}/logs/$(basename "$0").log')
    -n, --dryrun            Non-destructive. Makes no permanent changes.
    -q, --quiet             Quiet (no output)
    -v, --verbose           Output more information. (Items echoed to 'verbose')
    --force                 Skip all user interaction.  Implied 'Yes' to all actions.

  ${bold}Example Usage:${reset}

      ${gray}# Run the script and specify log level and log file.${reset}
      $(basename "$0") -vn --logfile "/path/to/file.log" --loglevel 'WARN'
USAGE_TEXT
}

# ################################## INITIALIZE AND RUN THE SCRIPT
#                                    (Comment or uncomment the lines below to customize script behavior)

trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM

# Trap errors in subshells and functions
set -o errtrace

# Exit on error. Append '||true' if you expect an error
set -o errexit

# Use last non-zero exit code in a pipeline
set -o pipefail

# Confirm we have BASH greater than v4
[ "${BASH_VERSINFO:-0}" -ge 4 ] || {
    printf "%s\n" "ERROR: BASH_VERSINFO is '${BASH_VERSINFO:-0}'.  This script requires BASH v4 or greater."
    exit 1
}

# Make `for f in *.txt` work when `*.txt` matches zero files
shopt -s nullglob globstar

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode
# set -o xtrace

# Initialize color constants
_setColors_

# Disallow expansion of unset variables
set -o nounset

# Force arguments when invoking the script
# [[ $# -eq 0 ]] && _parseOptions_ "-h"

# Parse arguments passed to script
_parseOptions_ "$@"

# Create a temp directory '$TMP_DIR'
_makeTempDir_ "$(basename "$0")"

# Acquire script lock
# _acquireScriptLock_

# Source GNU utilities for use on MacOS
_useGNUutils_

# Run the main logic script
_mainScript_

# Exit cleanly
_safeExit_
