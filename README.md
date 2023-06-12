## Bash Function Library (collection of utility functions)
Main / [Usage](#usage) / [Libraries](#libraries) / [Installation](installation.md) / [Description](docs/description.md) / [Coding](docs/coding-standards.md) / [Configuration](#configuration) / [Examples](#examples) / [Tests](#tests) / [Templates](#templates) / [Docs](#documentation) / [ToDo](#todo)

### This project is copied from several bash functions projects with the similar approach
#### Source git repositories I have got ideas, templates, tests and examples:
|             Author            |                                               weblink                                                                                                              |            Comment           |
|:-----------------------------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------:|
| **J.Mooring**                 | [https://github.com/jmooring/bash-function-library](https://github.com/jmooring/bash-function-library)                                                             | (is **NOT** POSIX compliant) |
| **Michael Strache** (Jarodiv) | [https://github.com/Jarodiv/bash-function-libraries](https://github.com/Jarodiv/bash-function-libraries)                                                           |                              |
| **Ariver**                    | [https://github.com/ariver/bash_functions](https://github.com/ariver/bash_functions)                                                                               |                              |
| **Haskell**                   | [https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh) |                              |
| **Ralish**                    | [https://github.com/ralish/bash-script-template](https://github.com/ralish/bash-script-template)                                                                   |                              |
| **Natelandau**                | [https://github.com/natelandau/shell-scripting-templates](https://github.com/natelandau/shell-scripting-templates)                                                 |                              |

### Usage

In my system I put this library right in `/etc` directory because of integrating `Bash Functions Library` in all system scripts.<br />
Also there is a file `/etc/getConsts` with some global declarations of common used tools at the same place.<br />
File `/etc/getConsts` is also is loaded at system sterting from script in `/etc/profile.d/` - maybe I should locate it directly to `/etc/profile.d/`.<br />
Every script like `/etc/bash.bashrc`, `/etc/bashrc`, `~/.bashrc`, `~/.profile` and others at scripts' beginning loads `BFL library` and `/etc/getConsts` file together:
```bash
[[ $_GUARD_BFL_autoload -ne 1 ]] && . /etc/getConsts && . "$BASH_FUNCTION_LIBRARY" # plug in external script libarary
```
As a result, `getConsts` will be loaded no more than once.<br />
contents of my `/etc/getConsts` :
```bash
set -o allexport  # == set -a Enable using full option name syntax
# -------------------------------------------------------------------
declare -x BASH_INTERACTIVE=true    # Global shell variable
[[ "$TERM" == 'linux' ]] && unset TERM
[[ -z ${TERM+x} ]] && readonly TERM='xterm-256color'

...................... some directory declarations ......................
readonly BASH_FUNCTION_LIBRARY='/etc/bash_functions_library/autoload.sh'
.........................................................................
readonly myPython='python3.8'
readonly myPerl='5.30.0'
readonly localPythonModulesDir="/home/alexei/.local/lib/$myPython/site-packages"
.........................................................................
set +o allexport  # == set +a Disable using full option name syntax
```
Note: readonly is a "Special Builtin". If Bash is in POSIX mode then readonly (and not declare) has the effect "returning an error status will not cause the shell to exit". [https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash](https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash)

**Source in your scripts `autoload.sh`**, because most of the `BFL` functions depend on one or more of the others.


### Libraries

|    Library   |      Description     |     |    Library   |  Description   |
|    :---:     |         :---:        | :-: |     :---:    |      :---:     |
|    string    |     Bash Strings     |     |    backup    |  file logging  |
|     file     |                      |     |     mail     |                |
|   directory  |                      |     |     log      |                |
|     date     |                      |     |     ssh      |  Secure Shell  |
|    number    |         mail         |     |   password   |   UUID, etc    |
|      url     |   url conversation   |     |    system    |  Linux System  |
|     array    |   pass as strings    |     |   terminal   |      Bash      |
|   directory  |                      |     |      sms     |                |
| declaration  | colors, other consts |     |    compile   |   LFS scripts  |
|  procedures  | (for internal using) |     |              |                |

#### libraries for specific usage:

|    Debian    |      Git     |    Apache    |     Maven    |     Lorem    |           Nexus             |
|    :---:     |     :---:    |    :---:     |     :---:    |     :---:    |           :---:             |
|              |              |              | Apache Maven |              |       Sonatype Nexus        |
|              |              |              |  build tool  |              | software repository manager |

### Configuration

Global variables in scripts:
* BASH_INTERACTIVE ....................
* RC_NOCOLOR .......................... If coloured, command tput also needs var $TERM
* BASH_FUNCTION_LIBRARY_COLOR_OUTPUT ..
* QUEIT, VERBOSE ...................... ??? - I doubt

Temporary variables in scripts:
* SPIN_NUM ................ for '_terminal_spinner.sh'
* PROGRESS_BAR_PROGRESS ... for '_terminal_progressbar.sh'

### Examples

|                       Example                     |                                              Description                                              |
|:-------------------------------------------------:|-------------------------------------------------------------------------------------------------------|
| [examples/\_introduce.sh](examples/_introduce.sh) | This library function is simple and heavily&mdash; documented tutorial                                |
| [examples/session-info](examples/session-info)    | This script leverages the Bash Function Library, displaying a banner with user and system information |

### Tests

I doubt about testing system:
[Jarodiv](https://github.com/Jarodiv/bash-function-libraries) uses the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats) by [Sam Stephenson](https://github.com/sstephenson)
[JMooring](https://github.com/jmooring/bash-function-library) uses not so flexible as [BATS](https://github.com/sstephenson/bats), but is smart and tiny.

Every library has its own test suite that can be run separately:
```bash
bats test/*.bats
```

### Templates

|                         Library                        |                                          Description                                              |
|:------------------------------------------------------:|---------------------------------------------------------------------------------------------------|
| [_library_function.sh](templates/_library_function.sh) | Use to add some new function, in order to make coding simplier and folow unified coding standards |
| [script](templates/script)                             | Use to create a script which leverages the Bash Function Library                                  |


### Documentation

|                       Docs                      |                Description                |
|:-----------------------------------------------:|-------------------------------------------|
| [function-list.md](docs/function-list.md)       | Summary of library functions              |
| [error-handling.md](docs/error-handling.md)     | Notes on error handling                   |
| [coding-standards.md](docs/coding-standards.md) | Coding standards                          |
| [function-list.md](docs/function-list.md)       | not updated yet                           |

### ToDo

* make function script for build help about all functions
* combine and [JMooring testing system](https://github.com/jmooring/bash-function-library/blob/master/test/test) and [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats)
