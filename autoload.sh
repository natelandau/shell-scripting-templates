#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR/../shell-scripting-templates/utilities
# shellcheck source-path=SCRIPTDIR/../../shell-scripting-templates/utilities

[[ "${BASH_SOURCE%/*}" =~ /bash_functions_library$ ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "${BASH_SOURCE##*/}" | sed 's/\.sh$//' | tr [:lower:] [:upper:])" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1

[[ -z ${TERM+x} ]] && TERM='xterm-256color' || [[ "$TERM" == 'linux' ]] && TERM='xterm-256color'
export TERM
#[[ "$TERM" == 'linux' ]] && unset TERM # Почему-то не работает!
#[[ -z ${TERM+x} ]] && readonly TERM='xterm-256color'
# ------------- https://github.com/jmooring/bash-function-library -------------
#------------------------------------------------------------------------------
# @file
# Sources files adjacent to (in the same directory as) this script.
#
# This is the required directory structure:
#
# └── library (directory name and location are irrelevant)
#     ├── autoload.sh
#     ├── lib
#     ├──── functions group
#     ├────── _file_1.sh
#     ├────── _file_2.sh
#     └────── _file_3.sh
#
# This script defines and then calls the autoload function.
#
# The autoload function loops through the files in the library directory, and
# sources file names that begin with an underscore.
#
# An "underscore" file should contain one and only one function. The file name
# should be equal to the function name, preceded by an underscore.
#
# So here's the scenario...
#
# You are creating a script ($HOME/foo.sh) to parse a text file. You need to
# trim (remove leading and trailing spaces) some strings. Trimming is a common
# task, a capability you are likely to need within other scripts.
#
# Instead of writing a trim function within foo.sh, write the function within
# a new file named _trim.sh in the library directory.
#
# Finally, source path/to/autoload.sh at the beginning of foo.sh. All of the
# functions in the library are now available to foo.sh.
#
# The relative path from foo.sh to autoload.sh is irrelevant.
#
# There is no need to set the executable bit on any of the files in the
# library directory. In fact, Google's "Shell Style Guide" specifically forbids
# this:
#
#   "Libraries must have a .sh extension and should not be executable."
#
# See https://google.github.io/styleguide/shell.xml#File_Extensions.
#
# Logical functions in this library, such as bfl::is_integer() or
# bfl::is_empty(), should not output any messages. They should only return 0
# if true or return 1 if false.
#
# To simplify usage, place this line at the top of $HOME/.bashrc:
#
#   export BASH_FUNCTION_LIBRARY="$HOME/path/to/autoloader.sh"
#
# Then, at the top of each new script add:
#
#   if ! source "${BASH_FUNCTION_LIBRARY}"; then
#     printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
#     exit 1
#   fi
#
# shellcheck disable=SC1090
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sources files adjacent to (in the same directory as) this script.
#
# This will only source file names that begin with an underscore.
#------------------------------------------------------------------------------
readonly BASH_FUNCTION_LOG="$HOME/.faults"                          # declare -gr
readonly GIT_HUB_CONFIG="$HOME/.git-hub/config.d/github.com.config" # declare -gr
readonly BFL_ErrCode_Not_verified_args_count=1                      # declare -gr
readonly BFL_ErrCode_Not_verified_dependency=2                      # declare -gr
readonly BFL_ErrCode_Not_verified_arg_values=3                      # declare -gr

# ------------------------ Some global variables ------------------------------
#LOGFILE="${HOME}/logs/${0##*/}.log"   $(basename "$0").log - is declared in ${HOME}/getConsts
BASH_INTERACTIVE=true   # QUIET=false
LOGLEVEL=ERROR
VERBOSE=false
FORCE=false
DRYRUN=false
#set -uo pipefail
set +u # Это все, что я могу себе позволить
set -o functrace -o pipefail # -eE - моментальный вылет, ничего не успев записать

# Confirm we have BASH greater than v4
[[ -z "${BASH_VERSINFO+x}" ]] ||  [[ "${BASH_VERSINFO:-0}" -ge 4 ]] || { printf "%s\n" "ERROR: BASH_VERSINFO is '${BASH_VERSINFO:-0}'.  This script requires BASH v4 or greater."; exit 1; }

# IFS=$' \n\t' # Set IFS to preferred implementation

bfl::autoload() {

  function _bfl_parse_params() {
      local param
      while [[ $# -gt 0 ]]; do
          param="$1"
          shift
          case $param in          # https://github.com/ralish/bash-script-template/script.sh
              -h | --h | --help)        cat << EOF
Usage:
     -h | --h | --help            Displays this help
     -v | --verbose               Displays verbose output
    -nc | --nc | --no-colour      Disables colour output
    -cr | --cr | --cron           Run silently unless we encounter an error
EOF
                                        return 0 ;;
              -v | --verbose)           verbose=true ;;
             -nc | --nc | --no-colour)  RC_NOCOLOR=true ;;
             -cr | --cr | --cron)       cron=true ;;
              *)  script_exit "Invalid parameter was provided: $param" 1 ;;
          esac
      done
  }

  [[ -f "$BASH_FUNCTION_LIBRARY" ]] || return 1
  [[ -d "${BASH_FUNCTION_LIBRARY%/*}" ]] || {   # $(dirname "$BASH_FUNCTION_LIBRARY")
      local str="Error readlink -e ${BASH_SOURCE[0]}"
      printf "%s/n" "$str" >> "$BASH_FUNCTION_LOG"
      [[ $BASH_INTERACTIVE == true ]] && printf "%s\n" "$str" # > /dev/tty;
      return 1
      }

  #             source functions' bodies
  local f
  for f in "${BASH_FUNCTION_LIBRARY%/*}"/lib/*/_*.sh; do  # $(dirname "$BASH_FUNCTION_LIBRARY")
      source "$f" || {
        [[ $BASH_INTERACTIVE == true ]] && printf "Error while loading $f\n" # > /dev/tty;
        return 1
        }
  done
  }

declare -a ARGS=()
bfl::parseOptions() {
    # DESC:
    #					Iterates through options passed to script and sets variables. Will break -ab into -a -b
    #         when needed and --foo=bar into --foo bar
    # ARGS:
    #					$@ from command line
    # OUTS:
    #					Sets array 'ARGS' containing all arguments passed to script that were not parsed as options
    # USAGE:
    #					bfl::parseOptions "$@"

    # Iterate over options
    local _optstring=h
    declare -a _options

    local _c i
    while (($#)); do
        case $1 in
            -[!-]?*)  # If option is of type -ab
                # Loop over each character starting with the second
                for ((i = 1; i < ${#1}; i++)); do
                    _c=${1:i:1}
                    _options+=("-${_c}") # Add current char to options
                    # If option takes a required argument, and it's not the last char make
                    # the rest of the string its argument
                    if [[ ${_optstring} == *"${_c}:"* && -n ${1:i+1} ]]; then
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
    # shellcheck disable=SC2034
    while [[ ${1:-} == -?* ]]; do
        case $1 in
            # Custom options
            #     ....
            #     ....

            # Common options
            -h | --h | --help) cat <<USAGE_TEXT

  ${Green}${0##*/} [OPTION]... [FILE]...${NC}

  This is a script template.  Edit this description to print help to users.

  ${Green}${FMT_UNDERLINE}Options:${NC}
