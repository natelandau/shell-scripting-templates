#!/usr/bin/env bash

# ##################################################
# This script will in restore a new computer from a mackup backup
# using Dropbox.  It requires a config file in '../etc' to run.
#
# HISTORY
# * 2015-01-02 - Initial creation
#
# NOTE: This script ensure that a Dropbox sync has been completed
# by keeping a list of files up-to-date.  These files are listed (one
# per line) in a text file.  If this file falls out of date, this
# script will never run
#
# ##################################################

# Source utils
if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit 0
fi

# Variables from config file
if is_file "../etc/mackup.cfg"; then
  source "../etc/mackup.cfg"
  MACKUPDIR="$DIRCFG"
  TESTFILE="$TESTCFG"
else
  die "Can not run without config file"
fi

#Run Dropbox checking function
hasDropbox

# Confirm we have Dropbox installed by checking for the existence of some synced files.
# IMPORTANT:  As time moves, some of these files may be deleted.  Ensure this list is kept up-to-date.
# This can be tested by running dropboxFileTest.sh script.

if is_not_file "$TESTFILE"; then
  die "Could not find $TESTFILE.  Exiting."
else
  notice "Confirming that Dropbox has synced..."
  while IFS= read -r file
  do
    while [ ! -e $HOME/"$file" ] ;
    do
      notice "Waiting for Dropbox to Sync files."
      sleep 10
    done
  done < "$TESTFILE"
fi

#Add some additional time just to be sure....
notice "Waiting for Dropbox to Sync files."
sleep 10
notice "Waiting for Dropbox to Sync files."
sleep 10
notice "Waiting for Dropbox to Sync files."
sleep 10

# Sync Complete
success "Hooray! Dropbox has synced the necessary files."

if type_not_exists 'mackup'; then
  info "Run 'brew install mackup' or run the Homebrew setup script."
  die "MACKUP NOT FOUND."
fi

# upgrade mackup.  Don't display in terminal
brew upgrade mackup >/dev/null 2>&1

notice "Checking for Mackup config files..."
if is_not_symlink ""$HOME"/.mackup"; then
  ln -s "$MACKUPDIR"/.mackup "$HOME"/.mackup
fi
if is_not_symlink ""$HOME"/.mackup.cfg"; then
  ln -s "$MACKUPDIR"/.mackup.cfg "$HOME"/.mackup.cfg
fi
success "Mackup config files linked."

seek_confirmation "Run Mackup Restore?"
if is_confirmed; then
  mackup restore
  header "All Done."
else
  notice "Exiting"
  exit 0
fi