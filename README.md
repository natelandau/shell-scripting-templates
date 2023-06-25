Main / [Usage](#usage) / [Libraries](#libraries) / [Installation](installation.md) / [Description](docs/description.md) / [Coding](docs/coding-standards.md) / [Configuration](#configuration) / [Examples](#examples) / [Tests](#tests) / [Templates](#templates) / [Docs](#documentation) / [ToDo](#todo)

## Bash Function Library (collection of utility functions)

A collection of BASH utility functions and script templates used to ease the creation of portable and hardened BASH scripts with sane defaults.<br />
I load these up in my own shell environment.<br />
If they're useful for anyone else, then great! :)

#### This project is copied from several bash functions projects with the similar approach.
#### Sourced git repositories I have got ideas, templates, tests and examples to current project:
| Author | weblink | comment |
|:---:|---|:---:|
| **Joe Mooring** | [https://github.com/jmooring/bash-function-library](https://github.com/jmooring/bash-function-library) | (is **not** POSIX compliant) |
| **Michael Strache** | [https://github.com/Jarodiv/bash-function-libraries](https://github.com/Jarodiv/bash-function-libraries) |  |
| **Nathaniel Landau** | [https://github.com/natelandau/shell-scripting-templates](https://github.com/natelandau/shell-scripting-templates) |  |
| **Ariver** | [https://github.com/ariver/bash_functions](https://github.com/ariver/bash_functions) |  |
| **Haskell** | [https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh) |  |
| **Ralish** | [https://github.com/ralish/bash-script-template](https://github.com/ralish/bash-script-template) |  |

### Usage

In short:<br />
1) clone repository: `git clone git@github.com:AlexeiKharchev/bash_functions_library "$YOUR_PATH"`<br />
2) create script to define repository locaton (in order ro source from any script):<br />
**Contents of my `${HOME}/getConsts` :**
```bash
set -o allexport  # == set -a Enable using full option name syntax
...................... some directory declarations ......................
readonly BASH_FUNCTION_LIBRARY='/etc/bash_functions_library/autoload.sh'
.........................................................................
readonly myPython='python3.8'
readonly myPerl='5.30.0'
readonly localPythonModulesDir="/home/alexei/.local/lib/$myPython/site-packages"
.........................................................................
set +o allexport  # == set +a Disable using full option name syntax
```
3) source ${HOME}/getConsts in /etc/profile (or some autoload script in /etc/profile.d)<br />
```bash
source ${HOME}/getConsts
```
4) run terminal and type `bfl::string_of_char 'A' 50`<br />
Your should see `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA` in terminal
5) use `Bash Functions Library` in ypur scripts like this:
```bash
# plug in external library
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY" ; }
echo "${DarkGreen}Loading /etc/profile${NC}"
```
As a result, `getConsts` will be loaded no more than once.<br />
In order to handle errors there is declaration `trap 'bfl::trap_cleanup ...` in `autoload.sh`,<br />
so you need not to additionally declare `trap`.<br />
Log file declared in `autoload.sh`:    `readonly BASH_FUNCTION_LOG="$HOME/.faults"`

### Templates

Use [_library_function.sh](templates/_library_function.sh) for writing new functions.

|                         Library                        |                                          Description                                              |
|:------------------------------------------------------:|---------------------------------------------------------------------------------------------------|
| [_library_function.sh](templates/_library_function.sh) | Use to add some new function, in order to make coding simplier and folow unified coding standards |
| [script](templates/script)                             | Use to create a script which leverages the Bash Function Library                                  |

### Additionally

More detailed section **Usage** you can see [here](docs/detailed-usage.md).
Complex `sed` find/replace operations are supported with the files located in `sedfiles/`. Read [the usage instructions](sedfiles/README.md).

Basic alerting from [Natelandau](https://github.com/natelandau/shell-scripting-templates) and logging and setting colors from [JMooring](https://github.com/jmooring/bash-function-library) functions (included in `autoload.sh` by default). Print messages to stdout and to a user specified logfile using the following functions.

```bash
warning "some text"   # Non-critical warnings
error "some text"     # Prints errors and the function stack but does not stop the script.
debug "some text"     # Printed only when in verbose (-v) mode
   ... etc ...
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

| Debian | Git | Apache | Maven | Lorem | Nexus |
|:---:|:---:|:---:|:---:|:---:|:---:|
|  |  |  | Apache Maven build tool |  | Sonatype Nexus software repository manager |

### Configuration

The following **global variables** must be set for the alert functions to work:
| var | description | default |
|:---:|---|:---:|
| **`$BASH_INTERACTIVE`** | If `false`, prints to log file but not stdout | `true` |
| **`$DEBUG`** | If `true`, prints `debug` level alerts to stdout | `false` |
| **`$VERBOSE`** | If `true` prints all debug messages to stdout | `false` |
| **`$DRYRUN`** | If `true` does not eval commands passed to `_execute_` function | `false` |
| **`$RC_NOCOLOR`** | Disable coloured output. If `false`, command `tput` also needs var `$TERM` | `false` |
| ??? | **`$BASH_FUNCTION_LIBRARY_COLOR_OUTPUT`** |  |
| **`$LOGFILE`** | Path to a log file | `"$HOME/.faults"` |
| **`$LOGLEVEL`** | One of: `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `ALL`, `OFF` | `ERROR` |

Temporary variables in scripts:
| var | description |
|:---:|---|
| **`$SPIN_NUM`** | Used in `_terminal_spinner.sh` |
| **`$PROGRESS_BAR_PROGRESS`** | Used in `_terminal_progressbar.sh` |

### The main script `autoload.sh` is roughly split into three sections:
#### I. TOP: Description, options and global variables:
These default options are included in the templates and used throughout the utility functions. CLI flags to set/unset them are:
- **`-h, --h, --help`**: Prints the contents of the `_usage_` function. Edit the text in that function to provide help
- **`--logfile [FILE]`** Full PATH to logfile. (Default is `${HOME}/logs/$(basename "$0").log`)
- **`loglevel [LEVEL]`**: Log level of the script. One of: `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `ALL`, `OFF` (Default is '`ERROR`')
- **`-n, --dryrun`**: Dryrun, sets `$DRYRUN` to `true` allowing you to write functions that will work non-destructively using the `_execute_` function
- **`-q, --q, --quiet`**: Runs in quiet mode, suppressing all output to stdout. Will still write to log files
- **`-v, --verbose`**: Sets `$VERBOSE` to `true` and prints all debug messages to stdout
- **`--force`**: If using the `bfl::wait_confirmation` utility function, this skips all user interaction. Implied `Yes` to all confirmations.
#### II. MIDDLE:
- **function `bfl::parseOptions`** You can add custom script options and flags to this function.
#### III. BOTTOM:
- **Script initialization** `bfl::autoload` is at the bottom of the `autoload.sh`. Uncomment or change the settings before `bfl::autoload` for your needs.
Write the main logic of your script within the `_mainScript_` function. It is placed at the bottom of the file for easy access and editing.It is invoked at the end of the script after options are parsed and functions are sourced.

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


### Documentation

|                       Docs                      |                Description                |
|:-----------------------------------------------:|-------------------------------------------|
| [coding-standards.md](docs/coding-standards.md) | Coding standards                          |
| [function-list.md](docs/function-list.md)       | Summary of library functions              |
| [error-handling.md](docs/error-handling.md)     | Notes on error handling                   |
| [functions-list.md](docs/functions-list.md)     | Is not updated yet                        |

### A Note on Code Reuse and Prior Art from [Nathaniel Landau](https://github.com/natelandau/shell-scripting-templates):

I compiled these scripting utilities over many years without having an intention to make them public.
As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs.
I often lift a function whole-cloth from a GitHub repo don't keep track of its original location.
I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible.
Unfortunately, I fear that I missed as many as I found.
My goal in making this repository public is not to take credit for the code written by others.
If you recognize something that I didn't credit, please let me know.

### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

### ToDo

* make function script for build help about all functions
* combine and [JMooring testing system](https://github.com/jmooring/bash-function-library/blob/master/test/test) and [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats)
