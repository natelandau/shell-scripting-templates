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

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run. Exiting."
  exit
fi

seek_confirmation "Do you want to run the Dropbox script to install it first?"
if is_confirmed; then
	if [ -e ./dropbox.sh ]; then
		./dropbox.sh
	else
		e_error "Can't find dropbox.sh"
		seek_confirmation "Continue running other scripts?"
		if is_not_confirmed; then
			e_error "Exiting"
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
	./ssd.sh
"

seek_confirmation "Do you want to run all the scripts at once?"
if is_confirmed; then
	for file in $FILES
	do
		if [ -e "$file" ]; then
			$file
		else
			e_error "$file does not exist. Exiting"
			exit 0
		fi
	done
else
for file in $FILES
	do
		seek_confirmation "Do you want to run $file?"
		if is_confirmed; then
			if [ -e "$file" ]; then
				$file
			else
				e_error "$file does not exist."
			fi
		fi
	done
fi
