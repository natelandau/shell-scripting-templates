# Functions for manipulating files

_backupFile_() {
    # DESC:
    #         Creates a backup of a specified file with .bak extension or optionally to a
    #         specified directory
    # ARGS:
    #         $1 (Required)   - Source file
    #         $2 (Optional)   - Destination dir name used only with -d flag (defaults to ./backup)
    # OPTS:
    #         -d  - Move files to a backup directory
    #         -m  - Replaces copy (default) with move, effectively removing the original file
    # REQUIRES:
    #         _execute_
    #         _createUniqueFilename_
    # OUTS:
    #         0 - Success
    #         1 - Error
    #         filesystem: Backup of files
    # USAGE:
    #         _backupFile_ "sourcefile.txt" "some/backup/dir"
    # NOTE:
    #         Dotfiles have their leading '.' removed in their backup

    local opt
    local OPTIND=1
    local _useDirectory=false
    local _moveFile=false

    while getopts ":dDmM" opt; do
        case ${opt} in
            d | D) _useDirectory=true ;;
            m | M) _moveFile=true ;;
            *)
                {
                    error "Unrecognized option '${1}' passed to _backupFile_" "${LINENO}"
                    return 1
                }
                ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _fileToBackup="${1}"
    local _backupDir="${2:-backup}"
    local _newFilename

    # Error handling
    declare -f _execute_ &>/dev/null || fatal "_backupFile_ needs function _execute_"
    declare -f _createUniqueFilename_ &>/dev/null || fatal "_backupFile_ needs function _createUniqueFilename_"

    [ ! -e "${_fileToBackup}" ] \
        && {
            debug "Source '${_fileToBackup}' not found"
            return 1
        }

    if [[ ${_useDirectory} == true ]]; then

        [ ! -d "${_backupDir}" ] \
            && _execute_ "mkdir -p \"${_backupDir}\"" "Creating backup directory"

        _newFilename="$(_createUniqueFilename_ "${_backupDir}/${_fileToBackup#.}")"
        if [[ ${_moveFile} == true ]]; then
            _execute_ "mv \"${_fileToBackup}\" \"${_backupDir}/${_newFilename##*/}\"" "Moving: '${_fileToBackup}' to '${_backupDir}/${_newFilename##*/}'"
        else
            _execute_ "cp -R \"${_fileToBackup}\" \"${_backupDir}/${_newFilename##*/}\"" "Backing up: '${_fileToBackup}' to '${_backupDir}/${_newFilename##*/}'"
        fi
    else
        _newFilename="$(_createUniqueFilename_ "${_fileToBackup}.bak")"
        if [[ ${_moveFile} == true ]]; then
            _execute_ "mv \"${_fileToBackup}\" \"${_newFilename}\"" "Moving '${_fileToBackup}' to '${_newFilename}'"
        else
            _execute_ "cp -R \"${_fileToBackup}\" \"${_newFilename}\"" "Backing up '${_fileToBackup}' to '${_newFilename}'"
        fi
    fi
}

