#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "${SCRIPTDIR}/../lib/utils.sh" ]; then
  source "${SCRIPTDIR}/../lib/utils.sh"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi


# Confirm we have Dropbox
# hasDropbox



