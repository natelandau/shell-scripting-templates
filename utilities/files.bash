_listFiles_() {
  # DESC:  Find files in a directory.  Use either glob or regex
  # ARGS:  $1 (Required) - 'g|glob' or 'r|regex'
  #        $2 (Required) - pattern to match
  #        $3 (Optional) - directory
  # OUTS:  Prints files to STDOUT
  # NOTE:  Searches are NOT case sensitive and MUST be quoted
  # USAGE: _listFiles_ glob "*.txt" "some/backup/dir"
  #        _listFiles_ regex ".*\.txt" "some/backup/dir"
  #        readarry -t array < <(_listFiles_ g "*.txt")

  [[ $# -lt 2 ]] && {
    error 'Missing required argument to _listFiles_()!'
    return 1
  }

  local t="${1}"
  local p="${2}"
  local d="${3:-.}"
  local fileMatch e

  case "$t" in
    glob | Glob | g | G)
      while read -r fileMatch; do
        e="$(realpath "${fileMatch}")"
        echo "${e}"
      done < <(find "${d}" -iname "${p}" -type f -maxdepth 1 | sort)
      ;;
    regex | Regex | r | R)
      while read -r fileMatch; do
        e="$(realpath "${fileMatch}")"
        echo "${e}"
      done < <(find "${d}" -iregex "${p}" -type f -maxdepth 1 | sort)
      ;;
    *)
      echo "Could not determine if search was glob or regex"
      return 1
      ;;
  esac
}

