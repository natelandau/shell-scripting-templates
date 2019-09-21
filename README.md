# Bash Function Library

## Table of Contents

* [Overview](#overview)
* [Installation](#installation)
* [Configuration](#configuration)
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

The calling script must source the entire library; some of the functions depend
on one or more of the others. Source the entire library by sourcing
autoload.sh. See the comments in autoload.sh for an explanation of the loading
process.

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

<a id="configuration"></a>

## Configuration

### Color Output

Library functions such as `bfl::die` and `bfl::warn` produce color output via
ANSI escape sequences. For example, `bfl::die` prints error messages in red,
while `bfl::warn` prints warning messages in yellow.

Instead of hardcoding ANSI escape sequences to produce color output, the
`bfl::declare_ansi_escape_sequences` library function defines global variables
for common color and formatting cases. This function is called when the Bash
Function Library is initially sourced.

The documentation contains a [complete
list](docs/function-list.md#bfl_declare_ansi_escape_sequences) of the defined
ANSI escape sequence variables.

Each of the following examples prints the word "foo" in yellow:

```bash
echo -e "${bfl_aes_yellow}foo${bfl_aes_reset}"
printf "${bfl_aes_yellow}%s${bfl_aes_reset}\\n" "foo"
printf "%b\\n" "${bfl_aes_yellow}foo${bfl_aes_reset}"
```

In some cases it may be desirable to disable color output. For example, let's
say you've written a script leveraging this library. When you run the script in
a terminal, you'd like to see the error messages in color. However, when run as
a cron job, you don't want to see the ANSI escape sequences surrounding error
messages when viewing logs or emails sent by cron.

To disable color output, set the BASH_FUNCTION_LIBRARY_COLOR_OUTPUT environment
variable to "disabled" before sourcing the autoloader. For example:

```bash
export BASH_FUNCTION_LIBRARY_COLOR_OUTPUT=disabled
if ! source "${BASH_FUNCTION_LIBRARY}"; then
  printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
  exit 1
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