$(bfl::_terminal_print_2columns -b -- '-h, --h, --help' "Display this help and exit" 2)
$(bfl::_terminal_print_2columns -b -- "--loglevel [LEVEL]" "One of: FATAL, ERROR (default), WARN, INFO, NOTICE, DEBUG, ALL, OFF" 2)
$(bfl::_terminal_print_2columns -b -- "--logfile [FILE]" "Full PATH to logfile.  (Default is '\${HOME}/logs/${0##*/}.log')" 2)
$(bfl::_terminal_print_2columns -b -- "-n, --dryrun" "Non-destructive. Makes no permanent changes." 2)
$(bfl::_terminal_print_2columns -b -- "-q, --q, --quiet" "Quiet (no output)" 2)
$(bfl::_terminal_print_2columns -b -- "-v, --verbose" "Output more information. (Items echoed to 'verbose')" 2)
$(bfl::_terminal_print_2columns -b -- "--force" "Skip all user interaction.  Implied 'Yes' to all actions." 2)

  ${Green}${FMT_UNDERLINE}Example Usage:${NC}

    ${Gray}# Run the script and specify log level and log file.${NC}
    ${0##*/} -vn --logfile "/path/to/file.log" --loglevel 'WARN'
USAGE_TEXT

                         bfl::script_lock_release ;;
            --loglevel)     shift
                            LOGLEVEL="${1}" ;;
            --logfile)      shift
                            LOGFILE="${1}" ;;
            -n | --dryrun)  DRYRUN=true ;;
            -v | --verbose) VERBOSE=true ;;
            -q | --q | --quiet)  BASH_INTERACTIVE=false ;;
            --force)        FORCE=true ;;
            --endopts)      shift
                            break ;;
            *)  bfl::writelog_error "invalid option: $1"
                exit 1 ;;
        esac
        shift
    done

    if [[ -z ${*} || ${*} == null ]]; then
        ARGS=()
    else
        ARGS+=("$@") # Store the remaining user input as arguments.
    fi
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if (return 0 2> /dev/null); then
  bfl::autoload
  #                                                                                                 {BASH_SOURCE[*]}  $1 $2 $3 $4 $5 $6 $7 $8 $9
  trap 'bfl::trap_cleanup "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]}" "$BASH_COMMAND" "$0" "${BASH_SOURCE[0]}" "$*" "${BASH_FUNCTION_LOG}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
