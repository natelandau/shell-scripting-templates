# Bash Function Library (collection of utility functions)
[Usage](#usage) \ [Libraries](#libraries) \ [Installation](docs/installation.md) \ [Description](docs/description.md) \ [Configuration](#configuration) \ [Examples](#examples) \ [Tests](#tests) \ [Templates](#templates) \ [Docs](#documentation)

### This project is copied from several bash functions projects with the similar approach
#### git repositories:
* [https://github.com/jmooring/bash-function-library](https://github.com/jmooring/bash-function-library) by **J.Mooring** (is **NOT** POSIX compliant)

* [https://github.com/Jarodiv/bash-function-libraries](https://github.com/Jarodiv/bash-function-libraries) by **Michael Strache** (Jarodiv) ; but **WITHOUT** using the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats) by [Sam Stephenson](https://github.com/sstephenson)

* [https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh) from haskell

### Usage:
* Like [jmooring](https://github.com/jmooring/bash-function-library), all libraries are located in `lib/*`.
* Like [jmooring](https://github.com/jmooring/bash-function-library), each function is namespaced with the `bfl::` prefix, but not multilevel as [Jarodiv](https://github.com/Jarodiv/bash-function-libraries). For example, to trim a string:

```bash
bfl::trim "${var}"
```

The calling script must source the entire library; some of the functions depend
on one or more of the others. Source the entire library by sourcing
autoload.sh. See the comments in autoload.sh for an explanation of the loading
process.

### Libraries
* Apache
* array - Some functions take or return arrays. Since Bash does not support to pass arrays, references and their serialized string representations are used.
* compile
* Debian
* ~declaration~
* directory
* file
* git
* log - Functions related to terminal and file logging
* mail
* number
* password
* ~procedures~ (for internal using)
* sms - Functions related to the Secure Shell
* ssh
* string - Functions related to Bash Strings
* system - Functions related to Linux Systems
* time
* url - Url conversation

#### libraries for specific usage:
* Lorem
* Maven - Functions related to the build tool Apache Maven
* Nexus - Functions related to the software repository manager Sonatype Nexus

## Configuration

* BASH_INTERACTIVE
* RC_NOCOLOR      If coloured, command tput also needs var $TERM
* BASH_FUNCTION_LIBRARY_COLOR_OUTPUT


## Examples

[examples/\_introduce.sh](examples/_introduce.sh)

> This library function is simple and heavily documented&mdash;a tutorial.

[examples/session-info](examples/session-info)

> This script leverages the Bash Function Library, displaying a banner with
user and system information.

## Tests

Test system is not so flexible as (BATS)](https://github.com/sstephenson/bats) but is smart and tiny.
Each library has its own test suite that can be run separately:

```
~$ bats test/*.bats~
```

## Templates

[templates/_library_function.sh](templates/_library_function.sh)

> Use this template to create a new library function.

[templates/script](templates/script)

> Use this template to create a script which leverages the Bash Function
Library.

## Documentation

[docs/function-list.md](docs/function-list.md)

> Summary of library functions.

[docs/error-handling.md](docs/error-handling.md)

> Notes on error handling.

[docs/coding-standards.md](docs/coding-standards.md)

> Coding standards.
