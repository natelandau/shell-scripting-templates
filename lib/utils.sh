#!/usr/bin/env bash


# Source additional files
# ------------------------------------------------------
# The list of additional utility files to be sourced
# ------------------------------------------------------

# First we locate this script and populate the $SCRIPTPATH variable
# Doing so allows us to source additional files from this utils file.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve ${SOURCE} until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if ${SOURCE} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCEPATH="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

# Write the list of utility files to be sourced
FILES="
  sharedVariables.sh
  sharedFunctions.sh
  setupScriptFunctions.sh
"

# Source the Utility Files
for file in $FILES
do
  if [ -f "${SOURCE}PATH/${file}" ]; then
    source "${SOURCE}PATH/${file}"
  else
    e_error "${file} does not exist.  Exiting"
    Exit 1
  fi
done

# Logging and Colors
# ------------------------------------------------------
# Here we set the colors for our script feedback.
# Example usage: e_success "sometext"
#------------------------------------------------------

# Set Colors
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

# Headers and  Logging
e_header() { echo -e "\n${bold}${purple}==========  $@  ==========${reset}\n" ; }
e_arrow() { echo -e "➜ $@" ; }
e_success() { echo -e "${green}✔ $@${reset}" ; }
e_error() { echo -e "${red}✖ $@${reset}" ; }
e_warning() { echo -e "${tan}➜ $@${reset}" ; }
e_underline() { echo -e "${underline}${bold}$@${reset}" ; }
e_bold() { echo -e "${bold}$@${reset}" ; }
e_note() { echo -e "${underline}${bold}${blue}Note:${reset}  ${blue}$@${reset}" ; }




# Note to self
# This is how you create a variable with multiple lines
# read -d '' String <<"EOF"
#   one
#   two
#   three
#   four
# EOF
# echo ${String}
