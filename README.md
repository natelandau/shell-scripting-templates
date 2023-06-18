## Bash Function Library (collection of utility functions)
Main / [Usage](#usage) / [Libraries](#libraries) / [Installation](installation.md) / [Description](docs/description.md) / [Coding](docs/coding-standards.md) / [Configuration](#configuration) / [Examples](#examples) / [Tests](#tests) / [Templates](#templates) / [Docs](#documentation) / [ToDo](#todo)

A collection of BASH utility functions and script templates used to ease the creation of portable and hardened BASH scripts with sane defaults.

### This project is copied from several bash functions projects with the similar approach
#### Source git repositories I have got ideas, templates, tests and examples:
| Author | weblink | Comment |
|:---:|---|:---:|
| **Joe Mooring** | [https://github.com/jmooring/bash-function-library](https://github.com/jmooring/bash-function-library) | (is **NOT** POSIX compliant) |
| **Michael Strache** | [https://github.com/Jarodiv/bash-function-libraries](https://github.com/Jarodiv/bash-function-libraries) |  |
| **Nathaniel Landau** | [https://github.com/natelandau/shell-scripting-templates](https://github.com/natelandau/shell-scripting-templates) |  |
| **Ariver** | [https://github.com/ariver/bash_functions](https://github.com/ariver/bash_functions) |  |
| **Haskell** | [https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh) |  |
| **Ralish** | [https://github.com/ralish/bash-script-template](https://github.com/ralish/bash-script-template) |  |

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
Is very important to handle errors. I have `trap` function declaration in my `.bashrc` **before**  $BASH\_FUNCTION_LIBRARY sourcing:<br />
```bash
set -o functrace
trap 'bfl::trap_cleanup "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]}" "$BASH_COMMAND" "$0" "${BASH_SOURCE[0]} "$*" "$HOME/.faults"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
```
Where `"$HOME/.faults"` is my log file.

Complex `sed` find/replace operations are supported with the files located in `sedfiles/`. Read [the usage instructions](sedfiles/README.md).

Basic alerting from [Natelandau](https://github.com/natelandau/shell-scripting-templates) and logging and setting colors from [JMooring](https://github.com/jmooring/bash-function-library) functions (included in `autoload.sh` by default). Print messages to stdout and to a user specified logfile using the following functions.

```bash
debug "some text"     # Printed only when in verbose (-v) mode
info "some text"      # Basic informational messages
notice "some text"    # Messages which should be read. Brighter than 'info'
warning "some text"   # Non-critical warnings
error "some text"     # Prints errors and the function stack but does not stop the script.
fatal "some text"     # Fatal errors. Exits the script
success "some text"   # Prints a success message
header "some text"    # Prints a header element
dryrun "some text"    # Prints commands that would be run if not in dry run (-n) mode
```

### Libraries

The libraries are located in diectories within `lib/` and contain BASH functions which can be used in your scripts.
Each included function includes detailed usage information. Read the inline comments within the code for detailed usage instructions.

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


The main script `autoload.sh` is roughly split into three sections:

- TOP: Description, options and global variables:

The following global variables must be set for the alert functions to work
- **`$DEBUG`** - If `true`, prints `debug` level alerts to stdout. (Default: `false`)
- **`$DRYRUN`** - If `true` does not eval commands passed to `_execute_` function. (Default: `false`)
- **`$LOGFILE`** - Path to a log file
- **`$LOGLEVEL`** - One of: FATAL, ERROR, WARN, INFO, DEBUG, ALL, OFF (Default: `ERROR`)
- **`$QUIET`** - If `true`, prints to log file but not stdout. (Default: `false`)

These default options are included in the templates and used throughout the utility functions. CLI flags to set/unset them are:
- **`-h, --help`**: Prints the contents of the `_usage_` function. Edit the text in that function to provide help
- **`--logfile [FILE]`** Full PATH to logfile. (Default is `${HOME}/logs/$(basename "$0").log`)
- **`loglevel [LEVEL]`**: Log level of the script. One of: `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `ALL`, `OFF` (Default is '`ERROR`')
- **`-n, --dryrun`**: Dryrun, sets `$DRYRUN` to `true` allowing you to write functions that will work non-destructively using the `_execute_` function
- **`-q, --quiet`**: Runs in quiet mode, suppressing all output to stdout. Will still write to log files
- **`-v, --verbose`**: Sets `$VERBOSE` to `true` and prints all debug messages to stdout
- **`--force`**: If using the `_seekConfirmation_` utility function, this skips all user interaction. Implied `Yes` to all confirmations.

- MIDDLE: function `_parseOptions_`. You can add custom script options and flags to the `_parseOptions_` function.
- BOTTOM: Script initialization `bfl::autoload` is at the bottom of the `autoload.sh`. Uncomment or change the settings before `bfl::autoload` for your needs.

  Write the main logic of your script within the `_mainScript_` function. It is placed at the bottom of the file for easy access and editing.
  It is invoked at the end of the script after options are parsed and functions are sourced.


### Examples

|                       Example                     |                                              Description                                              |
|:-------------------------------------------------:|-------------------------------------------------------------------------------------------------------|
| [examples/\_introduce.sh](examples/_introduce.sh) | This library function is simple and heavily&mdash; documented tutorial                                |
| [examples/session-info](examples/session-info)    | This script leverages the Bash Function Library, displaying a banner with user and system information |

### Tests

**Automated testing** is provided using [BATS](https://github.com/bats-core/bats-core). All tests are in the `test/` folder.
I doubt about testing system:
[Jarodiv](https://github.com/Jarodiv/bash-function-libraries) uses the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats) by [Sam Stephenson](https://github.com/sstephenson)
[JMooring](https://github.com/jmooring/bash-function-library) uses not so flexible as [BATS](https://github.com/sstephenson/bats), but is smart and tiny.

Every library has its own test suite that can be run separately:
```bash
bats test/*.bats
```
A git pre-commit hook provides automated testing is located in the `.hooks/` directory. Read about [how to install the hook](.hooks/README.md).


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

### A Note on Code Reuse and Prior Art

I compiled these scripting utilities over many years without having an intention to make them public. As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs. I often lift a function whole-cloth from a GitHub repo don't keep track of its original location. I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible. Unfortunately, I fear that I missed as many as I found. My goal in making this repository public is not to take credit for the code written by others. If you recognize something that I didn't credit, please let me know.

### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

### ToDo

* make function script for build help about all functions
* combine and [JMooring testing system](https://github.com/jmooring/bash-function-library/blob/master/test/test) and [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats)
