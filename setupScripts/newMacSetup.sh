#!/usr/bin/env bash

# ##################################################
# This script cycles through all my setup scripts.  Run
# this script when you are starting fresh on a computer and
# it will take care of everything.
#
# HISTORY
# * 2015-01-02 - Initial creation
#
# ##################################################

# Source global utilities
if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run. Exiting."
  exit
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
	./homebrew.sh
	./casks.sh
	./ruby.sh
	./mackup.sh
	./osx.sh
	./ssh.sh
"

seek_confirmation "Do you want to run all the scripts at once?"
if is_confirmed; then
	for file in $FILES
	do
		if is_file "$file"; then
			$file
		else
			die "$file does not exist. Exiting"
		fi
	done
else
for file in $FILES
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
