#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my bash scripts.
#
# HISTORY
# * 2015-01-02 - Initial creation
#
# ##################################################

# SCRIPTNAME
# ------------------------------------------------------
# Will return the name of the script being run
# ------------------------------------------------------
SCRIPTNAME=`basename $0` #Set Script Name variable

# NOW
# ------------------------------------------------------
# Will print the current date and time in the format:
# 01-02-2015 01:09:54 PM
# ------------------------------------------------------
NOW=$(date +"%m-%d-%Y %r") #Set Timestamp in variable

# THISHOST
# ------------------------------------------------------
# Will print the current hostname of the computer the script
# is being run on.
# ------------------------------------------------------
THISHOST=$(hostname)