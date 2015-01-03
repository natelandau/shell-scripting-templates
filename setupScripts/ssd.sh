#!/usr/bin/env bash

# Inspired by ~/.osx — http://mths.be/osx

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

# Update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &



###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################
e_header "Running SSD Specific OSX Tweaks"

seek_confirmation "Confirm that you have an SSD Hard Drive"
if is_confirmed; then

	e_success "Disable local Time Machine snapshots"
	sudo tmutil disablelocal

	e_success "Disable hibernation (speeds up entering sleep mode)"
	sudo pmset -a hibernatemode 0

	e_success "Remove the sleep image file to save disk space"
	sudo rm /Private/var/vm/sleepimage
	e_success "Create a zero-byte file instead…"
	sudo touch /Private/var/vm/sleepimage
	e_success "…and make sure it can’t be rewritten"
	sudo chflags uchg /Private/var/vm/sleepimage

	e_success "Disable the sudden motion sensor as it’s not useful for SSDs"
	sudo pmset -a sms 0

	e_note "DON'T FORGET TO RESTART FOR CHANGES TO TAKE EFFECT"
	e_header "Completed SSD Specific OSX Tweaks"
fi