_createUniqueFilename_() {
    # DESC:
    #         Ensure a file to be created has a unique filename to avoid overwriting other
    #         filenames by incrementing a number at the end of the filename
    # ARGS:
    #         $1 (Required) - Name of file to be created
    #         $2 (Optional) - Separation character (Defaults to a period '.')
    # OUTS:
    #         stdout: Unique name of file
    #         0 if successful
    #         1 if not successful
    # OPTS:
    #         -i:   Places the unique integer before the file extension
    # USAGE:
    #         _createUniqueFilename_ "/some/dir/file.txt" --> /some/dir/file.txt.1
    #         _createUniqueFilename_ -i"/some/dir/file.txt" "-" --> /some/dir/file-1.txt
    #         printf "%s" "line" > "$(_createUniqueFilename_ "/some/dir/file.txt")"

    [[ $# -lt 1 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local opt
    local OPTIND=1
    local _internalInteger=false
    while getopts ":iI" opt; do
        case ${opt} in
            i | I) _internalInteger=true ;;
            *)
                error "Unrecognized option '${1}' passed to ${FUNCNAME[0]}" "${LINENO}"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _fullFile="${1}"
    local _spacer="${2:-.}"
    local _filePath
    local _originalFile
    local _extension
    local _newFilename
    local _num
    local _levels
    local _fn
    local _ext
    local i

    # Find directories with realpath if input is an actual file
    if [ -e "${_fullFile}" ]; then
        _fullFile="$(realpath "${_fullFile}")"
    fi

    _filePath="$(dirname "${_fullFile}")"
    _originalFile="$(basename "${_fullFile}")"

    #shellcheck disable=SC2064
    trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
    shopt -s nocasematch                  # Use case-insensitive regex

    # Detect some common multi-extensions
    case $(tr '[:upper:]' '[:lower:]' <<<"${_originalFile}") in
        *.tar.gz | *.tar.bz2) _levels=2 ;;
        *) _levels=1 ;;
    esac

    # Find Extension
    _fn="${_originalFile}"
    for ((i = 0; i < _levels; i++)); do
        _ext=${_fn##*.}
        if [[ ${i} == 0 ]]; then
            _extension=${_ext}${_extension:-}
        else
            _extension=${_ext}.${_extension:-}
        fi
        _fn=${_fn%."${_ext}"}
    done

    if [[ ${_extension} == "${_originalFile}" ]]; then
        _extension=""
    else
        _originalFile="${_originalFile%."${_extension}"}"
        _extension=".${_extension}"
    fi

    _newFilename="${_filePath}/${_originalFile}${_extension:-}"

    if [ -e "${_newFilename}" ]; then
        _num=1
        if [ "${_internalInteger}" = true ]; then
            while [[ -e "${_filePath}/${_originalFile}${_spacer}${_num}${_extension:-}" ]]; do
                ((_num++))
            done
            _newFilename="${_filePath}/${_originalFile}${_spacer}${_num}${_extension:-}"
        else
            while [[ -e "${_filePath}/${_originalFile}${_extension:-}${_spacer}${_num}" ]]; do
                ((_num++))
            done
            _newFilename="${_filePath}/${_originalFile}${_extension:-}${_spacer}${_num}"
        fi
    fi

    printf "%s\n" "${_newFilename}"
    return 0
}

_decryptFile_() {
    # DESC:
    #         Decrypts a file with openSSL
    # ARGS:
    #         $1 (Required) - File to be decrypted
    #         $2 (Optional) - Name of output file (defaults to $1.decrypt)
    # OUTS:
    #         0 - Success
    #         1 - Error
    # REQUIRES:
    #         _execute_
    # USAGE:
    #         _decryptFile_ "somefile.txt.enc" "decrypted_somefile.txt"
    # NOTE:
    #         If a global variable '$PASS' has a value, we will use that as the password to decrypt
    #         the file. Otherwise we will ask

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _fileToDecrypt="${1:?_decryptFile_ needs a file}"
    local _defaultName="${_fileToDecrypt%.enc}"
    local _decryptedFile="${2:-${_defaultName}.decrypt}"

    declare -f _execute_ &>/dev/null || fatal "${FUNCNAME[0]} needs function _execute_"

    if ! command -v openssl &>/dev/null; then
        fatal "openssl not found"
    fi

    [ ! -f "${_fileToDecrypt}" ] && return 1

    if [ -z "${PASS:-}" ]; then
        _execute_ "openssl enc -aes-256-cbc -d -in \"${_fileToDecrypt}\" -out \"${_decryptedFile}\"" "Decrypt ${_fileToDecrypt}"
    else
        _execute_ "openssl enc -aes-256-cbc -d -in \"${_fileToDecrypt}\" -out \"${_decryptedFile}\" -k \"${PASS}\"" "Decrypt ${_fileToDecrypt}"
    fi
}

