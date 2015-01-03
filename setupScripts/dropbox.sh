#!/usr/bin/env bash

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit 0
fi

# Confirm we have Dropbox
hasDropbox

