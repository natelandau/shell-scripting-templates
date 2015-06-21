#!/usr/bin/env bash

# ##################################################
# This script cycles through all my setup scripts to bootstrap a
# new computer.  Run this script when you are starting fresh on
# a computer and it will take care of everything.
#
# HISTORY
# * 2015-01-02 - Initial creation
# * 2015-06-21 - Added Flash and XCode command line tools
#
# ##################################################

# Provide a variable with the location of this script.
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------

utilsLocation="${scriptPath}/../lib/utils.sh" # Update this path to find the utilities.

if [ -f "${utilsLocation}" ]; then
  source "${utilsLocation}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi


seek_confirmation "Do you want to run the Dropbox script to install it first?"
if is_confirmed; then
	if is_file "./dropbox.sh"; then
		./dropbox.sh
	else
		error "Can't find dropbox.sh"
		seek_confirmation "Continue running other scripts?"
		if is_not_confirmed; then
			warning "Exiting."
			exit 0
		fi
	fi
fi

#List of Scripts to be run
FILES="
	./install_command_line_tools.sh
	./homebrew.sh
	./casks.sh
	./ruby.sh
	./mackup.sh
	./osx.sh
	./ssh.sh
	./install_latest_adobe_flash_player.sh
"

seek_confirmation "Do you want to run all the scripts at once?"
if is_confirmed; then
	for file in "$FILES"
	do
		if is_file "$file"; then
			$file
		else
			die "$file does not exist. Exiting"
		fi
	done
else
for file in "$FILES"
	do
		seek_confirmation "Do you want to run $file?"
		if is_confirmed; then
			if is_file "$file"; then
				$file
			else
				die "$file does not exist."
			fi
		fi
	done
fi