_encryptFile_() {
    # DESC:
    #         Encrypts a file using openSSL
    # ARGS:
    #         $1 (Required) - Input file
    #         $2 (Optional) - Name of output file (defaults to $1.enc)
    # OUTS:
    #         None
    # REQUIRE:
    #         _execute_
    # USAGE:
    #         _encryptFile_ "somefile.txt" "encrypted_somefile.txt"
    # NOTE:
    #         If a variable '$PASS' has a value, we will use that as the password
    #         for the encrypted file. Otherwise ask.

    local _fileToEncrypt="${1:?_encodeFile_ needs a file}"
    local _defaultName="${_fileToEncrypt%.decrypt}"
    local _encryptedFile="${2:-${_defaultName}.enc}"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [ ! -f "${_fileToEncrypt}" ] && return 1

    declare -f _execute_ &>/dev/null || fatal "${FUNCNAME[0]} needs function _execute_"

    if ! command -v openssl &>/dev/null; then
        fatal "openssl not found"
    fi

    if [ -z "${PASS:-}" ]; then
        _execute_ "openssl enc -aes-256-cbc -salt -in \"${_fileToEncrypt}\" -out \"${_encryptedFile}\"" "Encrypt ${_fileToEncrypt}"
    else
        _execute_ "openssl enc -aes-256-cbc -salt -in \"${_fileToEncrypt}\" -out \"${_encryptedFile}\" -k \"${PASS}\"" "Encrypt ${_fileToEncrypt}"
    fi
}

_extractArchive_() {
    # DESC:
    #         Extract a compressed file
    # ARGS:
    #         $1 (Required) - Input file
    #         $2 (optional) - Input 'v' to show verbose output
    # OUTS:
    #         0 - Success
    #         1 - Error

    local _vv

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    [[ ${2:-} == "v" ]] && _vv="v"

    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2 | *.tbz | *.tbz2) tar "x${_vv}jf" "$1" ;;
            *.tar.gz | *.tgz) tar "x${_vv}zf" "$1" ;;
            *.tar.xz)
                xz --decompress "$1"
                set -- "$@" "${1:0:-3}"
                ;;
            *.tar.Z)
                uncompress "$1"
                set -- "$@" "${1:0:-2}"
                ;;
            *.bz2) bunzip2 "$1" ;;
            *.deb) dpkg-deb -x"${_vv}" "$1" "${1:0:-4}" ;;
            *.pax.gz)
                gunzip "$1"
                set -- "$@" "${1:0:-3}"
                ;;
            *.gz) gunzip "$1" ;;
            *.pax) pax -r -f "$1" ;;
            *.pkg) pkgutil --expand "$1" "${1:0:-4}" ;;
            *.rar) unrar x "$1" ;;
            *.rpm) rpm2cpio "$1" | cpio -idm"${_vv}" ;;
            *.tar) tar "x${_vv}f" "$1" ;;
            *.txz)
                mv "$1" "${1:0:-4}.tar.xz"
                set -- "$@" "${1:0:-4}.tar.xz"
                ;;
            *.xz) xz --decompress "$1" ;;
            *.zip | *.war | *.jar) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7za x "$1" ;;
            *) return 1 ;;
        esac
    else
        return 1
    fi
}

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

_fileExtension_() {
    # DESC:
    #					Gets an extension from a file name. Finds a few common double extensions (tar.gz, tar.bz2, log.1)
    # ARGS:
    #					$1 (Required) - Input string path
    # OUTS:
    #					0 - Success
    #					1 - If no extension found in filename
    #					stdout: extension (without the .)
    # USAGE:
    #					_fileExtension_ "some/path/to/file.txt" --> "txt"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _file
    local _extension
    local _levels
    local _ext
    local _exts
    _file="${1##*/}"

    # Detect some common multi-extensions
    if [[ -z ${_levels:-} ]]; then
        case $(tr '[:upper:]' '[:lower:]' <<<"${_file}") in
            *.tar.gz | *.tar.bz2 | *.log.[0-9]) _levels=2 ;;
            *) _levels=1 ;;
        esac
    fi

    _fn="${_file}"
    for ((i = 0; i < _levels; i++)); do
        _ext=${_fn##*.}
        if [[ ${i} == 0 ]]; then
            _exts=${_ext}${_exts:-}
        else
            _exts=${_ext}.${_exts:-}
        fi
        _fn=${_fn%."${_ext}"}
    done
    [[ ${_file} == "${_exts}" ]] && return 1

    printf "%s" "${_exts}"

}

