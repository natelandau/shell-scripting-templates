#!/usr/bin/env bats

# Unittests for the functions in Util.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/Util.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# Util::compare_versions                                                       #
# ---------------------------------------------------------------------------- #

@test "Util::compare_versions -> Should return 0 if VERSION1 is lower than VERSION2." {
  # Simple version numbers
  run Util::compare_versions "1.0" "2.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.9" "2.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0" "1.9"
  [ "$status" -eq 0 ]

  # Version numbers with two digits
  run Util::compare_versions "1.0" "1.10"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.10" "2.0"
  [ "$status" -eq 0 ]

  # One version number with bugfix version
  run Util::compare_versions "1.0" "2.0.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0" "1.10.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0" "1.0.10"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0.0" "2.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.10.0" "2.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0.10" "2.0"
  [ "$status" -eq 0 ]

  # Both version numbers with bugfix version
  run Util::compare_versions "1.0.0" "2.0.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.10.0" "2.0.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0.10" "2.0.0"
  [ "$status" -eq 0 ]
  run Util::compare_versions "1.0.10" "1.10.0"
  [ "$status" -eq 0 ]
}

@test "Util::compare_versions -> Should return 1 if VERSION1 is equal to VERSION2." {
  # Simple version numbers
  run Util::compare_versions "1.0" "1.0"
  [ "$status" -eq 1 ]

  # Both version numbers with bugfix version
  run Util::compare_versions "1.0.0" "1.0.0"
  [ "$status" -eq 1 ]
}

@test "Util::compare_versions -> Should return 2 If VERSION1 is higher than VERSION2." {
  # Simple version numbers
  run Util::compare_versions "2.0" "1.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0" "1.9"
  [ "$status" -eq 2 ]
  run Util::compare_versions "1.9" "1.0"
  [ "$status" -eq 2 ]

  # Version numbers with two digits
  run Util::compare_versions "1.10" "1.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0" "1.10"
  [ "$status" -eq 2 ]

  # One version number with bugfix version
  run Util::compare_versions "2.0.0" "1.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "1.10.0" "1.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "1.0.10" "1.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0" "1.0.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0" "1.10.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0" "1.0.10"
  [ "$status" -eq 2 ]

  # Both version numbers with bugfix version
  run Util::compare_versions "2.0.0" "1.0.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0.0" "1.10.0"
  [ "$status" -eq 2 ]
  run Util::compare_versions "2.0.0" "1.0.10"
  [ "$status" -eq 2 ]
  run Util::compare_versions "1.10.0" "1.0.10"
  [ "$status" -eq 2 ]
}