_backupFile_() {
  # DESC:   Creates a backup of a specified file with .bak extension or
  #         optionally to a specified directory
  # ARGS:   $1 (Required)   - Source file
  #         $2 (Optional)   - Destination dir name used only with -d flag (defaults to ./backup)
  # OPTS:   -d              - Move files to a backup direcory
  #         -m              - Replaces copy (default) with move, effectively removing the
  # OUTS:   None
  # USAGE:  _backupFile_ "sourcefile.txt" "some/backup/dir"
  # NOTE:   dotfiles have their leading '.' removed in their backup

  local opt
  local OPTIND=1
  local useDirectory=false
  local moveFile=false

  while getopts ":dDmM" opt; do
    case ${opt} in
      d | D) useDirectory=true ;;
      m | M) moveFile=true ;;
      *)
        {
          error "Unrecognized option '$1' passed to _makeSymlink_" "${LINENO}"
          return 1
        }
        ;;
    esac
  done
  shift $((OPTIND - 1))

  [[ $# -lt 1 ]] && fatal 'Missing required argument to _backupFile_()!'

  local s="${1}"
  local d="${2:-backup}"
  local n # New filename (created by _uniqueFilename_)

  # Error handling
  [ ! "$(declare -f "_execute_")" ] \
    && {
      warning "need function _execute_"
      return 1
    }
  [ ! "$(declare -f "_uniqueFileName_")" ] \
    && {
      warning "need function _uniqueFileName_"
      return 1
    }
  [ ! -e "$s" ] \
    && {
      warning "Source '${s}' not found"
      return 1
    }

  if [ ${useDirectory} == true ]; then

    [ ! -d "${d}" ] \
      && _execute_ "mkdir -p \"${d}\"" "Creating backup directory"

    if [ -e "$s" ]; then
      n="$(basename "${s}")"
      n="$(_uniqueFileName_ "${d}/${s#.}")"
      if [ ${moveFile} == true ]; then
        _execute_ "mv \"${s}\" \"${d}/${n##*/}\"" "Moving: '${s}' to '${d}/${n##*/}'"
      else
        _execute_ "cp -R \"${s}\" \"${d}/${n##*/}\"" "Backing up: '${s}' to '${d}/${n##*/}'"
      fi
    fi
  else
    n="$(_uniqueFileName_ "${s}.bak")"
    if [ ${moveFile} == true ]; then
      _execute_ "mv \"${s}\" \"${n}\"" "Moving '${s}' to '${n}'"
    else
      _execute_ "cp -R \"${s}\" \"${n}\"" "Backing up '${s}' to '${n}'"
    fi
  fi
}

_parseFilename_() {
  # DESC:   Break a filename into its component parts which and place them into prefixed
  #         variables for use in your script. Run with VERBOSE=true to see the variables while
  #         running your script.
  # ARGS:   $1 (Required)       - File
  # OPTS:   -n                  - optional flag for number of extension levels (Ex: -n2)
  # OUTS:   $PARSE_FULL         - File and its real path (ie, resolve symlinks)
  #         $PARSE_PATH         - Path to the file
  #         $PARSE_BASE         - Name of the file WITH extension
  #         $PARSE_BASENOEXT    - Name of file WITHOUT extension
  #         $PARSE_EXT          - The extension of the file (from _ext_())
  # USAGE:  _parseFilename_ "some/file.txt"

  # Error handling
  if [[ $# -lt 1 ]] \
    || ! command -v dirname &>/dev/null \
    || ! command -v basename &>/dev/null \
    || ! command -v realpath &>/dev/null; then

    fatal "Missing dependency or input to _parseFilename_()"
    return 1
  fi

  local levels
  local option
  local exts
  local ext
  local i
  local fn

  unset OPTIND
  while getopts ":n:" option; do
    case ${option} in
      n) levels=${OPTARG} ;;
      *) continue ;;
    esac
  done && shift $((OPTIND - 1))

  local fileToParse="${1}"


  [[ -f "${fileToParse}" ]] || {
    error "Can't locate a file to parse at: ${fileToParse}"
    return 1
  }

  PARSE_FULL="$(realpath "${fileToParse}")" \
    && debug "\${PARSE_FULL}: ${PARSE_FULL:-}"
  PARSE_BASE=$(basename "${fileToParse}") \
    && debug "\${PARSE_BASE}: ${PARSE_BASE-}"
  PARSE_PATH="$(realpath "$(dirname "${fileToParse}")")" \
    && debug "\${PARSE_PATH}: ${PARSE_PATH:-}"

  # Detect some common multi-extensions
  if [[ ! ${levels-} ]]; then
    case $(tr '[:upper:]' '[:lower:]' <<<"${PARSE_BASE}") in
      *.tar.gz | *.tar.bz2) levels=2 ;;
    esac
  fi

  # Find Extension
  levels=${levels:-1}
  fn="${PARSE_BASE}"
  for ((i = 0; i < levels; i++)); do
    ext=${fn##*.}
    if [ $i == 0 ]; then
      exts=${ext}${exts-}
    else
      exts=${ext}.${exts-}
    fi
    fn=${fn%.$ext}
  done
  if [[ "${exts}" == "${PARSE_BASE}" ]]; then
    PARSE_EXT="" && debug "\${PARSE_EXT}: ${PARSE_EXT}"
  else
    PARSE_EXT="${exts}" && debug "\${PARSE_EXT}: ${PARSE_EXT}"
  fi

  PARSE_BASENOEXT="${PARSE_BASE%.$PARSE_EXT}" \
    && debug "\${PARSE_BASENOEXT}: ${PARSE_BASENOEXT}"
}

_decryptFile_() {
  # DESC:   Decrypts a file with openSSL
  # ARGS:   $1 (Required) - File to be decrypted
  #         $2 (Optional) - Name of output file (defaults to $1.decrypt)
  # OUTS:   None
  # USAGE:  _decryptFile_ "somefile.txt.enc" "decrypted_somefile.txt"
  # NOTE:   If a variable '$PASS' has a value, we will use that as the password
  #         to decrypt the file. Otherwise we will ask

  [[ $# -lt 1 ]] && fatal 'Missing required argument to _decryptFile_()!'

  local fileToDecrypt decryptedFile defaultName
  fileToDecrypt="${1:?_decryptFile_ needs a file}"
  defaultName="${fileToDecrypt%.enc}"
  decryptedFile="${2:-$defaultName.decrypt}"

  [ ! "$(declare -f "_execute_")" ] \
    && {
      echo "need function _execute_"
      return 1
    }

  [ ! -f "$fileToDecrypt" ] && return 1

  if [ -z "${PASS}" ]; then
    _execute_ "openssl enc -aes-256-cbc -d -in \"${fileToDecrypt}\" -out \"${decryptedFile}\"" "Decrypt ${fileToDecrypt}"
  else
    _execute_ "openssl enc -aes-256-cbc -d -in \"${fileToDecrypt}\" -out \"${decryptedFile}\" -k \"${PASS}\"" "Decrypt ${fileToDecrypt}"
  fi
}

_encryptFile_() {
  # DESC:   Encrypts a file using openSSL
  # ARGS:   $1 (Required) - Input file
  #         $2 (Optional) - Name of output file (defaults to $1.enc)
  # OUTS:   None
  # USAGE:  _encryptFile_ "somefile.txt" "encrypted_somefile.txt"
  # NOTE:   If a variable '$PASS' has a value, we will use that as the password
  #         for the encrypted file. Otherwise we will ask.

  local fileToEncrypt encryptedFile defaultName

  fileToEncrypt="${1:?_encodeFile_ needs a file}"
  defaultName="${fileToEncrypt%.decrypt}"
  encryptedFile="${2:-$defaultName.enc}"

  [ ! -f "$fileToEncrypt" ] && return 1

  [ ! "$(declare -f "_execute_")" ] \
    && {
      echo "need function _execute_"
      return 1
    }

  if [ -z "${PASS}" ]; then
    _execute_ "openssl enc -aes-256-cbc -salt -in \"${fileToEncrypt}\" -out \"${encryptedFile}\"" "Encrypt ${fileToEncrypt}"
  else
    _execute_ "openssl enc -aes-256-cbc -salt -in \"${fileToEncrypt}\" -out \"${encryptedFile}\" -k \"${PASS}\"" "Encrypt ${fileToEncrypt}"
  fi
}

_extract_() {
  # DESC:   Extract a compressed file
  # ARGS:   $1 (Required) - Input file
  #         $2 (optional) - Input 'v' to show verbose output
  # OUTS:   None

  local filename
  local foldername
  local fullpath
  local didfolderexist
  local vv

  [[ $# -lt 1 ]] && fatal 'Missing required argument to _extract_()!'

  [[ "${2-}" == "v" ]] && vv="v"

  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2 | *.tbz | *.tbz2) tar "x${vv}jf" "$1" ;;
      *.tar.gz | *.tgz) tar "x${vv}zf" "$1" ;;
      *.tar.xz)
        xz --decompress "$1"
        set -- "$@" "${1:0:-3}"
        ;;
      *.tar.Z)
        uncompress "$1"
        set -- "$@" "${1:0:-2}"
        ;;
      *.bz2) bunzip2 "$1" ;;
      *.deb) dpkg-deb -x${vv} "$1" "${1:0:-4}" ;;
      *.pax.gz)
        gunzip "$1"
        set -- "$@" "${1:0:-3}"
        ;;
      *.gz) gunzip "$1" ;;
      *.pax) pax -r -f "$1" ;;
      *.pkg) pkgutil --expand "$1" "${1:0:-4}" ;;
      *.rar) unrar x "$1" ;;
      *.rpm) rpm2cpio "$1" | cpio -idm${vv} ;;
      *.tar) tar "x${vv}f" "$1" ;;
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
  shift

}

