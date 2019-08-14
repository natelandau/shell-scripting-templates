# Bash Function Library

## Table of Contents

* [Overview](#overview)
* [Installation](#installation)
* [Examples](#examples)
* [Templates](#templates)
* [Documentation](#documentation)

<a id="overview"></a>

## Overview

This is a library of Bash functions that I've used over the years. These are
not, and were never intended to be, POSIX compliant. Each of the functions is
name-spaced with the "bfl::" prefix. For example, call bfl::trim to trim a
string.

The calling script must source the entire library as some of the functions
depend on one or more of the others. Source the entire library by sourcing
autoload.sh. See the comments in autoload.sh for an explanation of the loading process.

<a id="installation"></a>

## Installation

1\. Clone this repository into ~/.lib/bfl.

```bash
git clone https://github.com/jmooring/bash-function-library.git "${HOME}/.lib/bfl"
```

2\. Create a permanent environment variable containing the path to the autoloader.

```bash
heredoc=$(cat<<EOT
# Export path to the autoloader for the Bash Function Library.
# See https://github.com/jmooring/bash-function-library.
if [ -f "${HOME}/.lib/bfl/autoload.sh" ]; then
  export BASH_FUNCTION_LIBRARY="$HOME/.lib/bfl/autoload.sh"
fi
EOT
)
printf "\\n%s\\n" "${heredoc}" >> "${HOME}/.bashrc"
```

3\. Close all terminals.

4\. Open a new terminal.

5\. Verify that the BASH_FUNCTION_LIBRARY environment variable is correct.

```bash
printf "%s\\n" "${BASH_FUNCTION_LIBRARY}"
```

6\. Test using the [bfl::str_repeat](docs/documentation.md#bfl_str_repeat) function from the library.

```bash
if source "${BASH_FUNCTION_LIBRARY}"; then
  printf "%s\\n" "$(bfl::str_repeat "=" "40")"
else
  printf "Error: unable to source BASH_FUNCTION_LIBRARY.\\n"
fi
```

<a id="examples"></a>

## Examples

[examples/\_introduce.sh](examples/_introduce.sh)

> This library function is simple and heavily documented&mdash;a tutorial.

[examples/session-info](examples/session-info)

> This script leverages the Bash Function Library, displaying a banner with user and system information.

<a id="templates"></a>

## Templates

[templates/\_library_function.sh](templates/_library_function.sh)

> Use this template to create a new library function.

[templates/script](templates/script)

> Use this template to create a script which leverages the Bash Function Library.

<a id="documentation"></a>

## Documentation

[docs/function-list.md](docs/function-list.md)

> Summary of library functions.

[docs/error-handling.md](docs/error-handling.md)

> Notes on error handling.

[docs/style-guide.md](docs/style-guide.md)

> Style guide.
