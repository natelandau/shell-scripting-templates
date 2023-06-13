#!/usr/bin/env bats

# Unittests for the functions in System.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/System.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# System::Path::remove_entry                                                   #
# ---------------------------------------------------------------------------- #
