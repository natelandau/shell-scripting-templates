#!/usr/bin/env bash

# This script tests for the existence of certain files in Dropbox.
# It is used to keep a current list in the mackup.sh script.

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit 0
fi

# Variables from config file
if is_file "../etc/mackup.cfg"; then
  source "../etc/mackup.cfg"
  TESTFILE="$TESTCFG"
else
  die "Can not run without config file"
fi

if is_not_file "$TESTFILE"; then
  die "Could not find $TESTFILE.  Exiting."
else
  e_arrow "Confirming that Dropbox has synced..."
  while IFS= read -r file
  do
    while [ ! -e $HOME/"$file" ] ;
    do
      e_warning "Waiting for Dropbox to Sync files."
      sleep 10
    done
    e_success "Found $file"
  done < "$TESTFILE"
fi