_filePath_() {
    # DESC:
    #		  Finds the directory name from a file path. If it exists on filesystem, print
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

_fileContains_() {
    # DESC:
    #					Searches a file for a given pattern using default grep patterns
    # ARGS:
    #					$1 (Required) - Input file
    #					$2 (Required) - Pattern to search for
    # OUTS:
    #					0 - Pattern found in file
    #					1 - Pattern not found in file
    # USAGE:
    #					_fileContains_ "./file.sh" "^[:alpha:]*"

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _file="$1"
    local _text="$2"
    grep -q "${_text}" "${_file}"
}

_json2yaml_() {
    # DESC:
    #         Convert JSON to YAML
    # ARGS:
    #         $1 (Required) - JSON file
    # OUTS:
    #         stdout: YAML from the JSON input

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' <"${1}"
}

_listFiles_() {
    # DESC:
    #         Find files in a directory.  Use either glob or regex
    # ARGS:
    #         $1 (Required) - 'g|glob' or 'r|regex'
    #         $2 (Required) - pattern to match
    #         $3 (Optional) - directory (defaults to .)
    # OUTS:
    #         0: if files found
    #         1: if no files found
    #         stdout: List of files
    # NOTE:
    #         Searches are NOT case sensitive and MUST be quoted
    # USAGE:
    #         _listFiles_ glob "*.txt" "some/backup/dir"
    #         _listFiles_ regex ".*\.[sha256|md5|txt]" "some/backup/dir"
    #         readarray -t array < <(_listFiles_ g "*.txt")

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _searchType="${1}"
    local _pattern="${2}"
    local _directory="${3:-.}"
    local _fileMatch
    declare -a _matchedFiles=()

    case "${_searchType}" in
        [Gg]*)
            while read -r _fileMatch; do
                _matchedFiles+=("$(realpath "${_fileMatch}")")
            done < <(find "${_directory}" -maxdepth 1 -iname "${_pattern}" -type f | sort)
            ;;
        [Rr]*)
            while read -r _fileMatch; do
                _matchedFiles+=("$(realpath "${_fileMatch}")")
            done < <(find "${_directory}" -maxdepth 1 -regextype posix-extended -iregex "${_pattern}" -type f | sort)
            ;;
        *)
            fatal "_listFiles_: Could not determine if search was glob or regex"
            ;;
    esac

    if [[ ${#_matchedFiles[@]} -gt 0 ]]; then
        printf "%s\n" "${_matchedFiles[@]}"
        return 0
    else
        return 1
    fi
}

_makeSymlink_() {
    # DESC:
    #         Creates a symlink and backs up a file which may be overwritten by the new symlink. If the
    #         exact same symlink already exists, nothing is done.
    #         Default behavior will create a backup of a file to be overwritten
    # ARGS:
    #         $1 (Required) - Source file
    #         $2 (Required) - Destination
    # OPTS:
    #         -c  - Only report on new/changed symlinks.  Quiet when nothing done.
    #         -n  - Do not create a backup if target already exists
    #         -s  - Use sudo when removing old files to make way for new symlinks
    # OUTS:
    #         0 - Success
    #         1 - Error
    #         Filesystem: Create's symlink if required
    # USAGE:
    #         _makeSymlink_ "/dir/someExistingFile" "/dir/aNewSymLink" "/dir/backup/location"

    local opt
    local OPTIND=1
    local _backupOriginal=true
    local _useSudo=false
    local _onlyShowChanged=false

    while getopts ":cCnNsS" opt; do
        case ${opt} in
            n | N) _backupOriginal=false ;;
            s | S) _useSudo=true ;;
            c | C) _onlyShowChanged=true ;;
            *) fatal "Missing required argument to ${FUNCNAME[0]}" ;;
        esac
    done
    shift $((OPTIND - 1))

    declare -f _execute_ &>/dev/null || fatal "${FUNCNAME[0]} needs function _execute_"
    declare -f _backupFile_ &>/dev/null || fatal "${FUNCNAME[0]} needs function _backupFile_"

    if ! command -v realpath >/dev/null 2>&1; then
        error "We must have 'realpath' installed and available in \$PATH to run."
        if [[ ${OSTYPE} == "darwin"* ]]; then
            notice "Install coreutils using homebrew and rerun this script."
            info "\t$ brew install coreutils"
        fi
        _safeExit_ 1
    fi

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _sourceFile="$1"
    local _destinationFile="$2"
    local _originalFile

    # Fix files where $HOME is written as '~'
    _destinationFile="${_destinationFile/\~/${HOME}}"
    _sourceFile="${_sourceFile/\~/${HOME}}"

    [ ! -e "${_sourceFile}" ] \
        && {
            error "'${_sourceFile}' not found"
            return 1
        }
    [ -z "${_destinationFile}" ] \
        && {
            error "'${_destinationFile}' not specified"
            return 1
        }

    # Create destination directory if needed
    [ ! -d "${_destinationFile%/*}" ] \
        && _execute_ "mkdir -p \"${_destinationFile%/*}\""

    if [ ! -e "${_destinationFile}" ]; then
        _execute_ "ln -fs \"${_sourceFile}\" \"${_destinationFile}\"" "symlink ${_sourceFile} → ${_destinationFile}"
    elif [ -h "${_destinationFile}" ]; then
        _originalFile="$(realpath "${_destinationFile}")"

        [[ ${_originalFile} == "${_sourceFile}" ]] && {
            if [[ ${_onlyShowChanged} == true ]]; then
                debug "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
            elif [[ ${DRYRUN:-} == true ]]; then
                dryrun "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
            else
                info "Symlink already exists: ${_sourceFile} → ${_destinationFile}"
            fi
            return 0
        }

        if [[ ${_backupOriginal} == true ]]; then
            _backupFile_ "${_destinationFile}"
        fi
        if [[ ${DRYRUN} == false ]]; then
            if [[ ${_useSudo} == true ]]; then
                command rm -rf "${_destinationFile}"
            else
                command rm -rf "${_destinationFile}"
            fi
        fi
        _execute_ "ln -fs \"${_sourceFile}\" \"${_destinationFile}\"" "symlink ${_sourceFile} → ${_destinationFile}"
    elif [ -e "${_destinationFile}" ]; then
        if [[ ${_backupOriginal} == true ]]; then
            _backupFile_ "${_destinationFile}"
        fi
        if [[ ${DRYRUN} == false ]]; then
            if [[ ${_useSudo} == true ]]; then
                sudo command rm -rf "${_destinationFile}"
            else
                command rm -rf "${_destinationFile}"
            fi
        fi
        _execute_ "ln -fs \"${_sourceFile}\" \"${_destinationFile}\"" "symlink ${_sourceFile} → ${_destinationFile}"
    else
        warning "Error linking: ${_sourceFile} → ${_destinationFile}"
        return 1
    fi
    return 0
}

