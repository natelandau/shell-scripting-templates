#!/usr/bin/env bash


# ##################################################
# My Generic sync script.
#
version="2.1.0"  # Sets version variable
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
# * 2015-03-15 - v2.0.0 - Added support for encrypted config files.
# * 2015-03-21 - v2.1.0 - Added support for extended RSYNC configurations.
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
editConfig=0
mountTest=0

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


# Configuration file(s)
# -----------------------------------
# This script calls for a configuration file.
# This is its location.  Default is the location
# where it will be automatically created.`
# -----------------------------------
tmpConfig="${tmpDir}/${scriptName}.cfg"
newConfig="./${scriptName}.cfg"
encConfig="../etc/${scriptName}.cfg.enc"

############## Begin Script Functions Here ###################

# Create new copy of the script if template is being executed
function newCopy() {
  if [ "${scriptName}" = "syncTemplate.sh" ]; then
    input "name your new script:"
    read newname
    verbose "Copying SyncTemplate.sh to ${newname}"
    cp "${scriptPath}"/"${scriptName}" "${scriptPath}"/"${newname}" && verbose "cp ${scriptPath}/${scriptName} ${scriptPath}/${newname}"
    success "${newname} created."
    safeExit
  fi
}

function encryptConfig() {
# If a non-encrypted config file exists (ie - it was being edited) we encrypt it
  if is_file "${newConfig}"; then
    verbose "${newConfig} exists"
    seek_confirmation "Are you ready to encrypt your config file?"
    if is_confirmed; then
      if is_file "${encConfig}"; then
        rm "${encConfig}" && verbose "Existing encoded config file exists. Running: rm ${encConfig}"
      fi
      if is_empty ${PASS}; then # Look for password from CLI
        verbose "openssl enc -aes-256-cbc -salt -in ${newConfig} -out ${encConfig}"
        openssl enc -aes-256-cbc -salt -in "${newConfig}" -out "${encConfig}"
      else
        verbose "openssl enc -aes-256-cbc -salt -in ${newConfig} -out ${encConfig} -k [PASSWORD]"
        openssl enc -aes-256-cbc -salt -in "${newConfig}" -out "${encConfig}" -k ${PASS}
      fi
      rm "${newConfig}" && verbose "rm ${newConfig}"
      success "Encoded the config file."
      safeExit
    else
      warning "You need to encrypt your config file before proceeding"
      safeExit
    fi
  fi
}

function createTempConfig() {
  # If we find the encoded config file, we decrypt it to the temp location
  if is_file "${encConfig}"; then
    if is_empty ${PASS}; then # Look for password from CLI
      verbose "openssl enc -aes-256-cbc -d -in ${encConfig} -out ${tmpConfig}"
      openssl enc -aes-256-cbc -d -in "${encConfig}" -out "${tmpConfig}"
    else
      verbose "openssl enc -aes-256-cbc -d -in ${encConfig} -out ${tmpConfig} -k [PASSWORD]"
      openssl enc -aes-256-cbc -d -in "${encConfig}" -out "${tmpConfig}" -k ${PASS}
    fi
  fi
}

function sourceConfiguration() {
  # Here we source the Config file or create a new one if none exists.
  if is_file "${tmpConfig}"; then
    source "${tmpConfig}" && verbose "source ${tmpConfig}"
  else
    seek_confirmation "Config file does not exist.  Would you like to create one?"
    if is_not_confirmed; then
      die "No config file."
    else
      touch "${newConfig}" && verbose "touch ${newConfig}"
  cat >"${newConfig}" <<EOL
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

# EXCLUDE sets rsync to exclude files from syncing based on a pattern.
# Defaults to null.
# If needed, add individual excludes in the format of "--exclude file1.txt --exclude file2.txt".
EXCLUDE=""

# EXCLUDELIST is a text file that contains all the rsync excludes.
# Anything listed within this file will be ignored during sync.
# Default is null.
# Set value to "--exclude-from=/some/file/location.txt" if needed
EXCLUDELIST=""

# DELETE sets the variable to delete files in the target directory that are deleted from
# the source directory.  In effect, keeping them 'in-sync'. Defaults to equal "--delete"
# which sets that flag.  Set to null to ensure all files on the target remain when deleted
# from the source.
DELETE="--delete"

# ---------------------------
# ADDITIONAL OPTIONS
# ---------------------------

# PUSHOVER is an online notification tool.
# If you want to receive notifications upon completion
# set the following value to "true"
PUSHOVERNOTIFY="false"

# CANONICALHOST is used to denote a sync hub which should never initiate a sync.
# Leave blank if not needed.
CANONICALHOST=""
EOL
  success "Config file created. Edit the values before running this script again."
  notice "The file is located at: ${newConfig}.  Exiting."
  safeExit
  fi
fi
}

