#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my mac setup scripts.
#
# HISTORY
# * 2015-01-02 - Initial creation
#
# ##################################################


# hasHomebrew
# ------------------------------------------------------
# This function checks for Homebrew being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasHomebrew () {
  # Check for Homebrew
  if type_not_exists 'brew'; then
    e_error "No Homebrew. Gots to install it."
    seek_confirmation "Install Homebrew?"
    if is_confirmed; then
      #   Ensure that we can actually, like, compile anything.
      if [[ ! "$(type -P gcc)" && "$OSTYPE" =~ ^darwin ]]; then
        e_error "XCode or the Command Line Tools for XCode must be installed first."
        seek_confirmation "Install Command Line Tools from here?"
        if is_confirmed; then
          xcode-select --install
        else
          e_error "Please come back after Command Line Tools are installed.  Exiting"
          exit 1
        fi
      fi
      # Check for Git
      if type_not_exists 'git'; then
        e_error "Git should be installed. It isn't. Aborting."
        exit 1
      fi
      # Install Homebrew
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      brew tap homebrew/dupes
      brew tap homebrew/versions
    else
      e_error "Without Homebrew installed we won't get very far."
      e_error "Exiting"
      exit 0
    fi
  fi
}

# brewMaintenance
# ------------------------------------------------------
# Will run the recommended Homebrew maintenance scripts
# ------------------------------------------------------
brewMaintenance () {
  seek_confirmation "Run Homebrew maintenance?"
  if is_confirmed; then
    brew doctor
    brew update
    brew upgrade
  fi
}

# hasCasks
# ------------------------------------------------------
# This function checks for Homebrew Casks and Fonts being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasCasks () {
  if ! $(brew cask > /dev/null); then
    brew install caskroom/cask/brew-cask
    brew tap caskroom/fonts
  fi
}


# doInstall
# ------------------------------------------------------
# Reads a list of items, checks if they are installed, installs
# those which are needed.
#
# Variables needed are:
# LISTINSTALLED:  The command to list all previously installed items
#                 Ex: "brew list" or "gem list | awk '{print $1}'"
#
# INSTALLCOMMAND: The Install command for the desired items.
#                 Ex:  "brew install" or "gem install"
#
# RECIPES:      The list of packages to install.
#               Ex: RECIPES=(
#                     package1
#                     package2
#                   )
#
# Credit: https://github.com/cowboy/dotfiles
# ------------------------------------------------------

# Given a list of desired items and installed items, return a list
# of uninstalled items.
# Credit: https://github.com/cowboy/dotfiles
function to_install() {
  local debug desired installed i desired_s installed_s remain
  if [[ "$1" == 1 ]]; then debug=1; shift; fi
    # Convert args to arrays, handling both space- and newline-separated lists.
    read -ra desired < <(echo "$1" | tr '\n' ' ')
    read -ra installed < <(echo "$2" | tr '\n' ' ')
    # Sort desired and installed arrays.
    unset i; while read -r; do desired_s[i++]=$REPLY; done < <(
      printf "%s\n" "${desired[@]}" | sort
    )
    unset i; while read -r; do installed_s[i++]=$REPLY; done < <(
      printf "%s\n" "${installed[@]}" | sort
    )
    # Get the difference. comm is awesome.
    unset i; while read -r; do remain[i++]=$REPLY; done < <(
      comm -13 <(printf "%s\n" "${installed_s[@]}") <(printf "%s\n" "${desired_s[@]}")
  )
  [[ "$debug" ]] && for v in desired desired_s installed installed_s remain; do
    echo "$v ($(eval echo "\${#$v[*]}")) $(eval echo "\${$v[*]}")"
  done
  echo "${remain[@]}"
}

# Install the desired items that are not already installed.
function doInstall () {
  list="$(to_install "${RECIPES[*]}" "$($LISTINSTALLED)")"
  if [[ "$list" ]]; then
    seek_confirmation "Confirm each install before running?"
    if is_confirmed; then
      for item in ${list[@]}
      do
        seek_confirmation "Install $item?"
        if is_confirmed; then
          $INSTALLCOMMAND $item
        fi
      done
    else
      for item in ${list[@]}
      do
        $INSTALLCOMMAND $item
      done
    fi
  else
    e_success "Nothing to install. You've already got them all."
  fi
}

# brewCleanup
# ------------------------------------------------------
# This function cleans up an initial Homebrew installation
# ------------------------------------------------------
brewCleanup () {
  # This is where brew stores its binary symlinks
  binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

  # htop
  if [[ "$(type -P $binroot/htop)" && "$(stat -L -f "%Su:%Sg" "$binroot/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "$binroot/htop") & 4))" ]]; then
    e_header "Updating htop permissions"
    sudo chown root:wheel "$binroot/htop"
    sudo chmod u+s "$binroot/htop"
  fi
  if [[ "$(type -P $binroot/bash)" && "$(cat /etc/shells | grep -q "$binroot/bash")" ]]; then
    e_header "Adding $binroot/bash to the list of acceptable shells"
    echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "$binroot/bash" ]]; then
    e_header "Making $binroot/bash your default shell"
    sudo chsh -s "$binroot/bash" "$USER" >/dev/null 2>&1
    e_success "Please exit and restart all your shells."
  fi
  brew cleanup
}

# hasDropbox
# ------------------------------------------------------
# This function checks for Dropbox being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasDropbox () {
  # Confirm we have Dropbox installed
  e_arrow "Confirming that Dropbox is installed..."
  if [ ! -e /Applications/Dropbox.app ]; then
    e_error "We don't have Dropbox.  Let's get it installed."
    seek_confirmation "Install Dropbox and all necessary prerequisites?"
    if is_confirmed; then
      # Run functions
      hasHomebrew
      brewMaintenance
      hasCasks

      # Set Variables
      local LISTINSTALLED="brew cask list"
      local INSTALLCOMMAND="brew cask install --appdir=/Applications"

      local RECIPES=(dropbox)
      Install
      open -a dropbox
    else
      e_error "Can't run this script.  Install Dropbox manually.  Exiting."
      exit 0
    fi
  else
    e_success "Dropbox is installed."
  fi
}