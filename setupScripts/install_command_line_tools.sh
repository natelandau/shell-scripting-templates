#!/usr/bin/env bash

# ##################################################
#
# # This script was taken in its entirety from:
# https://github.com/rtrouton/rtrouton_scripts/
#
# This script will download and install the Xcode command line
# tools on Macs running 10.7.x and higher.
#
# How the script works:
#
# On 10.9.x and 10.10.x:
#
# 1. Creates a placeholder file in $tmpDir. This file's existence is checked by the
#    softwareupdate tool before allowing the installation of the Xcode command line tools.
#
# 2. Runs the softwareupdate tool and checks for the latest version of the Xcode command
#    line tools for the OS in question.
#
# 3. Uses the softwareupdate tool to install the latest version of the Xcode command
#    line tools for the OS in question.
#
# 4. Removes the placeholder file stored in /tmp.
#
#
# On 10.7.x and 10.8.x:
#
# 1. Uses curl to download a disk image containing the specified Xcode Command Line
#    Tools installer from Apple's web site
#
# 2. Renames the downloaded disk image to cltools.dmg.
#
# 2. Mounts the disk image silently in $tmpDir. Disk image will not be visible to any
#    logged-in user.
#
# 3. Installs the Xcode Command Line Tools using the installer package stored on the
#    disk image
#
# 4. After installation, unmounts the disk image and removes it from the Mac in question.
#
version="1.0.0"               # Sets version variable
#
scriptTemplateVersion="1.4.1" # Version of scriptTemplate.sh that this script is based on
#
# HISTORY:
#
# * 2015-06-21 - v1.0.0  - First Creation
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

# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."  # Edit this if you like.
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=0
printLog=0
verbose=0
force=0
strict=0
debug=0
args=()

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="${HOME}/Library/Logs/${scriptBasename}.log"

# Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.  Mac applications will be installed using
# Homebrew Casks. Ruby and gems via RVM.
# -----------------------------------
homebrewDependencies=()
caskDependencies=()
gemDependencies=()

function mainScript() {
############## Begin Script Here ###################
####################################################

# Installing the Xcode command line tools on 10.7.x or higher

osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
cmd_line_tools_temp_file="${tmpDir}/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# invoke verbose usage when set
if ${verbose}; then v="-v" ; fi

# Installing the latest Xcode command line tools on 10.9.x or higher

if [[ "${osx_vers}" -ge 9 ]]; then

  # Create the placeholder file which is checked by the softwareupdate tool
  # before allowing the installation of the Xcode command line tools.

  touch "${cmd_line_tools_temp_file}"

  # Find the last listed update in the Software Update feed with "Command Line Tools" in the name

  cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | tail -1 | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)

  #Install the command line tools

  softwareupdate -i "${cmd_line_tools}" -v

  # Remove the temp file

  if [[ -f "${cmd_line_tools_temp_file}" ]]; then
    rm ${v} "${cmd_line_tools_temp_file}"
  fi
fi

# Installing the latest Xcode command line tools on 10.7.x and 10.8.x

# on 10.7/10.8, instead of using the software update feed, the command line tools are downloaded
# instead from public download URLs, which can be found in the dvtdownloadableindex:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex

if [[ "${osx_vers}" -eq 7 ]] || [[ "${osx_vers}" -eq 8 ]]; then

  if [[ "${osx_vers}" -eq 7 ]]; then
      DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
  fi

  if [[ "${osx_vers}" -eq 8 ]]; then
       DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg
  fi

    TOOLS=cltools.dmg
    curl "${DMGURL}" -o "${TOOLS}"
    TMPMOUNT=`/usr/bin/mktemp -d ${tmpDir}/clitools.XXXX`
    hdiutil attach "${TOOLS}" -mountpoint "${TMPMOUNT}" -nobrowse
    # The "-allowUntrusted" flag has been added to the installer
    # command to accomodate for now-expired certificates used
    # to sign the downloaded command line tools.
    installer -allowUntrusted -pkg "$(find ${TMPMOUNT} -name '*.mpkg')" -target /
    hdiutil detach "${TMPMOUNT}"
    rm -rf ${v} "${TMPMOUNT}"
    rm ${v} "${TOOLS}"
fi

####################################################
############### End Script Here ####################
}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This script will download and install the Xcode command line tools on Macs
running 10.7.x and higher.

How the script works:

On 10.9.x and 10.10.x:

1. Creates a placeholder file in /tmp. This file's existence is checked by
   the softwareupdate tool before allowing the installation of the Xcode command
   line tools.

2. Runs the softwareupdate tool and checks for the latest version of the Xcode
   command line tools for the OS in question.

3. Uses the softwareupdate tool to install the latest version of the Xcode command
   line tools for the OS in question.

4. Removes the placeholder file stored in /tmp.


On 10.7.x and 10.8.x:

1. Uses curl to download a disk image containing the specified Xcode Command Line
   Tools installer from Apple's web site

2. Renames the downloaded disk image to cltools.dmg.

2. Mounts the disk image silently in /tmp. Disk image will not be visible to any
   logged-in user.

3. Installs the Xcode Command Line Tools using the installer package stored on the
disk image

4. After installation, unmounts the disk image and removes it from the Mac in question.

This script was taken in its entirety from:
https://github.com/rtrouton/rtrouton_scripts/

 Options:
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed
# and --foo=bar into --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "$(basename $0) ${version}"; safeExit ;;
    -u|--username) shift; username=${1} ;;
    -p|--password) shift; echo "Enter Pass: "; stty -echo; read PASS; stty echo;
      echo ;;
    -v|--verbose) verbose=true ;;
    -l|--log) printLog=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--strict) strict=1;;
    -d|--debug) debug=1;;
    --force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

############## End Options and Usage ###################




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if [ "${debug}" == "1" ]; then
  set -x
fi

# Exit on empty variable
if [ "${strict}" == "1" ]; then
  set -o nounset
fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Invoke the checkDependenices function to test for Bash packages
# checkDependencies

# Run your script
mainScript

safeExit # Exit cleanly