_parseYAML_() {
    # DESC:
    #         Convert a YAML file into BASH variables for use in a shell script
    # ARGS:
    #         $1 (Required) - Source YAML file
    #         $2 (Required) - Prefix for the variables to avoid namespace collisions
    # OUTS:
    #         Prints variables and arrays derived from YAML File
    # USAGE:
    #         To source into a script
    #         _parseYAML_ "sample.yml" "CONF_" > tmp/variables.txt
    #         source "tmp/variables.txt"
    #
    # NOTE:
    #         https://gist.github.com/DinoChiesa/3e3c3866b51290f31243
    #         https://gist.github.com/epiloque/8cf512c6d64641bde388

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _yamlFile="${1}"
    local _prefix="${2:-}"

    [ ! -s "${_yamlFile}" ] && return 1

    local _s='[[:space:]]*'
    local _w='[a-zA-Z0-9_]*'
    local _fs
    _fs="$(printf @ | tr @ '\034')"

    sed -ne "s|^\(${_s}\)\(${_w}\)${_s}:${_s}\"\(.*\)\"${_s}\$|\1${_fs}\2${_fs}\3|p" \
        -e "s|^\(${_s}\)\(${_w}\)${_s}[:-]${_s}\(.*\)${_s}\$|\1${_fs}\2${_fs}\3|p" "${_yamlFile}" \
        | awk -F"${_fs}" '{
    indent = length($1)/2;
    if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s%s=(\"%s\")\n", "'"${_prefix}"'",vn, $2, conj[indent-1],$3);
    }
  }' | sed 's/__=/+=/g' | sed 's/_=/+=/g' | sed 's/[[:space:]]*#.*"/"/g' | sed 's/=("--")//g'
}