else
  bfl::autoload "$@"

# Enable these shell behaviours if script not being sourced ONLY
# Approach via: https://stackoverflow.com/a/28776166/8787985                                        {BASH_SOURCE[*]}  $1 $2 $3 $4 $5 $6 $7 $8 $9
  trap 'bfl::trap_cleanup "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]}" "$BASH_COMMAND" "$0" "${BASH_SOURCE[0]}" "$*" "${BASH_FUNCTION_LOG}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
  echo 'Script not being sourced' > /dev/tty
# Ensure the error trap handler is inherited !!!
# ----------------------- https://www.caliban.org/bash/index.shtml -----------------------
# Enable errtrace or the error trap handler will not work as expected
# set -e == set -o errexit     # Exit on most errors (see the manual)
# set -E == set -o errtrace    # Trap errors in subshells and functions
# set -u == set -o nounset     # Disallow expansion of unset variables
# set -o pipefail              # Use last non-zero exit code in a pipeline
  set -eEu -o pipefail
# set -o xtrace                # Run in debug mode

# Make `for f in *.txt` work when `*.txt` matches zero files
  shopt -s nullglob globstar
fi

# Enable xtrace if the DEBUG environment variable is set
[[ "${DEBUG,,}" =~ ^1|yes|true$ ]] && set -o xtrace    # Trace the execution of the script (debug)

bfl::global_declare_dependencies

# [[ $# -eq 0 ]] && bfl::parseOptions "-h"  # Force arguments when invoking the script
bfl::parseOptions "$@"                      # Parse arguments passed to script
# bfl::make_tempdir "${0##*/}"              # Create a temp directory '$TMP_DIR'
bfl::script_lock_acquire                    # Acquire script lock

if [[ "$(bfl::get_OS)" == "mac" ]]; then
  bfl::get_homebrew_path                    # Add Homebrew bin directory to PATH (MacOS)
  bfl::use_GNU_utils                        # Source GNU utilities from Homebrew (MacOS)
fi

# Run the main logic script
_mainScript_() {
    # Replace everything in _mainScript_() with your script's code
    header  "Showing alert colors"
    debug   "This is debug text"
    info    "This is info text"
    notice  "This is notice text"
    dryrun  "This is dryrun text"
    warning "This is warning text"
    error   "This is error text"
    success "This is success text"
    input   "This is input text"
}

if [[ -n "$PS1" ]]; then
    case $- in
        *i*) _mainScript_  ;; # Only if running interactively
        *)      # do nothing
            ;;  # non-interactive
    esac
fi

bfl::script_lock_release                    # Exit cleanly

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
