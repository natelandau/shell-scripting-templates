#!/usr/bin/env bash


# ##################################################
# My Generic sync script.
#
version="1.1.0"  # Sets version variable
#
scriptTemplateVersion="1.1.1" # Version of scriptTemplate.sh that this script is based on
#                               v.1.1.0 - Added 'debug' option
#                               v.1.1.1 - Moved all shared variables to Utils
#
# This script will give you the option of using rsync
# or Unison.  Rsync is for one-way syncing, Unison is for
# two-way syncing.
#
# Depending on what flags are passed to the script and
# what information is written in the config file, this script
# will perform different behavior.
#
# USAGE:
#
# 1) IMPORTANT: Copy this script and rename it for your purpose before running.
# 2) Run the script.  This will create a blank config file for you and then exit.
# 3) Enter your information within the config file
# 4) Run the script again.
#
# TO DO:
#   * Add SSH functionality
#
# DISCLAIMER:
# I am a novice programmer and I bear no responsibility whatsoever
# if this (or any other) script that I write wipes your computer,
# destroys your data, crashes your car, or otherwise causes mayhem
# and destruction.  USE AT YOUR OWN RISK.
#
#
# HISTORY:
# * 2015-01-02 - v1.0.0 - First Creation
# * 2015-01-03 - v1.1.0 - Added support for using roots in Unison .prf
# * 2015-03-10 - v1.1.1 - Updated script template version
#                       - Removed $logFile from config.  Default is now '~/library/logs/'
#
# ##################################################

# Source Scripting Utilities
# Source Scripting Utilities
# -----------------------------------
# If these can't be found, update the path to the file
# -----------------------------------
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "${scriptPath}/../lib/utils.sh" ]; then
  source "${scriptPath}/../lib/utils.sh"
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

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
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


# Configuration file
# -----------------------------------
# This script calls for a configuration file.
# This is its location.  Default is the location
# where it will be automatically created.`
# -----------------------------------
CONFIG="../etc/${scriptName}.cfg"


# Create new copy of the script if template is being executed
function newCopy() {
  if [ "${scriptName}" = "SyncTemplate.sh" ]; then
    input "name your new script:"
    read newname
    verbose "Copying SyncTemplate.sh to ${newname}"
    cp "${scriptPath}"/"${scriptName}" "${scriptPath}"/"${newname}" && verbose "cp ${scriptPath}/${scriptName} ${scriptPath}/${newname}"
    success "${newname} created."
    safeExit
  fi
}

function configFile() {
  # Here we source the Config file or create a new one if none exists.
  if is_file "${CONFIG}"; then
    source "${CONFIG}"
    verbose "source ${CONFIG}"
  else
    seek_confirmation "Config file does not exist.  Would you like to create one?"
    if is_not_confirmed; then
      die "No config file.  Exiting"
    else
      touch "${CONFIG}" && verbose "touch ${CONFIG}"
  cat >"${CONFIG}" <<EOL
# ##################################################
# CONFIG FILE FOR ${scriptName}
# CREATED ON ${now}
#
# Created by version "$version" of "SyncTemplate.sh"
# ##################################################

# METHOD
# ---------------------------
# This script will work with both Unison and rsync.
# Set the METHOD variable to either 'unison' or 'rsync'
METHOD=""


# ---------------------------
# Network Volume Mounting
# ---------------------------
# If one of the directies you need to sync is on a network drive set
# the variable NEEDMOUNT to 'true'
NEEDMOUNT="false"

# MOUNTPOINT is the address of the drive to be mounted.
# Use the format afp://username:password@address/mountname
# to be prompted to enter a password, change MOUNTPW to 'true'
MOUTPW="false"
MOUNTPOINT=""

# REMOTEVOLUME is the directory that the drive should be mounted
# into on the local computer. Typically this is in the /Volumes/ dir.
# and should be named the same as the mountname in the MOUNTPOINT.
# Use a complete path, not a relative path without a trailing slash.
REMOTEVOLUME=""


# ---------------------------
# Directories To Sync
# ---------------------------
# These are the COMPLETE paths two directories that will be synced.
# Be sure to include trailing slashes on directories.
SOURCEDIRECTORY=""
TARGETDIRECTORY=""


# ---------------------------
# UNISON PREFERENCES
# ---------------------------
# If you are using UNISON to sync your directories, fill in this section.

# Unison keeps its own config profiles which configure
# much of the script.  These .prf files are located in '~/.unison/'
# more info: http://www.cis.upenn.edu/~bcpierce/unison/download/releases/stable/unison-manual.html
#
# If you wish to use a Unison profile change USERPROFILE to 'true'
# and add the profile name to UNISONPROFILE.
#
# If your Unison profile contains the 'roots' to by synced, change PROFILEROOTS to 'true'.
# If this remains 'false', the directories to by synced will be the ones specified above.
USEPROFILE="false"
PROFILEROOTS="false"
UNISONPROFILE=""


# ---------------------------
# RSYNC PREFENCES
# ---------------------------
# If you are using rsync, complete this section

# EXCLUDE is a text file that contains all the rsync excludes.
# Anything listed within this file will be ignored during sync.
EXCLUDE=""


# ---------------------------
# ADDITIONAL OPTIONS
# ---------------------------

# PUSHOVER is an online notification tool.
# If you want to receive notifications upon completion
# set the following value to "true"
PUSHOVERnotice="false"

# CANONICALHOST is used to denote a sync hub which should never initiate a sync.
# Leave blank if not needed.
CANONICALHOST=""
EOL
  success "Config file created. Edit the values before running this script again."
  notice "The file is located at: ${CONFIG}.  Exiting."
  safeExit
  fi
fi
}



