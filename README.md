# Bash Function Library (collection of utility functions)
[Usage](#usage) / [Libraries](#libraries) / [Installation](docs/installation.md) / [Description](docs/description.md) / [Configuration](#configuration) / [Examples](#examples) / [Tests](#tests) / [Templates](#templates) / [Docs](#documentation)

### This project is copied from several bash functions projects with the similar approach
#### git repositories:
* [https://github.com/jmooring/bash-function-library](https://github.com/jmooring/bash-function-library) by **J.Mooring** (is **NOT** POSIX compliant)

* [https://github.com/Jarodiv/bash-function-libraries](https://github.com/Jarodiv/bash-function-libraries) by **Michael Strache** (Jarodiv) ; but **WITHOUT** using the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats) by [Sam Stephenson](https://github.com/sstephenson)

* [https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh) from haskell

* [https://github.com/ralish/bash-script-template](https://github.com/ralish/bash-script-template)

* [https://github.com/natelandau/shell-scripting-templates](https://github.com/natelandau/shell-scripting-templates)

Usage
-----

* Like [Jarodiv](https://github.com/Jarodiv/bash-function-libraries), all libraries are located in `lib/`, every function located in `lib/library/`. [Natelandau](https://github.com/natelandau/shell-scripting-templates) also keeps scripts in separate directory (utilities).
- Like [JMooring](https://github.com/jmooring/bash-function-library), script names use camel case with a starting underscores: `_name_of_script.sh`.
Each included function includes detailed usage information. Read the inline comments within the code for detailed usage instructions.
Within the `lib` folder are many BASH functions meant to ease development of more complicated scripts.

* Like [JMooring](https://github.com/jmooring/bash-function-library), each function is namespaced with the `bfl::` prefix, but not multileveled as [Jarodiv](https://github.com/Jarodiv/bash-function-libraries). For example, to trim a string:

```bash
bfl::trim "${var}"
```

The calling script must source the entire library; some of the functions depend on one or more of the others.
Source the entire library by sourcing autoload.sh. See the comments in autoload.sh for an explanation of the loading process.

Coding conventions
------------------

- Variables are always surrounded by quotes `"$1"`. Brackets used, but not always `"${1}"` (Overly verbose true, but a safe practice)
- Formatting: 2 spaces for first indent and 4 spaces for next indents (is provided by [shfmt](https://github.com/mvdan/sh))
- All scripts and functions are fully [Shellcheck](https://github.com/koalaman/shellcheck) compliant
- Where possible, we should follow [defensive BASH programming](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/) principles.

Libraries
---------

* Apache
* Array - Some functions take or return arrays. Since Bash does not support to pass arrays, references and their serialized string representations are used.
* Compile
* Date
* Debian
* ~declaration~
* Directory
* File
* Git
* Log - Functions related to terminal and file logging
* Mail
* Number
* Password
* ~procedures~ (for internal using)
* Sms - Functions related to the Secure Shell
* Ssh
* String - Functions related to Bash Strings
* System - Functions related to Linux Systems
* Terminal
* Time
* Url - Url conversation

#### libraries for specific usage:
* Lorem
* Maven - Functions related to the build tool Apache Maven
* Nexus - Functions related to the software repository manager Sonatype Nexus

Configuration
-------------

* BASH_INTERACTIVE
* RC_NOCOLOR      If coloured, command tput also needs var $TERM
* BASH_FUNCTION_LIBRARY_COLOR_OUTPUT


Examples
--------

[examples/\_introduce.sh](examples/_introduce.sh)

> This library function is simple and heavily documented&mdash;a tutorial.

[examples/session-info](examples/session-info)

> This script leverages the Bash Function Library, displaying a banner with
user and system information.

Tests
-----

Test system is not so flexible as (BATS)](https://github.com/sstephenson/bats) but is smart and tiny.
Each library has its own test suite that can be run separately:

```
~$ bats test/*.bats~
```

Templates
---------

[templates/_library_function.sh](templates/_library_function.sh)

> Use this template to create a new library function.

[templates/script](templates/script)

> Use this template to create a script which leverages the Bash Function
Library.

Documentation
-------------

[docs/function-list.md](docs/function-list.md)

> Summary of library functions.

[docs/error-handling.md](docs/error-handling.md)

> Notes on error handling.

[docs/coding-standards.md](docs/coding-standards.md)

> Coding standards.
