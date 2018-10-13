#!/usr/bin/env bash

# Library of functions related to Linux Systems
#
# @author  Michael Strache


# Prevent this library from being sourced more than once
[[ ${_GUARD_BFL_SYSTEM:-} -eq 1 ]] && return 0 || declare -r _GUARD_BFL_SYSTEM=1


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #

declare BFL_LIB_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $BFL_LIB_PATH/String.sh
source $BFL_LIB_PATH/Log.sh


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# Checks if the system supports the EFI bootloader
#
# @return Boolean  true if the system supports boots via EFI, else false
function System::Efi::detect() {
  # '/sys/firmware/efi' is only available on systems that are booted using EFI
  # 'efibootmgr' is required when working with EFI, so its not wrong to test for it too
  [[ -d /sys/firmware/efi ]] && efibootmgr &>/dev/null
}


# Returns a string with the efibootmgr entry for the boot order (if it exists)
# Note: This function requires the tool "efibootmgr" which may has to be installed manually
#
# @return String  Comma separated list
function System::Efi::get_bootorder() {
  local _bootorder

  # Utilizing Process Substitution (http://tldp.org/LDP/abs/html/process-sub.html) to make the command output parsable
  while read -r line ; do
    if [[ "${line}" == BootOrder:* ]]; then
      _bootorder="${line#* }"
      break
    fi
  done < <(efibootmgr)
  [[ -z "${_bootorder}" ]] && return 1

  echo "${_bootorder}"
}


# Returns an associative array (string representation) with the efibootmgr entry for FILE if it exists
#
# @param String   IDENTIFIER      BootNum or Path of an '.efi' file like it is used in the efibootmgr entries (e.g. '\EFI\gentoo\vmlinuz-4.4.6-gentoo.efi')
#
# @return String  String representation of an associative array (e.g. '( [bootnum]="0001" [label]="Gentoo Linux 4.4.6" [loader]="\EFI\GENTOO\VMLINUZ-4.4.6-GENTOO.EFI" )')
function System::Efi::get_entry() {
  local -r IDENTIFIER="${1:-}"; shift
  local entry_identifier

  if String::is_hex_number "${IDENTIFIER}"; then
    if (( ${#IDENTIFIER} > 4 )); then
      Log::Error "Invalid value for 'BOOTNUM', must be hexadecimal but was '${IDENTIFIER}'"
      return 1
    fi
    entry_identifier="boot${IDENTIFIER}"
  else
    entry_identifier="file($( String::to_lowercase "$( String::replace ${IDENTIFIER} '/' '\' )" ))"
  fi

  # Utilizing Process Substitution (http://tldp.org/LDP/abs/html/process-sub.html) to make the command output parsable
  local -A efi_entry
  while read -r line ; do
    # If we have a boot entry that contains our search string, we have the right one
    if [[ "${line}" =~ ^Boot[[:digit:]]{4}.*$ ]] && String::contains "$( String::to_lowercase "${line}" )" "${entry_identifier}"; then
      # Use a regular expression to extract the boot entry attributes
      if [[ "${line}" =~ ^Boot([[:digit:]]{4})\*?[[:space:]]+(.+)[[:space:]]+HD\(.+\)/File\((.*)\).*$ ]]; then
        efi_entry=( [bootnum]="${BASH_REMATCH[1]}" [label]="${BASH_REMATCH[2]}" [loader]="${BASH_REMATCH[3]}" )
      fi
      break
    fi
  done < <(efibootmgr -v)
  [[ -z "${efi_entry[bootnum]}" ]] || [[ -z "${efi_entry[label]}" ]] || [[ -z "${efi_entry[loader]}" ]] && return 1

  # Serialize the array that contains the boot entry ('declare -p' prints out the array constructor, which then is stripped down to the array string)
  local -r EFI_ENTRY_SERIALIZED=$( declare -p efi_entry )
  printf "${EFI_ENTRY_SERIALIZED#*=}"
}


# Returns of all EFI bootloader entries matching the OS_ID the one with the lowest boot priority, as long as there will be KEEP others left
#
# @param String   OS_ID           Identifier that limits the search
# @param Integer  KEEP            Number of entries that should be kept (Default: 2)
#
# @return String  String representation of an associative array (e.g. '( [bootnum]="0001" [label]="Gentoo Linux 4.4.6" [loader]="\EFI\GENTOO\VMLINUZ-4.4.6-GENTOO.EFI" )')
function System::Efi::get_least_entry() {
  local -r OS_ID=$( String::to_lowercase "${1:-}" ); shift
  local -r KEEP="${1:-2}"; shift

  [[ -z ${OS_ID} ]] && {
    Log::Error "Invalid argument, 'OS_ID' must be specified"
    return 1
  }

  ! String::is_integer ${KEEP} && {
    Log::Error "Invalid argument, 'KEEP' must be an integer"
    return 1
  }

  # Alternative implementation: Iterate Boot Order and select the first entry that matches the filter ("\EFI\<OS_ID>\*.EFI")
  local result
  local counter=0

  local -a bootorder=$( String::split "$( System::Efi::get_bootorder )" "," )
  for (( i=${#bootorder[@]}-1 ; i>=0 ; i-- )) ; do
    local efi_entry="$( System::Efi::get_entry "${bootorder[$i]}" )"

    local -A efi_entry_array=${efi_entry}
    local loader=$( String::to_lowercase "${efi_entry_array[loader]}" )
    if [[ ${loader} =~ ^\\efi\\${OS_ID}\\[[:print:]]+\.efi$ ]]; then
      [[ -z ${result} ]] && {
        result="${efi_entry}"
      }
      (( counter++ ))
    fi

    (( counter > KEEP )) && {
      echo "${result}"
      break
    }
  done

  return 0
}


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
  local -r AVAILABLE_VERSIONS=( $( find /usr/src/ -maxdepth 1 -name 'linux-*' -type d -print0 | xargs --null --max-args=1 basename | sort --version-sort | sed -e 's/^linux-//' ) )

  # Serialize the array ('declare -p' prints out the array constructor, which then is stripped down to the array string)
  local -r AVAILABLE_VERSIONS_SERIALIZED=$( declare -p AVAILABLE_VERSIONS )
  printf "${AVAILABLE_VERSIONS_SERIALIZED#*=}"
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