############## Begin Script Functions Here ###################


# HostCheck
# Confirm we can run this script.  If a canonical host is set in
# the config file we check it here.
function hostCheck() {
  if [ "${thisHost}" = "${CANONICALHOST}" ]; then
    die "We are currently on ${THISHOST} and can not proceed. Be sure to run this script on the non-canonical host."
  fi
}

# MethodCheck
# Confirm we have either Unison or Rsync specified
# in the config file. Exit if not.
function MethodCheck() {
  if [ "${METHOD}" != "rsync" ] && [ "${METHOD}" != "unison" ]; then
    die "Script aborted without a method specified in the config file."
  fi
}

function moutDrives() {
  if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ] || [ "${NEEDMOUNT}" = "True" ]; then
    # Mount AFP volume
    if is_not_dir "${REMOTEVOLUME}"; then
      notice "Mounting drive"
      mkdir "${REMOTEVOLUME}" && verbose "mkdir ${REMOTEVOLUME}"
      if [ "${MOUTPW}" = "true" ]; then # if password prompt needed
        mount_afp -i "${MOUNTPOINT}" "${REMOTEVOLUME}" && verbose "mount_afp -i ${MOUNTPOINT} ${REMOTEVOLUME}"
      else
        mount_afp "${MOUNTPOINT}" "${REMOTEVOLUME}" && verbose "mount_afp ${MOUNTPOINT} ${REMOTEVOLUME}"
      fi
      sleep 5
      notice "${REMOTEVOLUME} Mounted"
    else
      notice "${REMOTEVOLUME} was already mounted."
    fi
  fi
}

function unmountDrives() {
  # Unmount the drive (if mounted)
  if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ]; then
    unmountDrive "${REMOTEVOLUME}"
    notice "${REMOTEVOLUME} UnMounted"
  fi
}

function testSources() {
  # Test for source directories.
  # If they don't exist we can't continue

  # test for target
  if is_dir "${TARGETDIRECTORY}"; then
    verbose "${TARGETDIRECTORY} exists"
  else
    if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ]; then
      unmountDrive "${REMOTEVOLUME}" && verbose "Unmounting ${REMOTEVOLUME}"
      if is_dir "${REMOTEVOLUME}"; then
        rm -r "${REMOTEVOLUME}" && verbose "rm -r ${REMOTEVOLUME}"
      fi
    fi
    die "Target directory: ${TARGETDIRECTORY} does not exist."
  fi

  # Test for source directory
  if is_dir "${SOURCEDIRECTORY}"; then
    verbose "${SOURCEDIRECTORY} exists"
  else
    if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ]; then
      unmountDrive "${REMOTEVOLUME}" && verbose "Unmounting ${REMOTEVOLUME}"
      if is_dir "${REMOTEVOLUME}"; then
        rm -r "${REMOTEVOLUME}" && verbose "rm -r ${REMOTEVOLUME}"
      fi
    fi
    die "Source directory: ${SOURCEDIRECTORY} does not exist."
  fi
  notice "Source directories passed filesystem check.  Continuing."
}

function runRsync() {
  if [ "${METHOD}" = "rsync" ]; then
    if [ "${debug}" = "1" ]; then
      debug "/usr/bin/rsync -vahh${DRYRUN}${COMPRESS} --progress --force --delete --exclude-from=${EXCLUDE} ${SOURCEDIRECTORY} ${TARGETDIRECTORY} --log-file=${logFile}"
    else
      notice "Commencing rsync"
      /usr/bin/rsync -vahh"${DRYRUN}""${COMPRESS}" --progress --force --delete --exclude-from="${EXCLUDE}" "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}" --log-file="${logFile}"
    fi
  fi
}


