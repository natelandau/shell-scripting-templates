#!/usr/bin/env bash

# ##################################################
# My Generic sync script.
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
# DISCLAIMER:
# I am a novice programmer and I bear no responsibility whatsoever
# if this (or any other) script that I write wipes your computer,
# destroys your data, crashes your car, or otherwise causes mayhem
# and destruction.  USE AT YOUR OWN RISK.
#
VERSION="1.1"
#
# HISTORY
# * 2015-01-03 - v.1.1  - Added version number
#                       - Added support for using roots in Unison .prf
# * 2015-01-02 - v.1.0  - First Creation
#
# ##################################################

# Source Scripting Utilities
if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi

# This script calls for a configuration file.
# This is its location
CONFIG="../etc/$SCRIPTNAME.cfg"


# HELP
# When -h is passed to the script, this will display inline help
function HELP () {
  e_bold "\nHelp for $SCRIPTNAME"
  echo -e "This script will give you the option of using rsync"
  echo -e "or Unison.  Rsync is for one-way syncing, Unison is for"
  echo -e "two-way syncing.\n"
  echo -e "Depending on what flags are passed to the script and"
  echo -e "what information is written in the config file, this script"
  echo -e "will perform different behavior.\n"
  echo -e "USAGE:"
  echo -e "  1) Copy this script and rename it for your purpose before running."
  echo -e "     The script will do this for you when run."
  echo -e "  2) Run the new script.  This will create a blank config file for you and then exit."
  echo -e "  3) Enter your information within the config file"
  echo -e "  4) Run the script again.\n"
  echo -e "This script requires a config file located at: \"$CONFIG\""
  echo -e "Ensure that the config file is correct before running."
  echo -e "If the config file is not found at all, the script will create a new one for you.\n"
  echo -e "MODIFIERS:"
  echo -e "-n: Dry Run. This will show what would have been transferred.  Works in rsync only."
  echo -e "-z: Compresses data during the transfer. Good for low bandwidth. Works in rsync only."
  echo -e "-h: View help"
  exit 0
}

# READ OPTIONS
# Reads the options passed to the script
# from the command line
# ------------------------
while getopts "hnz" opt; do
  case $opt in
    h) # show help
      HELP
      ;;
    n) # Show progress in terminal
      DRYRUN="n"
      ;;
    z) # Compress Data
      COMPRESS="z"
      ;;
    \?)
      HELP
      ;;
  esac
done

# Create new copy of the script if template is being executed
function newCopy() {
  scriptPath
  if [ "$SCRIPTNAME" = "SyncTemplate.sh" ]; then
    e_bold "name your new script:"
    read newname
    cp "$SCRIPTPATH"/"$SCRIPTNAME" "$SCRIPTPATH"/"$newname"
    e_success "$newname created."
    exit 0
  fi
}

function configFile() {
  # Here we source the Config file or create a new one if none exists.
  if is_file "$CONFIG"; then
    source "$CONFIG"
  else
    seek_confirmation "Config file does not exist.  Would you like to create one?"
    if is_not_confirmed; then
      die "No config file.  Exiting"
    else
      touch "$CONFIG"
  cat >"$CONFIG" <<EOL
# ##################################################
# CONFIG FILE FOR $SCRIPTNAME
# CREATED ON $NOW
#
# Created by version "$VERSION" of "SyncTemplate.sh"
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

# LOGFILE is a text file to log all script activity to.
# Use the format /some/directory/file.txt
# If you don't want a log of the activity leave this as /dev/null
LOGFILE="/dev/null"

# PUSHOVER is an online notification tool.
# If you want to receive notifications upon completion
# set the following value to "true"
PUSHOVERNOTIFY="false"

# CANONICALHOST is used to denote a sync hub which should never initiate a sync.
# Leave blank if not needed.
CANONICALHOST=""
EOL
  e_success "Config file created. Edit the values before running this script again."
  e_arrow "The file is located at: $CONFIG"
  echo "Exiting."
  exit 0
  fi
fi
}


# HostCheck
# Confirm we can run this script.  If a canonical host is set in
# the config file we check it here.
function hostCheck() {
  if [ "$THISHOST" = "$CANONICALHOST" ]; then
    echo "$NOW - Script was not run since we were on the wrong host" >> "$LOGFILE"
    die "We are currently on $THISHOST and can not proceed. Be sure to run this script on the non-canonical host."
  fi
}

# MethodCheck
# Confirm we have either Unison or Rsync specified
# in the config file. Exit if not
function MethodCheck() {
  if [ "$METHOD" != "rsync" ] && [ "$METHOD" != "unison" ]; then
    echo "$NOW - Script aborted without a method specified in the config file." >> "$LOGFILE"
    die "We can not continue.  Please specify a sync method in the config file."
  fi
}