_printFileBetween_() (
    # DESC:
    #					Prints text of a file between two regex patterns
    # ARGS:
    #					$1 (Required):	Starting regex pattern
    #					$2 (Required):	Ending regex pattern
    #					$3 (Required):	Input string
    # OPTIONS:
    #         -i (Optional) - Case-insensitive regex
    #         -r (Optional) - Remove first and last lines (ie - the lines which matched the patterns)
    #         -g (Optional) - Greedy regex (Defaults to non-greedy)
    # OUTS:
    #					 0:  Success
    #					 1:  Failure
    #					stdout: Prints text between two regex patterns
    # USAGE:
    #					_printFileBetween_ "^pattern1$" "^pattern2$" "String or variable containing a string"

    [[ $# -lt 3 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _removeLines=false
    local _greedy=false
    local _caseInsensitive=false
    local opt
    local OPTIND=1
    while getopts ":iIrRgG" opt; do
        case ${opt} in
            i | I) _caseInsensitive=true ;;
            r | R) _removeLines=true ;;
            g | G) _greedy=true ;;
            *) fatal "Unrecognized option '${1}' passed to ${FUNCNAME[0]}. Exiting." ;;
        esac
    done
    shift $((OPTIND - 1))

    local _startRegex="${1}"
    local _endRegex="${2}"
    local _input="${3}"
    local _output

    if [[ ${_removeLines} == true ]]; then
        if [[ ${_greedy} == true ]]; then
            if [[ ${_caseInsensitive} == true ]]; then
                _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/Ip" "${_input}" | sed -n '2,$p' | sed '$d')"
            else
                _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/p" "${_input}" | sed -n '2,$p' | sed '$d')"
            fi
        else
            if [[ ${_caseInsensitive} == true ]]; then
                _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/I{p;/${_endRegex}/Iq}" "${_input}" | sed -n '2,$p' | sed '$d')"
            else
                _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/{p;/${_endRegex}/q}" "${_input}" | sed -n '2,$p' | sed '$d')"
            fi
        fi
    else
        if [[ ${_greedy} == true ]]; then
            if [[ ${_caseInsensitive} == true ]]; then
                _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/Ip" "${_input}")"
            else
                _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/p" "${_input}")"
            fi
        else
            if [[ ${_caseInsensitive} == true ]]; then
                _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/I{p;/${_endRegex}/Iq}" "${_input}")"
            else
                _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/{p;/${_endRegex}/q}" "${_input}")"
            fi
        fi
    fi

    if [[ -n ${_output:-} ]]; then
        printf "%s\n" "${_output}"
        return 0
    else
        return 1
    fi
)

_randomLineFromFile_() {
    # DESC:
    #         Returns a random line from a file
    # ARGS:
    #         $1 (Required) - Input file
    # OUTS:
    #         Returns random line from file
    # USAGE:
    #         _randomLineFromFile_ "file.txt"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _fileToRead="$1"
    local _rnd

    [ ! -f "${_fileToRead}" ] \
        && {
            error "'${_fileToRead}' not found"
            return 1
        }

    _rnd=$((1 + RANDOM % $(wc -l <"${_fileToRead}")))
    sed -n "${_rnd}p" "${_fileToRead}"
}

_readFile_() {
    # DESC:
    #         Prints each line of a file
    # ARGS:
    #         $1 (Required) - Input file
    # OUTS:
    #         Prints contents of file
    # USAGE:
    #         _readFile_ "file.txt"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _result
    local _fileToRead="$1"

    [ ! -f "${_fileToRead}" ] \
        && {
            error "'${_fileToRead}' not found"
            return 1
        }

    while read -r _result; do
        printf "%s\n" "${_result}"
    done <"${_fileToRead}"
}

_sourceFile_() {
    # DESC:
    #         Source a file into a script safely.  Will exit script if the file does not exist.
    # ARGS:
    #         $1 (Required) - File to be sourced
    # OUTS:
    #         0 if file sourced successfully
    #         exit script if file not sourced

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _fileToSource="$1"

    [ ! -f "${_fileToSource}" ] && fatal "Attempted to source '${_fileToSource}'. Not found"
    # shellcheck disable=SC1090
    if source "${_fileToSource}"; then
        return 0
    else
        fatal "Failed to source: ${_fileToSource}"
    fi
}

_yaml2json_() {
    # DESC:
    #         Convert a YAML file to JSON
    # ARGS:
    #         $1 (Required) - Input YAML file
    # OUTS:
    #         stdout: JSON

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' <"${1:?_yaml2json_ needs a file}"
}
