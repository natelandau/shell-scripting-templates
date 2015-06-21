#!/usr/bin/env bash

# ##################################################
#
# This script was taken in its entirety from:
# https://github.com/rtrouton/rtrouton_scripts/
#
# This script will download a disk image containing the latest Adobe Flash
# Player and install Flash Player using the installer package stored inside
# the downloaded disk image.
#
# How the script works:
#
# 1. Uses curl to download a disk image containing the latest Flash Player
#    installer from Adobe's web site
# 2. Renames the downloaded disk image to flash.dmg and stores it in /tmp
# 2. Mounts the disk image silently in /tmp. Disk image will not be visible
#    to any logged-in user.
# 3. Installs the latest Flash Player using the installer package stored on
#    the disk image
# 4. After installation, unmounts the disk image and removes it from the Mac
#    in question.
#
version="1.0.0"               # Sets version variable
#
scriptTemplateVersion="1.4.1" # Version of scriptTemplate.sh that this script is based on
#
# HISTORY:
#
# * 2015-06-21 - v1.0.0 - First Creation
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
logFile="$HOME/Library/Logs/${scriptBasename}.log"

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

# invoke verbose usage of commands when set
if $verbose; then v="-v" ; fi

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Determine current major version of Adobe Flash for use
# with the fileURL variable
flash_major_version=`/usr/bin/curl --silent http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml | cut -d , -f 1 | awk -F\" '/update version/{print $NF}'`

# Specify the complete address of the Adobe Flash Player
# disk image
 fileURL="http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_"${flash_major_version}"_osx_pkg.dmg"

flash_dmg="${tmpDir}/flash.dmg"

if [[ ${osvers} -lt 6 ]]; then
  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below."
fi

if [[ ${osvers} -ge 6 ]]; then

    # Download the latest Adobe Flash Player software disk image

    /usr/bin/curl --output "${flash_dmg}" "${fileURL}"

    # Specify a /tmp/flashplayer.XXXX mountpoint for the disk image

    TMPMOUNT=`/usr/bin/mktemp -d ${tmpDir}/flashplayer.XXXX`

    # Mount the latest Flash Player disk image to /tmp/flashplayer.XXXX mountpoint

    hdiutil attach "$flash_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    pkg_path="$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Flash*\.pkg -o -iname \*Flash*\.mpkg \))"

    # Before installation on Mac OS X 10.7.x and later, the installer's
    # developer certificate is checked to see if it has been signed by
    # Adobe's developer certificate. Once the certificate check has been
    # passed, the package is then installed.

    if [[ ${pkg_path} != "" ]]; then
       if [[ ${osvers} -ge 7 ]]; then
         signature_check=`/usr/sbin/pkgutil --check-signature "$pkg_path" | awk /'Developer ID Installer/{ print $5 }'`
         if [[ ${signature_check} = "Adobe" ]]; then
           # Install Adobe Flash Player from the installer package stored inside the disk image
           /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "/"
         fi
       fi

    # On Mac OS X 10.6.x, the developer certificate check is not an
    # available option, so the package is just installed.

       if [[ ${osvers} -eq 6 ]]; then
           # Install Adobe Flash Player from the installer package stored inside the disk image
           /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "/"
       fi
    fi

    # Clean-up

    # Unmount the Flash Player disk image from /tmp/flashplayer.XXXX

    /usr/bin/hdiutil detach "$TMPMOUNT"

    # Remove the /tmp/flashplayer.XXXX mountpoint

    rm -rf $v "$TMPMOUNT"

    # Remove the downloaded disk image

    rm -rf $v "$flash_dmg"
fi

####################################################
############### End Script Here ####################
}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This script was taken in its entirety from:
https://github.com/rtrouton/rtrouton_scripts/

This script will download a disk image containing the latest Adobe Flash
Player and install Flash Player using the installer package stored inside
the downloaded disk image.

How the script works:

1. Uses curl to download a disk image containing the latest Flash Player
   installer from Adobe's web site
2. Renames the downloaded disk image to flash.dmg and stores it in /tmp
2. Mounts the disk image silently in /tmp. Disk image will not be visible
   to any logged-in user.
3. Installs the latest Flash Player using the installer package stored on
   the disk image
4. After installation, unmounts the disk image and removes it from the Mac
   in question.

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

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
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