function mainScript() {
  # Time the script by logging the start time
  STARTTIME=$(date +"%s")

  # Log Script Start to $LOGFILE
  echo -e "-----------------------------------------------------" >> "$LOGFILE"
  echo -e "$NOW - $SCRIPTNAME Begun" >> "$LOGFILE"
  echo -e "-----------------------------------------------------\n" >> "$LOGFILE"


  if [ "$NEEDMOUNT" = "true" ] || [ "$NEEDMOUNT" = "TRUE" ]; then
    # Mount AFP volume
    if is_not_dir "$REMOTEVOLUME"; then
      e_arrow "Mounting drive"
      mkdir "$REMOTEVOLUME"
      if [ "$MOUTPW" = "true" ]; then # if password prompt needed
        mount_afp -i "$MOUNTPOINT" "$REMOTEVOLUME"
      else
        mount_afp "$MOUNTPOINT" "$REMOTEVOLUME"
      fi
      sleep 10
      echo "$NOW - $REMOTEVOLUME Mounted" >> "$LOGFILE"
      e_success "$REMOTEVOLUME Mounted"
    else
      e_success "$REMOTEVOLUME already mounted"
    fi
  fi

  # Test for source directories.
  # If they don't exist we can't continue

  # test for target
  if is_dir "$TARGETDIRECTORY"; then
    e_success "$TARGETDIRECTORY exists"
  else
    if [ "$NEEDMOUNT" = "true" ] || [ "$NEEDMOUNT" = "TRUE" ]; then
      unmountDrive "$REMOTEVOLUME"
      if is_dir "$REMOTEVOLUME"; then
        rm -r "$REMOTEVOLUME"
      fi
    fi
    echo -e "$NOW - Script aborted since target dir: $TARGETDIRECTORY was not found.  Exited.\n" >> "$LOGFILE"
    die "target directory: $TARGETDIRECTORY does not exist. Exiting."
  fi

  # Test for source directory
  if is_dir "$SOURCEDIRECTORY"; then
    e_success "$SOURCEDIRECTORY exists"
  else
    if [ "$NEEDMOUNT" = "true" ] || [ "$NEEDMOUNT" = "TRUE" ]; then
      unmountDrive "$REMOTEVOLUME"
      if is_dir "$REMOTEVOLUME"; then
        rm -r "$REMOTEVOLUME"
      fi
    fi
    echo -e "$NOW - Script aborted since source dir: $SOURCEDIRECTORY was not found.  Exited.\n" >> "$LOGFILE"
    die "source directory: $SOURCEDIRECTORY does not exist. Exiting."
  fi

  # Time to sync
  if [ "$METHOD" = "rsync" ]; then
    /usr/bin/rsync -vahh"$DRYRUN""$COMPRESS" --progress --force --delete --exclude-from="$EXCLUDE" "$SOURCEDIRECTORY" "$TARGETDIRECTORY" --log-file="$LOGFILE"
  fi
  if [ "$METHOD" = "unison" ]; then

    # Check if Unison is installed.  It is not a standard package
    if type_not_exists 'unison'; then
      seek_confirmation "Unison not installed, install it?"
      if is_confirmed; then
        hasHomebrew
        brewMaintenance
        brew install unison
      else
        if [ "$NEEDMOUNT" = "true" ] || [ "$NEEDMOUNT" = "TRUE" ]; then
          unmountDrive "$REMOTEVOLUME"
          if is_dir "$REMOTEVOLUME"; then
            rm -r "$REMOTEVOLUME"
          fi
        fi
        die "Can not continue without Unison."
      fi
    fi

    # Run Unison
    if [ "$PROFILEROOTS" = "true" ]; then
      # Throw error if we don't have enough information
      if [ "$USEPROFILE" = "false" ] || [ "$UNISONPROFILE" = "" ]; then
        echo "$NOW - We were missing the Unison Profile.  Could not sync." >> "$LOGFILE"
        die "We were missing the Unison Profile.  Could not sync."
      fi
      # Run unison with the profile
      echo "$NOW - Beginning Unison with command: unison $UNISONPROFILE" >> "$LOGFILE"
      unison "$UNISONPROFILE"
    else
      if [ "$USEPROFILE" = "true" ]; then
        # Throw error if we can't find the profile
        if [ "$UNISONPROFILE" = "" ]; then
          echo "$NOW - We were missing the Unison Profile.  Could not sync." >> "$LOGFILE"
          die "We were missing the Unison Profile.  Could not sync."
        fi
        # Run unison with a profile
        echo "$NOW - Beginning Unison with command: unison $UNISONPROFILE $SOURCEDIRECTORY $TARGETDIRECTORY" >> "$LOGFILE"
        unison "$UNISONPROFILE" "$SOURCEDIRECTORY" "$TARGETDIRECTORY"
      else
        # Run Unison without a profile
        echo "$NOW - Beginning Unison with command: unison $SOURCEDIRECTORY $TARGETDIRECTORY" >> "$LOGFILE"
        unison "$SOURCEDIRECTORY" "$TARGETDIRECTORY"
      fi
    fi
  fi

  # Unmount the drive (if mounted)
  if [ "$NEEDMOUNT" = "true" ] || [ "$NEEDMOUNT" = "TRUE" ]; then
    unmountDrive "$REMOTEVOLUME"
    echo "$NOW - $REMOTEVOLUME Unmounted" >> "$LOGFILE"
    e_success "$REMOTEVOLUME UnMounted"
  fi

  # Time the script by logging the end time
  ENDTIME=$(date +"%s")
  TOTALTIME=$(($ENDTIME-$STARTTIME-20))

  # notify with pushover if requested
  if [ "$PUSHOVERNOTIFY" = "true" ]; then
    pushover "$SCRIPTNAME Completed" "$SCRIPTNAME was run in $(convertsecs $TOTALTIME)"
  fi

  echo -e "\n-----------------------------------------------------" >> "$LOGFILE"
  echo "$NOW - $SCRIPTNAME completed in $(convertsecs $TOTALTIME)" >> "$LOGFILE"
  echo -e "-----------------------------------------------------\n" >> "$LOGFILE"

  e_success "$NOW - $SCRIPTNAME completed in $(convertsecs $TOTALTIME)"
}

newCopy
configFile
hostCheck
MethodCheck
mainScript