#!/usr/bin/env bash

# ##################################################
# My Generic BASH script template
#
version="1.0.0"               # Sets version variable for this script
#
scriptTemplateVersion="1.1.0" # Version of scriptTemplate.sh
#                               that this script is based on
#
# A Bash script boilerplate.  Allows for common functions, logging, tmp
# file creation, CL option passing, and more.
#
# For logging levels use the following functions:
#   - header:   Prints a script header
#   - input:    Ask for user input
#   - success:  Print script success
#   - info:     Print information to the user
#   - notice:   Notify the user of something
#   - warning:  Warn the user of something
#   - error:    Print a non-fatal error
#   - die:      A fatal error.  Will exit the script
#   - debug:    Debug information
#   - verbose:  Debug info only printed when 'verbose' flag is set to 'true'.
#
# HISTORY:
#
# * 2015-02-07 - v1.0.0  - First Creation
#
# ##################################################

# Source Scripting Utilities
# -----------------------------------
# If these can't be found, update the path to the file
# -----------------------------------
if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi
# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."  # Edit this if you like.
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=0
printLog=0
verbose=0
force=0
strict=0
debug=0

# Set Local Variables
# -----------------------------------
# A set of variables used by many scripts
# -----------------------------------

# Set Script name and location variables
scriptName=`basename ${0}`  # Full name
scriptBasename="$(basename ${scriptName} .sh)" # Strips '.sh' from name
scriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set time stamp
now=$(date +"%m-%d-%Y %r")
# Set hostname
thisHost=$(hostname)

# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${scriptBasename}.log"


function mainScript() {
############## Begin Script Here ###################
header "Beginning ${scriptName}"


# Variables from config file
if is_file "../etc/mackup.cfg"; then
  source "../etc/mackup.cfg"
  MACKUPDIR="$DIRCFG"
  TESTFILE="$TESTCFG"
else
  die "Can not run without config file.  Please find mackup.cfg"
fi

#Run Dropbox checking function
hasDropbox

# Confirm we have Dropbox installed by checking for the existence of some synced files.
# IMPORTANT:  As time moves, some of these files may be deleted.  Ensure this list is kept up-to-date.
# This can be tested by running dropboxFileTest.sh script.

if [ "${force}" = "0" ]; then  #Bypass the Dropbox test when script is forced
  if is_not_file "${TESTFILE}"; then
    die "Could not find ${TESTFILE}.  Exiting."
  else
    notice "Confirming that Dropbox has synced..."
    while IFS= read -r file
    do
      while [ ! -e $HOME/"${file}" ] ;
      do
        info "...Waiting for Dropbox to Sync files."
        sleep 10
      done
    done < "${TESTFILE}"
  fi

  #Add some additional time just to be sure....
  info "...Waiting for Dropbox to Sync files."
  sleep 10
  info "...Waiting for Dropbox to Sync files."
  sleep 10

  # Sync Complete
  success "Hooray! Dropbox has synced the necessary files."
fi


if type_not_exists 'mackup'; then
  warning "Run 'brew install mackup' or run the Homebrew setup script."
  die "MACKUP NOT FOUND."
else
  verbose "Mackup is installed."
fi

notice "Checking for Mackup config files..."
if is_not_symlink "$HOME/.mackup"; then
  notice "Symlinking ~/.mackup"
  ln -s "${MACKUPDIR}"/.mackup "$HOME"/.mackup
else
  verbose "~/.mackup is symlinked"
fi
if is_not_symlink "${HOME}/.mackup.cfg"; then
  notice "Symlinking ~/.mackup.cfg"
  ln -s "${MACKUPDIR}"/.mackup.cfg "${HOME}"/.mackup.cfg
else
  verbose "~/.mackup.cfg is symlinked"
fi
success "Mackup config files are symlinked."

seek_confirmation "Run Mackup Restore?"
if is_confirmed; then
  verbose "Running mackup restore" && mackup restore
  header "All Done."
fi


header "Completed ${scriptName}"
############## End Script Here ###################
}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This is my script template.

 Options:
  -u, --username    Username for script
  -p, --password    User password
  -f, --force       Skip all user interaction.  Implied 'Yes' to all actions
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set-x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "$(basename $0) $version"; safeExit ;;
    -u|--username) shift; username=$1 ;;
    -p|--password) shift; password=$1 ;;
    -v|--verbose) verbose=1 ;;
    -l|--log) printLog=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--strict) strict=1;;
    -d|--debug) debug=1;;
    -f|--force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done


############## End Options and Usage ###################




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Run in debug mode, if set
if [ "${debug}" == "1" ]; then
  set -x
fi

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Exit on error. Append ||true if you expect an error.
set -o errexit

# Exit on empty variable
if [ "${strict}" = "1" ]; then
  set -o nounset
fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail


mainScript # Run your script

safeExit # Exit cleanly