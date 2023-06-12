#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1

[[ -z ${TERM+x} ]] && TERM='xterm-256color' || [[ "$TERM" == 'linux' ]] && TERM='xterm-256color'
export TERM

#set -uo pipefail
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
declare -gr BASH_FUNCTION_LOG="$HOME/.faults"
declare -gr BFL_ErrCode_Not_verified_args_count=1
declare -gr BFL_ErrCode_Not_verified_dependency=2
declare -gr BFL_ErrCode_Not_verified_arg_values=3

# Enable xtrace if the DEBUG environment variable is set
if [[ "${DEBUG,,}" =~ ^1|yes|true$ ]]; then
  set -o xtrace    # Trace the execution of the script (debug)
fi

# Only enable these shell behaviours if script not being sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
  echo 'Script not being sourced' > /dev/tty
  # A better class of script...
  set -o errexit      # Exit on most errors (see the manual)
  set -o nounset      # Disallow expansion of unset variables
  set -o pipefail     # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
# set -o errtrace         # Ensure the error trap handler is inherited

bfl::autoload() {
  # https://github.com/ralish/bash-script-template/script.sh
  function script_usage() {
      cat << EOF
Usage:
     -h|--help                    Displays this help
     -v|--verbose                 Displays verbose output
    -nc|--no-colour               Disables colour output
    -cr|--cron                    Run silently unless we encounter an error
EOF
  }

  function parse_params() {
      local param
      while [[ $# -gt 0 ]]; do
          param="$1"
          shift
          case $param in
              -h | --help)        script_usage
                                  exit 0 ;;
              -v | --verbose)     verbose=true ;;
              -nc | --no-colour)  RC_NOCOLOR=true ;;
              -cr | --cron)       cron=true ;;
              *)  script_exit "Invalid parameter was provided: $param" 1 ;;
          esac
      done
  }

  declare autoload_canonical_path    # Canonical path to this file.
  declare autoload_directory         # Directory in which this file resides.
  declare f

  autoload_canonical_path=$(readlink -e "${BASH_SOURCE[0]}") || {
      local str="Error readlink -e ${BASH_SOURCE[0]}"
      printf "%s/n" "$str" >> "$BASH_FUNCTION_LOG"
      [[ $BASH_INTERACTIVE == true ]] && printf "%s/n" "$str" # > /dev/tty;
      exit 1
      }

  autoload_directory=$(dirname "$autoload_canonical_path") || exit 1

  for f in "$autoload_directory"/lib/*/_*.sh; do
      source "$f" || {
        [[ $BASH_INTERACTIVE == true ]] && printf "Error while loading $f/n" # > /dev/tty;
        return 1
        }
  done
  }

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if (return 0 2> /dev/null); then
  bfl::autoload
else
  bfl::autoload "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