function runUnison() {
  if [ "${METHOD}" = "unison" ]; then
    # Check if Unison is installed.  It is not a standard package
    if type_not_exists 'unison'; then
      seek_confirmation "Unison not installed, try to install it with Homebrew?"
      if is_confirmed; then
        notice "Attempting to install Unison."
        hasHomebrew
        brew install unison
      else
        if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ]; then
          unmountDrive "${REMOTEVOLUME}" && verbose "unmountDrive ${REMOTEVOLUME}"
          if is_dir "${REMOTEVOLUME}"; then
            rm -r "${REMOTEVOLUME}" && verbose "rm -r ${REMOTEVOLUME}"
          fi
        fi
        die "Can not continue without having Unison installed."
      fi
    fi

    # Run Unison
    if [ "${PROFILEROOTS}" = "true" ]; then
      # Throw error if we don't have enough information
      if [ "${USEPROFILE}" = "false" ] || [ "${UNISONPROFILE}" = "" ]; then
        die "We were missing the Unison Profile.  Could not sync."
      fi
      # Run unison with a profile and no sources
      if [ "${debug}" = "1" ]; then
        debug "unison ${UNISONPROFILE}"
      else
        notice "Commencing Unison"
        unison "${UNISONPROFILE}"
      fi
    else
      if [ "${USEPROFILE}" = "true" ]; then
        # Throw error if we can't find the profile
        if [ "${UNISONPROFILE}" = "" ]; then
          die "We were missing the Unison Profile.  Could not sync."
        fi
        # Run unison with a profile and specified sources
        if [ "${debug}" = "1" ]; then
          debug "unison ${UNISONPROFILE} ${SOURCEDIRECTORY} ${TARGETDIRECTORY}"
        else
          notice "Commencing Unison"
          unison "${UNISONPROFILE}" "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}"
        fi
      else
        # Run Unison without a profile
        if [ "${debug}" = "1" ]; then
          debug "unison ${SOURCEDIRECTORY} ${TARGETDIRECTORY}"
        else
          notice "Commencing Unison"
          unison "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}"
        fi
      fi
    fi
  fi
}

function notifyPushover() {
  if [ "${PUSHOVERNOTIFY}" = "true" ]; then
    if [ "${debug}" = "1" ]; then
      debug "\"pushover ${SCRIPTNAME} Completed\" \"${SCRIPTNAME} was run in $(convertsecs $TOTALTIME)\""
    else
      pushover "${SCRIPTNAME} Completed" "${SCRIPTNAME} was run in $(convertsecs $TOTALTIME)"
    fi
  fi
}

############## End Script Functions Here ###################


############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

  This script will give you the option of using rsync
  or Unison.  Rsync is for one-way syncing, Unison is for
  two-way syncing.

  Depending on what flags are passed to the script and
  what information is written in the config file, this script
  will perform different behavior.

  USAGE:
    1) Copy this script and rename it for your purpose before running.
       The script will do this for you when run.
    2) Run the new script.  This will create a blank config file
       for you and then exit.
    3) Enter your information within the config file
    4) Run the script again.

  This script requires a config file located at: ${CONFIG}
  Ensure that the config file is correct before running.
  If the config file is not found at all, the script will
  create a new one for you.

  TO DO:
    * Add SSH functionality

 Options:
  -d, --debug       Prints commands to console. Runs no syncs.
  -f, --force       Skip all user interaction.  Implied 'Yes' to all actions
  -h, --help        Display this help and exit
  -l, --log         Print log to file
  -n, --dryrun      Dry run.  If using rsync, will run everything
                    without making any changes
  -q, --quiet       Quiet (no output)
  -s, --strict      Exit script with null variables.  'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -z, --compress    Comress.  If using rsync, this will compress date before
                    transferring.  Good for slow internet connections.
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
    -v|--verbose) verbose=1 ;;
    -l|--log) printLog=1 ;;
    -d|--debug) debug=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--strict) strict=1;;
    -f|--force) force=1 ;;
    -n|--dryrun) DRYRUN=n ;;
    -z|--compress) COMPRESS=z ;;
    --endopts) shift; break ;;
     *) warning "invalid option: $1.\n"; usage >&2; safeExit ;;
#     *) die "invalid option: '$1'." ;;
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

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Exit on error. Append ||true if you expect an error.
set -o errexit

# Exit on empty variable
if [ "${strict}" == "1" ]; then
  set -o nounset
fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail

# Set timer for script to start
STARTTIME=$(date +"%s")

header "${scriptName} Begun"

newCopy
configFile
hostCheck
MethodCheck
moutDrives
testSources
runRsync
runUnison
unmountDrives

# Time the script by logging the end time
ENDTIME=$(date +"%s")
TOTALTIME=$(($ENDTIME-$STARTTIME))

notifyPushover
header "${scriptName} completed in $(convertsecs $TOTALTIME)"

safeExit # Exit cleanly