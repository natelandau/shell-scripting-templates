#!/usr/bin/env bash

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

# Set Variables
LISTINSTALLED="gem list | awk '{print $1}'"
INSTALLCOMMAND="gem install"
RUBYVERSION="2.1.2"


# Check for RVM
if [[ ! "$(type -P rvm)" ]]; then
  seek_confirmation_head "Install RVM?"
  if is_confirmed; then
    e_warning "Installing RVM (Ruby Version Manager) and Ruby  which becomes the default ..."
    curl -L https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
  fi
fi

#Install Ruby
if [[ "$(type -P rvm)" ]]; then
  #e_warning "Checking for newer Ruby Version"
  source $HOME/.bash_profile
  #rvm get stable --autolibs=enable
  rvm install $RUBYVERSION
  rvm use $RUBYVERSION --default
fi

RECIPES=(
    bundler
    classifier
    compass
    digest
    fileutils
    jekyll
    kramdown
    kss
    less
    logger
    mini_magick
    rake
    reduce
    s3_website
    sass
    smusher
)

# Run Functions

hasHomebrew
doInstall

#update gems
gem update --system
gem update