_json2yaml_() {
  # DESC:   Convert JSON to YAML
  # ARGS:   $1 (Required) - JSON file
  # OUTS:   None

  python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' <"${1:?_json2yaml_ needs a file}"
}

_makeSymlink_() {
  # DESC:   Creates a symlink and backs up a file which may be overwritten by the new symlink. If the
  #         exact same symlink already exists, nothing is done.
  #         Default behavior will create a backup of a file to be overwritten
  # ARGS:   $1 (Required) - Source file
  #         $2 (Required) - Destination
  #         $3 (Optional) - Backup directory for files which may be overwritten (defaults to 'backup')
  # OPTS:  -n             - Do not create a backup if target already exists
  #        -s             - Use sudo when removing old files to make way for new symlinks
  # OUTS:   None
  # USAGE:  _makeSymlink_ "/dir/someExistingFile" "/dir/aNewSymLink" "/dir/backup/location"
  # NOTE:   This function makes use of the _execute_ function

  local opt
  local OPTIND=1
  local backupOriginal=true
  local useSudo=false

  while getopts ":nNsS" opt; do
    case $opt in
      n | N) backupOriginal=false ;;
      s | S) useSudo=true ;;
      *)
        {
          error "Unrecognized option '$1' passed to _makeSymlink_" "$LINENO"
          return 1
        }
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if ! command -v realpath >/dev/null 2>&1; then
    error "We must have 'realpath' installed and available in \$PATH to run."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      notice "Install coreutils using homebrew and rerun this script."
      info "\t$ brew install coreutils"
    fi
    _safeExit_ 1
  fi

  [[ $# -lt 2 ]] && fatal 'Missing required argument to _makeSymlink_()!'

  local s="$1"
  local d="$2"
  local b="${3-}"
  local o

  # Fix files where $HOME is written as '~'
  d="${d/\~/$HOME}"
  s="${s/\~/$HOME}"
  b="${b/\~/$HOME}"

  [ ! -e "$s" ] \
    && {
      error "'$s' not found"
      return 1
    }
  [ -z "$d" ] \
    && {
      error "'${d}' not specified"
      return 1
    }
  [ ! "$(declare -f "_execute_")" ] \
    && {
      echo "need function _execute_"
      return 1
    }
  [ ! "$(declare -f "_backupFile_")" ] \
    && {
      echo "need function _backupFile_"
      return 1
    }

  # Create destination directory if needed
  [ ! -d "${d%/*}" ] \
    && _execute_ "mkdir -p \"${d%/*}\""

  if [ ! -e "${d}" ]; then
    _execute_ "ln -fs \"${s}\" \"${d}\"" "symlink ${s} → ${d}"
  elif [ -h "${d}" ]; then
    o="$(realpath "${d}")"

    [[ "${o}" == "${s}" ]] && {
      if [ "${DRYRUN}" == true ]; then
        dryrun "Symlink already exists: ${s} → ${d}"
      else
        info "Symlink already exists: ${s} → ${d}"
      fi
      return 0
    }

    if [[ "${backupOriginal}" == true ]]; then
      _backupFile_ "${d}" "${b:-backup}"
    fi
    if [[ "${DRYRUN}" == false ]]; then
      if [[ "${useSudo}" == true ]]; then
        command rm -rf "${d}"
      else
        command rm -rf "${d}"
      fi
    fi
    _execute_ "ln -fs \"${s}\" \"${d}\"" "symlink ${s} → ${d}"
  elif [ -e "${d}" ]; then
    if [[ "${backupOriginal}" == true ]]; then
      _backupFile_ "${d}" "${b:-backup}"
    fi
    if [[ "${DRYRUN}" == false ]]; then
      if [[ "${useSudo}" == true ]]; then
        sudo command rm -rf "${d}"
      else
        command rm -rf "${d}"
      fi
    fi
    _execute_ "ln -fs \"${s}\" \"${d}\"" "symlink ${s} → ${d}"
  else
    warning "Error linking: ${s} → ${d}"
    return 1
  fi
  return 0
}

_parseYAML_() {
  # DESC:   Convert a YANML file into BASH variables for use in a shell script
  # ARGS:   $1 (Required) - Source YAML file
  #         $2 (Required) - Prefix for the variables to avoid namespace collisions
  # OUTS:   Prints variables and arrays derived from YAML File
  # USAGE:  To source into a script
  #         _parseYAML_ "sample.yml" "CONF_" > tmp/variables.txt
  #         source "tmp/variables.txt"
  #
  # NOTE:   https://gist.github.com/DinoChiesa/3e3c3866b51290f31243
  #         https://gist.github.com/epiloque/8cf512c6d64641bde388

  local yamlFile="${1:?_parseYAML_ needs a file}"
  local prefix="${2-}"

  [ ! -s "${yamlFile}" ] && return 1

  local s='[[:space:]]*'
  local w='[a-zA-Z0-9_]*'
  local fs="$(echo @ | tr @ '\034')"
  sed -ne "s|^\(${s}\)\(${w}\)${s}:${s}\"\(.*\)\"${s}\$|\1${fs}\2${fs}\3|p" \
    -e "s|^\(${s}\)\(${w}\)${s}[:-]${s}\(.*\)${s}\$|\1${fs}\2${fs}\3|p" "${yamlFile}" \
    | awk -F"${fs}" '{
    indent = length($1)/2;
    if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s%s=(\"%s\")\n", "'"${prefix}"'",vn, $2, conj[indent-1],$3);
    }
  }' | sed 's/_=/+=/g' | sed 's/[[:space:]]*#.*"/"/g'
}

