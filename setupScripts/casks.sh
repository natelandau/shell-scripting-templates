#!/usr/bin/env bash

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

# Set Variables
LISTINSTALLED="brew cask list"
INSTALLCOMMAND="brew cask install --appdir=/Applications"

RECIPES=(
    alfred
    arq
    authy-bluetooth
    bartender
    betterzipql
    capo
    carbon-copy-cloner
    cheatsheet
    codekit
    controlplane
    default-folder-x
    dropbox
    evernote
    fantastical
    firefox
    flux
    fluid
    github
    google-chrome
    hazel
    istat-menus
    iterm2
    imagealpha
    imageoptim
    java
    joinme
    kaleidoscope
    launchbar
    mamp
    marked
    mailplane
    moom
    nvalt
    omnifocus
    onepassword
    plex-home-theater
    qlcolorcode
    qlmarkdown
    qlprettypatch
    qlstephen
    quicklook-csv
    quicklook-json
    skitch
    suspicious-package
    textexpander
    tower
    vlc
    webp-quicklook
    xld
)

# Run Functions

hasHomebrew
hasCasks
brewMaintenance
doInstall

# Cleanup Homebrew
brew cask cleanup
