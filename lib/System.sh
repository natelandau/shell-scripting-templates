#!/usr/bin/env bash

# Library of functions related to Linux Systems
#
# @author  Michael Strache


# Checks if the sources of KERNEL exist in the local system
#
# @param String   KERNEL          Name of the kernel
#
# @return Boolean  true if the sources exists, otherwise false
function System::Kernel::exists() {
  local -r KERNEL="${1:-}"; shift

  [[ -d $( System::Kernel::get_sources ${KERNEL} ) ]]
}


# Returns the string representation of an array of all kernel sources available in '/usr/src' (lowest first, highest last)
#
# @return String  String representation of an array (e.g. "4.4.6-gentoo 4.4.39-gentoo")
function System::Kernel::get_available() {
  # List all kernel sources folders, sort their base names naturally (the lowest version first, the highest last) and remove the 'linux-' prefix
  local -r NEWEST_VERSION=( $( find /usr/src/ -maxdepth 1 -name 'linux-*' -type d -print0 | xargs --null --max-args=1 basename | sort --version-sort | sed -e 's/^linux-//' ) )

  echo "${NEWEST_VERSION[@]}"
}


# Returns the version string of the currently running kernel
#
# @return String  Version string (e.g. "4.4.39-gentoo")
function System::Kernel::get_current() {
  local -r  CURRENT_VERSION="$( uname -r )"

  echo "${CURRENT_VERSION}"
}


# Returns the path to the sources of KERNEL.
#
# @param String   KERNEL          Name of the kernel (e.g. 4.12.12-gentoo). If not specified, the path to the current sources is returned.
#
# @return String   Path to the sources (e.g. "/usr/src/linux-4.12.12-gentoo")
function System::Kernel::get_sources() {
  local -r KERNEL="${1:-}"; shift

  local src_dir="/usr/src/linux"
  [[ -n ${KERNEL} ]] && src_dir="${src_dir}-${KERNEL}"

  echo "${src_dir}"
}


# Mount a filesystem
#
# @param String   DEVICE          The device providing the mount. This can be whatever device is supporting by the mount
# @param String   DIR             The mount path for the mount
# @param String   FSTYPE          The mount type
# @param String   OPTIONS         A single string containing options for the mount, as they would appear in fstab
#
# @return Boolean  true if DEVICE was mounted successfully, otherwise false
function System::mount() {
  local -r DEVICE="${1:-}"; shift
  local -r DIR="${1:-}"; shift
  local -r FSTYPE="${1:+"-t $1"}"; shift
  local -r OPTIONS="${1:+"-o $1"}"; shift

  if [[ ! -d ${DIR} ]]; then
    { # try
      Log::Debug "mkdir ${DIR} && chmod 755 ${DIR}" &&
      mkdir ${DIR} &&
      chmod 755 ${DIR}
    } || { # catch
      return 1
    }
  fi

  { # try
    Log::Debug "mount ${FSTYPE} ${OPTIONS} ${DEVICE} ${DIR}" &&
    mount ${FSTYPE} ${OPTIONS} ${DEVICE} ${DIR}
  } || { # catch
    return 1
  }

  return 0
}


# Returns the OS id as written in '/etc/os-release'
#
# @return String  Value of the 'ID' attribute
function System::OS::ID() {
  echo "$( . /etc/os-release && echo ${ID} )"
}


# Returns the OS name as written in '/etc/os-release'
#
# @return String  Value of the 'NAME' attribute
function System::OS::NAME() {
  echo "$( . /etc/os-release && echo ${NAME} )"
}


# Returns the OS pretty name as written in '/etc/os-release'
#
# @return String  Value of the 'PRETTY_NAME' attribute
function System::OS::PRETTY_NAME() {
  echo "$( . /etc/os-release && echo ${PRETTY_NAME} )"
}


# Checks if PARTITION exists in the local system
#
# @param String   PARTITION       Device path of the partition (e.g. '/dev/sda1')
#
# @return Boolean  true if PARTITION exists, else false
function System::Partition::exists() {
  local -r PARTITION="${1:-}"

  # If the string is empty or does not follow the device notation, quit
  [[ -z ${PARTITION} ]] || [[ ! ${PARTITION} =~ ^\/dev\/(hd|sd)[[:lower:]][[:digit:]]$ ]] && return 1

  blkid ${PARTITION} &>/dev/null
}


# Ensures, that ENTRY is no longer part of the PATH environment variable
#
# @param String   ENTRY           The path to some application binaries
function System::Path::remove_entry() {
  local -r ENTRY="${1:-}"; shift

  export PATH=$(sed -E -e "s;:${ENTRY};;" -e "s;${ENTRY}:?;;" <<< "${PATH}")
}