_readFile_() {
  # DESC:   Prints each line of a file
  # ARGS:   $1 (Required) - Input file
  # OUTS:   Prints contents of file

  [[ $# -lt 1 ]] && fatal 'Missing required argument to _readFile_()!'

  local result
  local c="$1"

  [ ! -f "$c" ] \
    && {
      echo "'$c' not found"
      return 1
    }

  while read -r result; do
    echo "${result}"
  done <"${c}"
}

_sourceFile_() {
  # DESC:   Source a file into a script
  # ARGS:   $1 (Required) - File to be sourced
  # OUTS:   None

  [[ $# -lt 1 ]] && fatal 'Missing required argument to _sourceFile_()!'

  local c="$1"

  [ ! -f "$c" ] \
    && {
      fatal "Attempted to source '$c' Not found"
      return 1
    }

  source "$c"
  return 0
}

_uniqueFileName_() {
  # DESC:   Ensure a file to be created has a unique filename to avoid overwriting other files
  # ARGS:   $1 (Required) - Name of file to be created
  #         $2 (Optional) - Separation characted (Defaults to a period '.')
  # OUTS:   Prints unique filename to STDOUT
  # USAGE:  _uniqueFileName_ "/some/dir/file.txt" "-"

  local fullfile="${1:?_uniqueFileName_ needs a file}"
  local spacer="${2:-.}"
  local directory
  local filename
  local extension
  local newfile
  local n

  if ! command -v realpath >/dev/null 2>&1; then
    error "We must have 'realpath' installed and available in \$PATH to run."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      notice "Install coreutils using homebrew and rerun this script."
      info "\t$ brew install coreutils"
    fi
    _safeExit_ 1
  fi

  # Find directories with realpath if input is an actual file
  if [ -e "${fullfile}" ]; then
    fullfile="$(realpath "${fullfile}")"
  fi

  directory="$(dirname "${fullfile}")"
  filename="$(basename "${fullfile}")"

  # Extract extensions only when they exist
  if [[ "${filename}" =~ \.[a-zA-Z]{2,4}$ ]]; then
    extension=".${filename##*.}"
    filename="${filename%.*}"
  fi

  newfile="${directory}/${filename}${extension-}"

  if [ -e "${newfile}" ]; then
    n=1
    while [[ -e "${directory}/${filename}${extension-}${spacer}${n}" ]]; do
      ((n++))
    done
    newfile="${directory}/${filename}${extension-}${spacer}${n}"
  fi

  echo "${newfile}"
  return 0
}

_yaml2json_() {
  # DESC:   Convert a YAML file to JSON
  # ARGS:   $1 (Required) - Input YAML file
  # OUTS:   None

  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' <"${1:?_yaml2json_ needs a file}"
}
