#!/usr/bin/env bash

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

# Set Variables
LISTINSTALLED="brew list"
INSTALLCOMMAND="brew install"

install-ffmpeg () {
  seek_confirmation "Install ffmpeg?"
  if is_confirmed; then
    if type_not_exists 'ffmpeg'; then
      brew install ffmpeg --with-fdk-aac --with-ffplay --with-freetype --with-libcaca --with-libass --with-frei0r --with-libquvi --with-libvidstab --with-libvo-aacenc --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-openssl --with-opus --with-rtmpdump --with-schroedinger --with-speex --with-theora --with-tools --with-x265
    fi
  fi
}

RECIPES=(
  autoconf
  automake
  bash
  bash-completion
  colordiff
  coreutils
  git
  git-extras
  git-flow
  htop-osx
  hub
  hr
  id3tool
  imagemagick
  jpegoptim
  lesspipe
  libksba
  libtool
  libyaml
  mackup
  man2html
  multimarkdown
  openssl
  optipng
  pkg-config
  pngcrush
  readline
  shellcheck
  sl
  source-highlight
  ssh-copy-id
  sqlite
  tree
  unison
  z
)

# Run Functions

hasHomebrew
brewMaintenance
doInstall
install-ffmpeg
brewCleanup
