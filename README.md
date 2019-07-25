# Bash Function Library

## Table of Contents

* [Overview](#overview)
* [Installation](#installation)
* [Example](#example)
* [Documentation](#documentation)
* [Template](#template)

<a id="overview"></a>

## Overview

This is a library of Bash functions that I've used over the years. These are
not, and were never intended to be, POSIX compliant. Each of the functions is
name-spaced with the "lib::" prefix. For example, call lib::trim to trim a
string.

The calling script must source the entire library as some of the functions
depend on one or more of the others. Source the entire library by sourcing
autoload.sh. See the comments in autoload.sh for an explanation of the loading process.

<a id="installation"></a>

## Installation

1\. Clone this repository into ~/.lib.

```bash
git clone https://github.com/jmooring/bash-function-library.git "${HOME}/.lib"
```

2\. Create a permanent environment variable containing the path to the autoloader.

```bash
heredoc=$(cat<<EOT
# Export path to the autoloader for the Bash Function Library.
# See https://github.com/jmooring/bash-function-library.
if [ -f "${HOME}/.lib/autoload.sh" ]; then
  export BASH_FUNCTION_LIBRARY="$HOME/.lib/autoload.sh"
fi
EOT
)
printf "\\n%s\\n" "${heredoc}" >> "${HOME}/.bashrc"
```

3\. Close all terminals.

4\. Open a new terminal.

5\. Verify that the BASH_FUNCTION_LIBRARY environment variable is set to the
correct path.

```bash
printf "%s\\n" "${BASH_FUNCTION_LIBRARY}"
```

6\. Test using the [lib::str_repeat](docs/documentation.md#lib_str_repeat) function from the library.

```bash
if ! source "${BASH_FUNCTION_LIBRARY}"; then
  printf "Error: unable to source BASH_FUNCTION_LIBRARY.\\n"
  exit 1
fi


printf "%s\\n" "$(lib::str_repeat "=" "10")"
```

<a id="example"></a>

## Example

This Bash script calls three functions from the Bash Function Library:

* lib::declare_global_display_constants ([documentation](docs/documentation.md#lib_declare_global_display_constants))
  ([code](_declare_global_display_constants.sh))
* lib::validate_arg_count ([documentation](docs/documentation.md#lib_validate_arg_count)) ([code](_validate_arg_count.sh))
* lib::str_repeat ([documentation](docs/documentation.md#lib_str_repeat)) ([code](_str_repeat.sh))

```bash
#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Repeats a string N times.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Displays usage message.
#------------------------------------------------------------------------------
usage() {
  declare this_script
  this_script=$(basename "$0")
  echo
  echo "Repeats a string N times."
  echo
  echo "Usage:    ${this_script} string multiplier"
  echo "Example:  ${this_script} \"=\" \"10\""
  echo
  exit 1
}

#------------------------------------------------------------------------------
# @function
# Main function.
#
# shellcheck disable=1090
#------------------------------------------------------------------------------
main() {
  if ! source "${BASH_FUNCTION_LIBRARY}"; then
    printf "Error: unable to source BASH_FUNCTION_LIBRARY.\\n"
    exit 1
  fi

  lib::declare_global_display_constants
  lib::validate_arg_count "$#" 2 2 || usage

  declare -r string_to_repeat="$1"
  declare -r multiplier="$2"
  declare repeated_string

  repeated_string=$(lib::str_repeat "${string_to_repeat}" "${multiplier}")
  printf "%s\\n" "${repeated_string}"
}

set -euo pipefail
main "$@"
```

<a id="documentation"></a>

## Documentation

See [docs/documentation.md](docs/documentation.md).

## Template

See [examples/template](examples/template).
