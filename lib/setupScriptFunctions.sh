#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my mac setup scripts.
#
# VERSION 1.0.0
#
# HISTORY
#
# * 2015-01-02 - v1.0.0  - First Creation
#
# ##################################################


# hasHomebrew
# ------------------------------------------------------
# This function checks for Homebrew being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasHomebrew () {
  # Check for Homebrew
  #verbose "Checking homebrew install"
  if type_not_exists 'brew'; then
    warning "No Homebrew. Gots to install it..."
    seek_confirmation "Install Homebrew?"
    if is_confirmed; then
      #   Ensure that we can actually, like, compile anything.
      if [[ ! "$(type -P gcc)" && "$OSTYPE" =~ ^darwin ]]; then
        notice "XCode or the Command Line Tools for XCode must be installed first."
        seek_confirmation "Install Command Line Tools from here?"
        if is_confirmed; then
          xcode-select --install
        else
          die "Please come back after Command Line Tools are installed."
        fi
      fi
      # Check for Git
      if type_not_exists 'git'; then
        die "Git should be installed. It isn't."
      fi
      # Install Homebrew
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      brew tap homebrew/dupes
      brew tap homebrew/versions
    else
      die "Without Homebrew installed we won't get very far."
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
    brew upgrade --all
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
    brew tap caskroom/versions
  fi
}

# My preferred installation of FFMPEG
install-ffmpeg () {
  if [ ! $(type -P "ffmpeg") ]; then
    brew install ffmpeg --with-faac --with-fdk-aac --with-ffplay --with-fontconfig --with-freetype --with-libcaca --with-libass --with-frei0r --with-libass --with-libbluray --with-libcaca --with-libquvi --with-libvidstab --with-libsoxr --with-libssh --with-libvo-aacenc --with-libvidstab --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-openssl --with-opus --with-rtmpdump --with-schroedinger --with-speex --with-theora --with-tools --with-webp --with-x265
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
function to_install() {
  local debugger desired installed i desired_s installed_s remain
  if [[ "$1" == 1 ]]; then debugger=1; shift; fi
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
  [[ "$debugger" ]] && for v in desired desired_s installed installed_s remain; do
    echo "$v ($(eval echo "\${#$v[*]}")) $(eval echo "\${$v[*]}")"
  done
  echo "${remain[@]}"
}

# Install the desired items that are not already installed.
function doInstall () {
  list=$(to_install "${RECIPES[*]}" "$(${LISTINSTALLED})")
  if [[ "${list}" ]]; then
    seek_confirmation "Confirm each package before installing?"
    if is_confirmed; then
      for item in ${list[@]}
      do
        seek_confirmation "Install ${item}?"
        if is_confirmed; then
          notice "Installing ${item}"
          # FFMPEG takes additional flags
          if [[ "${item}" = "ffmpeg" ]]; then
            install-ffmpeg
          elif [[ "${item}" = "tldr" ]]; then
            brew tap tldr-pages/tldr
            brew install tldr
          else
            ${INSTALLCOMMAND} ${item}
          fi
        fi
      done
    else
      for item in ${list[@]}
      do
        notice "Installing ${item}"
        # FFMPEG takes additional flags
        if [[ "${item}" = "ffmpeg" ]]; then
          install-ffmpeg
        elif [[ "${item}" = "tldr" ]]; then
          brew tap tldr-pages/tldr
          brew install tldr
        else
          ${INSTALLCOMMAND} ${item}
        fi
      done
    fi
  else
    # only print notice when not checking dependencies via another script
    if [ -z "$homebrewDependencies" ] && [ -z "$caskDependencies" ] && [ -z "$gemDependencies" ]; then
      notice "Nothing to install.  You've already installed all your recipes."
    fi

  fi
}

# brewCleanup
# ------------------------------------------------------
# This function cleans up an initial Homebrew installation
# ------------------------------------------------------
brewCleanup () {
  # This is where brew stores its binary symlinks
  binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

  if [[ "$(type -P ${binroot}/bash)" && "$(cat /etc/shells | grep -q "$binroot/bash")" ]]; then
    info "Adding ${binroot}/bash to the list of acceptable shells"
    echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "${binroot}/bash" ]]; then
    info "Making ${binroot}/bash your default shell"
    sudo chsh -s "${binroot}/bash" "$USER" >/dev/null 2>&1
    success "Please exit and restart all your shells."
  fi

  brew cleanup

  if $(brew cask > /dev/null); then
    brew cask cleanup
  fi
}

# hasDropbox
# ------------------------------------------------------
# This function checks for Dropbox being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasDropbox () {
  # Confirm we have Dropbox installed
  notice "Confirming that Dropbox is installed..."
  if [ ! -e "/Applications/Dropbox.app" ]; then
    notice "We don't have Dropbox.  Let's get it installed."
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
      die "Can't run this script.  Install Dropbox manually."
    fi
  else
    success "Dropbox is installed."
  fi
}