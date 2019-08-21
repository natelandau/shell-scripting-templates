# Bash Function Library

## Table of Contents

* [Overview](#overview)
* [Installation](#installation)
* [Examples](#examples)
* [Templates](#templates)
* [Documentation](#documentation)

<a id="overview"></a>

## Overview

The Bash Function Library is a collection of utility functions. The library is
not, and was never intended to be, POSIX compliant. Each function is
namespaced with the `bfl::` prefix. For example, to trim a string:

```bash
bfl::trim "${var}"
```

The calling script must source the entire library; some of the functions depend on one or more of the others. Source the entire library by sourcing autoload.sh. See the comments in autoload.sh for an explanation of the loading process.

<a id="installation"></a>

## Installation

1\. Clone this repository into `${HOME}/.lib/bfl`.

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

3\. Verify that the BASH_FUNCTION_LIBRARY environment variable is correct.

```bash
source "${HOME}/.bashrc"
printf "%s\\n" "${BASH_FUNCTION_LIBRARY}"
```

4\. Test using the `bfl::repeat` library function.

```bash
if source "${BASH_FUNCTION_LIBRARY}"; then
  printf "%s\\n" "$(bfl::repeat "=" "40")"
else
  printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
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

[templates/_library_function.sh](templates/_library_function.sh)

> Use this template to create a new library function.

[templates/script](templates/script)

> Use this template to create a script which leverages the Bash Function Library.

<a id="documentation"></a>

## Documentation

[docs/function-list.md](docs/function-list.md)

> Summary of library functions.

[docs/error-handling.md](docs/error-handling.md)

> Notes on error handling.

[docs/coding-standards.md](docs/coding-standards.md)

> Coding standards.
