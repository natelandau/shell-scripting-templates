#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my bash scripts.
#
# VERSION 1.0.0
#
# HISTORY
#
# * 2015-01-02 - v1.0.0 - First Creation
# * 2015-08-05 - v1.0.1 - Now has $hourstamp (10:34:40 PM)
#
# ##################################################

# SCRIPTNAME
# ------------------------------------------------------
# Will return the name of the script being run
# ------------------------------------------------------
scriptName=`basename $0` #Set Script Name variable
scriptBasename="$(basename ${scriptName} .sh)" # Strips '.sh' from scriptName

# TIMESTAMPS
# ------------------------------------------------------
# Prints the current date and time in a variety of formats:
#
# ------------------------------------------------------
now=$(date +"%m-%d-%Y %r")        # Returns: 06-14-2015 10:34:40 PM
datestamp=$(date +%Y-%m-%d)       # Returns: 2015-06-14
hourstamp=$(date +%r)             # Returns: 10:34:40 PM
timestamp=$(date +%Y%m%d_%H%M%S)  # Returns: 20150614_223440
today=$(date +"%m-%d-%Y")         # Returns: 06-14-2015

# THISHOST
# ------------------------------------------------------
# Will print the current hostname of the computer the script
# is being run on.
# ------------------------------------------------------
thisHost=$(hostname)