function editConfiguration() {
# If the '--config' is set to true, we create an editable config file for re-encryption
  if [ "${editConfig}" == "1" ]; then
    verbose "editConfig is true"
    seek_confirmation "Would you like to edit your config file?"
    if is_confirmed; then
      if is_file "${tmpConfig}"; then
        cp "${tmpConfig}" "${newConfig}" && verbose "cp ${tmpConfig} ${newConfig}"
        success "Config file has been decrypted to ${newConfig}.  Edit the file and rerun the script."
        safeExit
      else
        die "Couldn't find ${tmpConfig}."
      fi
    else
      notice "Exiting."
      safeExit
    fi
  fi
}


# HostCheck
# Confirm we can run this script.  If a canonical host is set in
# the config file we check it here.
function hostCheck() {
  if [ "${thisHost}" = "${CANONICALHOST}" ]; then
    notice "We are currently on ${THISHOST} and can not proceed. Be sure to run this script on the non-canonical host. Exiting"
    safeExit
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

    #Allow for debugging with only the mount function
    if [ ${mountTest} = 1 ]; then
      seek_confirmation "Are you ready to unmount the drive"
      if is_confirmed; then
        unmountDrives
        safeExit
      fi
    fi
  fi
}

function unmountDrives() {
  # Unmount the drive (if mounted)
  if [ "${NEEDMOUNT}" = "true" ] || [ "${NEEDMOUNT}" = "TRUE" ]; then
    unmountDrive "${REMOTEVOLUME}" && verbose "unmountDrive ${REMOTEVOLUME}"
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
  # Populate logfile variable if "printlog=1"
  if [ "${printLog}" = 1 ]; then
    RSYNCLOG="--log-file=${logFile}"
  else
    RSYNCLOG=""
  fi
  if [ "${METHOD}" = "rsync" ]; then
      notice "Commencing rsync"
      verbose "rsync -vahh${DRYRUN}${COMPRESS} --progress --force ${DELETE} ${EXCLUDE} ${EXCLUDELIST} ${SOURCEDIRECTORY} ${TARGETDIRECTORY} ${RSYNCLOG}"
      rsync -vahh${DRYRUN}${COMPRESS} --progress --force ${DELETE} ${EXCLUDE} ${EXCLUDELIST} "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}" ${RSYNCLOG}
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
      notice "Commencing Unison"
      verbose "unison ${UNISONPROFILE}" && unison "${UNISONPROFILE}"
    else
      if [ "${USEPROFILE}" = "true" ]; then
        # Throw error if we can't find the profile
        if [ "${UNISONPROFILE}" = "" ]; then
          die "We were missing the Unison Profile.  Could not sync."
        fi
        # Run unison with a profile and specified sources
        notice "Commencing Unison"
        verbose "unision ${UNISONPROFILE} ${SOURCEDIRECTORY} ${TARGETDIRECTORY}" && unison "${UNISONPROFILE}" "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}"
      else
        # Run Unison without a profile
        notice "Commencing Unison"
        verbose "unison ${SOURCEDIRECTORY} ${TARGETDIRECTORY}" && unison "${SOURCEDIRECTORY}" "${TARGETDIRECTORY}"
      fi
    fi
  fi
}

function notifyPushover() {
  if [ "${PUSHOVERNOTIFY}" = "true" ]; then
    verbose "\"pushover ${SCRIPTNAME} Completed\" \"${SCRIPTNAME} was run in $(convertsecs $TOTALTIME)\""
    pushover "${SCRIPTNAME} Completed" "${SCRIPTNAME} was run in $(convertsecs $TOTALTIME)"
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

  This script requires an encoded config file located at: ${encConfig}
  Ensure that the config file is correct before running.
  If the config file is not found at all, the script will
  create a new one for you.

  To edit the configuration file, run the script with the '-c' flag.

 Options:
  -c, --config      Decrypts the configuration file to allow it to be edited.
  -d, --debug       Prints commands to console. Runs no syncs.
  -f, --force       Rsync only. Skip all user interaction. Implied 'Yes' to all actions.
  -h, --help        Display this help and exit.
  -l, --log         Print log to file.
  -n, --dryrun      Rsync only. Dry run - will run everything without making any changes.
  -m, --mounttest   Will run the mount/unmount drive portion of the script and bypass all syncing.
  -p, --password    Prompts for the password which decrypts the configuration file.
  -q, --quiet       Quiet (no output)
  -s, --strict      Exit script with null variables.  'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -z, --compress    Rsync only. This will compress data before transferring.
                    Good for slow internet connections.
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
    -p|--password) shift; echo "Enter Pass: "; stty -echo; read PASS; stty echo;
      echo ;;
    -v|--verbose) verbose=1 ;;
    -l|--log) printLog=1 ;;
    -c|--config) editConfig=1 ;;
    -d|--debug) debug=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--strict) strict=1;;
    -f|--force) force=1 ;;
    -n|--dryrun) DRYRUN=n ;;
    -m|--mounttest) mountTest=1 ;;
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

# Run in debug mode, if set
if [ "${debug}" == "1" ]; then
  set -x
fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail

# Set timer for script to start
STARTTIME=$(date +"%s")

header "${scriptName} Begun"

newCopy
encryptConfig
createTempConfig
editConfiguration
sourceConfiguration
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
