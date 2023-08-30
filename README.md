# Shell Scripting Templates and Utilities

A collection of BASH utility functions and script templates used to ease the creation of portable and hardened BASH scripts with sane defaults.

## Usage

There are **two Script Templates** located in the root level of this repository. The usage of these templates is described in detail below.

BASH **Utility functions** are located within the `utilities/` folder.

Complex `sed` find/replace operations are supported with the files located in `sedfiles/`. Read [the usage instructions](sedfiles/README.md).

**Automated testing** is provided using [BATS](https://github.com/bats-core/bats-core). All tests are in the `tests/` repo. A git pre-commit hook provides automated testing is located in the `.hooks/` directory. Read about [how to install the hook](.hooks/README.md).

## Bash Script Templates Usage

To create a new script, copy one of the script templates to a new file and make it executable `chmod 755 [newscript].sh`. Place your custom script logic within the `_mainScript_` function at the top of the script.

### Script Templates

There are two templates located at the root level of this repository.

-   **`template.sh`** - A lean template which attempts to source all the utility functions from this repository. You will need to update the path to the utilities folder sent to `_sourceUtilities_` at the bottom of the script. This template will not function correctly if the utilities are not found.
-   **`template_standalone.sh`** - For portability, the standalone template does not assume that this repository is available. Copy and paste the individual utility functions under the `### Custom utility functions` line.

### Code Organization

The script templates are roughly split into three sections:

-   TOP: Write the main logic of your script within the `_mainScript_` function. It is placed at the top of the file for easy access and editing. However, it is invoked at the end of the script after options are parsed and functions are sourced.
-   MIDDLE: Functions and default variable settings are located just below `_mainScript_`.
-   BOTTOM: Script initialization (BASH options, traps, call to `_mainScript_`, etc.) is at the bottom of the template

### Default Options

These default options and global variables are included in the templates and used throughout the utility functions. CLI flags to set/unset them are:

-   **`-h, --help`**: Prints the contents of the `_usage_` function. Edit the text in that function to provide help
-   **`--logfile [FILE]`** Full PATH to logfile. (Default is `${HOME}/logs/$(basename "$0").log`)
-   **`loglevel [LEVEL]`**: Log level of the script. One of: `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `ALL`, `OFF` (Default is '`ERROR`')
-   **`-n, --dryrun`**: Dryrun, sets `$DRYRUN` to `true` allowing you to write functions that will work non-destructively using the `_execute_` function
-   **`-q, --quiet`**: Runs in quiet mode, suppressing all output to stdout. Will still write to log files
-   **`-v, --verbose`**: Sets `$VERBOSE` to `true` and prints all debug messages to stdout
-   **`--force`**: If using the `_seekConfirmation_` utility function, this skips all user interaction. Implied `Yes` to all confirmations.

You can add custom script options and flags to the `_parseOptions_` function.

### Script Initialization

The bottom of the script template file contains a block which initializes the script. Comment, uncomment, or change the settings here for your needs

```bash
trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR

# Trap errors in subshells and functions
set -o errtrace

# Exit on error. Append '||true' if you expect an error
set -o errexit

# Use last non-zero exit code in a pipeline
set -o pipefail

# Confirm we have BASH greater than v4
[ "${BASH_VERSINFO:-0}" -ge 4 ] || {
    printf "%s\n" "ERROR: BASH_VERSINFO is '${BASH_VERSINFO:-0}'.  This script requires BASH v4 or greater."
    exit 1
}

# Make `for f in *.txt` work when `*.txt` matches zero files
shopt -s nullglob globstar

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode
# set -o xtrace

# Source utility functions
_sourceUtilities_

# Initialize color constants
_setColors_

# Disallow expansion of unset variables
set -o nounset

# Force arguments when invoking the script
# [[ $# -eq 0 ]] && _parseOptions_ "-h"

# Parse arguments passed to script
_parseOptions_ "$@"

# Create a temp directory '$TMP_DIR'
# _makeTempDir_ "$(basename "$0")"

# Acquire script lock
# _acquireScriptLock_

# Source GNU utilities for use on MacOS
# _useGNUUtils_

# Run the main logic script
_mainScript_

# Exit cleanly
_safeExit_
```

# Utility Functions

The files within `utilities/` contain BASH functions which can be used in your scripts. Each included function includes detailed usage information. Read the inline comments within the code for detailed usage instructions.

## Including Utility Functions

Within the `utilities` folder are many BASH functions meant to ease development of more complicated scripts. These can be included in the template in two ways.

#### 1. Copy and paste into template_standalone.sh

You can copy any complete function from the Utilities and place it into your script. Copy it beneath the `### Custom utility functions` line. Scripts created this way are fully portable among systems

#### 2. Source all the utility files by using template.sh

`template.sh` contains a function to source all the utility files into the script. **IMPORTANT:** You will need to update the paths within the `_sourceUtilities_` function to ensure your script can find this repository.

## alerts.bash

-   **`_columns_`** Prints a two column output from a key/value pair
-   -**`_printFuncStack_`** Prints the function stack in use. Used for debugging, and error reporting
-   **`_alert_`** Performs alerting functions including writing to a log file and printing to screen
-   **`_centerOutput_`** Prints text in the center of the terminal window
-   **`_setColors_`** Sets color constants for alerting (**Note:** Colors default to a dark theme.)

Basic alerting, logging, and setting color functions (included in `scriptTemplate.sh` by default). Print messages to stdout and to a user specified logfile using the following functions.

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

The following global variables must be set for the alert functions to work

-   **`$DEBUG`** - If `true`, prints `debug` level alerts to stdout. (Default: `false`)
-   **`$DRYRUN`** - If `true` does not eval commands passed to `_execute_` function. (Default: `false`)
-   **`$LOGFILE`** - Path to a log file
-   **`$LOGLEVEL`** - One of: FATAL, ERROR, WARN, INFO, DEBUG, ALL, OFF (Default: `ERROR`)
-   **`$QUIET`** - If `true`, prints to log file but not stdout. (Default: `false`)

## arrays.bash

Utility functions for working with arrays.

-   **`_dedupeArray_`** Removes duplicate array elements
-   **`_forEachDo_`** Iterates over elements and passes each to a function
-   **`_forEachFilter_`** Iterates over elements, returning only those that are validated by a function
-   **`_forEachFind_`** Iterates over elements, returning the first value that is validated by a function
-   **`_forEachReject_`** Iterates over elements, returning only those that are NOT validated by a function
-   **`_forEachValidate_`** Iterates over elements and passes each to a function for validation
-   **`_inArray_`** Determine if a value is in an array
-   **`_isEmptyArray_`** Checks if an array is empty
-   **`_joinArray_`** Joins items together with a user specified separator
-   **`_mergeArrays_`** Merges the values of two arrays together
-   **`_randomArrayElement_`** Selects a random item from an array
-   **`_reverseSortArray_`** Sorts an array from highest to lowest
-   **`_setdiff_`** Return items that exist in ARRAY1 that are do not exist in ARRAY2
-   **`_sortArray_`** Sorts an array from lowest to highest

## checks.bash

Functions for validating common use-cases

-   **`_commandExists_`** Check if a command or binary exists in the PATH
-   **`_functionExists_`** Tests if a function is available in current scope
-   **`_isInternetAvailable_`** Checks if Internet connections are possible
-   **`_isAlpha_`** Validate that a given variable contains only alphabetic characters
-   **`_isAlphaDash_`** Validate that a given variable contains only alpha-numeric characters, as well as dashes and underscores
-   **`_isAlphaNum_`** Validate that a given variable contains only alpha-numeric characters
-   **`_isDir_`** Validate that a given input points to a valid directory
-   **`_isEmail_`** Validates that an input is a valid email address
-   **`_isFQDN_`** Determines if a given input is a fully qualified domain name
-   **`_isFile_`** Validate that a given input points to a valid file
-   **`_isIPv4_`** Validates that an input is a valid IPv4 address
-   **`_isIPv6_`** Validates that an input is a valid IPv6 address
-   **`_isNum_`** Validate that a given variable contains only numeric characters
-   **`_isTerminal_`** Checks if script is run in an interactive terminal
-   **`_rootAvailable_`** Validate we have superuser access as root (via sudo if requested)
-   **`_varIsEmpty_`** Checks if a given variable is empty or null
-   **`_varIsFalse_`** Checks if a given variable is false
-   **`_varIsTrue_`** Checks if a given variable is true

## dates.bash

Functions for working with dates and time.

-   **`_convertToUnixTimestamp_`** Converts a date to unix timestamp
-   **`_countdown_`** Sleep for a specified amount of time
-   **`_dateUnixTimestamp_`** Current time in unix timestamp
-   **`_formatDate_`** Reformats dates into user specified formats
-   **`_fromSeconds_`** Convert seconds to HH:MM:SS
-   **`_monthToNumber_`** Convert a month name to a number
-   **`_numberToMonth_`** Convert a month number to its name
-   **`_parseDate_`** Takes a string as input and attempts to find a date within it to parse into component parts (day, month, year)
-   **`_readableUnixTimestamp_`** Format unix timestamp to human readable format
-   **`_toSeconds_`** Converts HH:MM:SS to seconds

## debug.bash

Functions to aid in debugging BASH scripts

-   **`_pauseScript_`** Pause a script at any point and continue after user input
-   **`_printAnsi_`** Helps debug ansi escape sequence in text by displaying the escape codes
-   **`_printArray_`** Prints the content of array as key value pairs for easier debugging

## files.bash

Functions for working with files.

-   **`_backupFile_`** Creates a backup of a specified file with .bak extension or optionally to a specified directory.
-   **`_decryptFile_`** Decrypts a file with `openssl`
-   **`_encryptFile_`** Encrypts a file with `openssl`
-   **`_extractArchive_`** Extract a compressed file
-   **`_fileBasename_`** Gets the basename of a file from a file name
-   **`_fileContains_`** Tests whether a file contains a given pattern
-   **`_filePath_`** Gets the absolute path to a file
-   **`_fileExtension_`** Gets the extension of a file
-   **`_fileName_`** Prints a filename from a path
-   **`_json2yaml_`** Convert JSON to YAML uses python
-   **`_listFiles_`** Find files in a directory. Use either glob or regex.
-   **`_makeSymlink_`** Creates a symlink and backs up a file which may be overwritten by the new symlink. If the exact same symlink already exists, nothing is done.
-   **`_parseYAML_`** Convert a YAML file into BASH variables for use in a shell script
-   **`_printFileBetween_`** Prints block of text in a file between two regex patterns
-   **`_randomLineFromFile_`** Prints a random line from a file
-   **`_readFile_`** Prints each line of a file
-   **`_sourceFile_`** Source a file into a script
-   **`_createUniqueFilename_`** Ensure a file to be created has a unique filename to avoid overwriting other files
-   **`_yaml2json_`** Convert a YAML file to JSON with python

## macOS.bash

Functions useful when writing scripts to be run on macOS

-   **`_guiInput_`** Ask for user input using a Mac dialog box
-   **`_haveScriptableFinder_`** Determine whether we can script the Finder or not
-   **`_homebrewPath_`** Adds Homebrew bin directory to PATH
-   **`_useGNUUtils_`** Add GNU utilities to PATH to allow consistent use of sed/grep/tar/etc. on MacOS

## misc.bash

Miscellaneous functions

-   **`_acquireScriptLock_`** Acquire script lock to prevent running the same script a second time before the first instance exits
-   **`_detectLinuxDistro_`** Detects the host computer's distribution of Linux
-   **`_detectMacOSVersion_`** Detects the host computer's version of macOS
-   **`_detectOS_`** Detect the the host computer's operating system
-   **`_endspin_`** Clears output from the _spinner_
-   **`_execute_`** Executes commands with safety and logging options. Respects `DRYRUN` and `VERBOSE` flags.
-   **`_findBaseDir_`** Locates the real directory of the script being run. Similar to GNU readlink -n
-   **`_generateUUID_`** Generates a unique UUID
-   **`_progressBar_`** Prints a progress bar within a for/while loop
-   **`_runAsRoot_`** Run the requested command as root (via sudo if requested)
-   **`_seekConfirmation_`** Seek user input for yes/no question
-   **`_spinner_`** Creates a spinner within a for/while loop.
-   **`_trapCleanup_`** Cleans up after a trapped error.

## services.bash

Functions to work with external services

-   **`_haveInternet_`** Tests to see if there is an active Internet connection
-   **`_httpStatus_`** Report the HTTP status of a specified URL
-   **`_pushover_`** Sends a notification via Pushover (Requires API keys)

## strings.bash

Functions for string manipulation

-   **`_cleanString_`** Cleans a string of text
-   **`_decodeHTML_`** Decode HTML characters with sed. (Requires sed file)
-   **`_decodeURL_`** Decode a URL encoded string
-   **`_encodeHTML_`** Encode HTML characters with sed (Requires sed file)
-   **`_encodeURL_`** URL encode a string
-   **`_escapeString_`** Escapes a string by adding `\` before special chars
-   **`_lower_`** Convert a string to lowercase
-   **`_ltrim_`** Removes all leading whitespace (from the left)
-   **`_regexCapture_`** Use regex to validate and parse strings
-   **`_rtrim_`** Removes all leading whitespace (from the right)
-   **`_splitString_`** Split a string based on a given delimiter
-   **`_stringContains_`** Tests whether a string matches a substring
-   **`_stringRegex_`** Tests whether a string matches a regex pattern
-   **`_stripANSI_`** Strips ANSI escape sequences from text
-   **`_stripStopwords_`** Removes common stopwords from a string using a list of sed replacements located in an external file.
-   **`_trim_`** Removes all leading/trailing whitespace
-   **`_upper_`** Convert a string to uppercase

## template_utils.bash

Functions required to allow the script template and alert functions to be used

-   **`_makeTempDir_`** Creates a temp directory to house temporary files
-   **`_safeExit_`** Cleans up temporary files before exiting a script
-   **`_setPATH_`** Add directories to $PATH so script can find executables

# Coding conventions

-   Function names use camel case surrounded by underscores: `_nameOfFunction_`
-   Local variable names use camel case with a starting underscore: `_localVariable`
-   Global variables are in ALL_CAPS with underscores separating words
-   Exceptions to the variable an function naming rules are made for alerting functions and colors to ease my speed of programming. (Breaking years of habits is hard...) I.e. `notice "Some log item: ${blue}blue text${reset}` Where `notice` is a function and `$blue` and `$reset` are global variables but are lowercase.
-   Variables are always surrounded by quotes and brackets `"${1}"` (Overly verbose true, but a safe practice)
-   Formatting is provided by [shfmt](https://github.com/mvdan/sh) using 4 spaces for indentation
-   All scripts and functions are fully [Shellcheck](https://github.com/koalaman/shellcheck) compliant
-   Where possible, I follow [defensive BASH programming](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/) principles.

## A Note on Code Reuse and Prior Art

I compiled these scripting utilities over many years without having an intention to make them public. As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs. I often lift a function whole-cloth from a GitHub repo don't keep track of its original location. I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible. Unfortunately, I fear that I missed as many as I found. My goal in making this repository public is not to take credit for the code written by others. If you recognize something that I didn't credit, please let me know.

## Contributing

### Setup

1. Install Python 3.11 and [Poetry](https://python-poetry.org)
2. Clone this repository. `git clone https://github.com/natelandau/shell-scripting-templates.git`
3. Install the Poetry environment with `poetry install`.
4. Activate your Poetry environment with `poetry shell`.
5. Install the pre-commit hooks with `pre-commit install --install-hooks`.

### Developing

-   Activate your Poetry environment with `poetry shell`.
-   This project follows the [Conventional Commits](https://www.conventionalcommits.org/) standard to automate [Semantic Versioning](https://semver.org/) and [Keep A Changelog](https://keepachangelog.com/) with [Commitizen](https://github.com/commitizen-tools/commitizen).
    -   When you're ready to commit changes run `cz c`
-   Run `poe` from within the development environment to print a list of [Poe the Poet](https://github.com/nat-n/poethepoet) tasks available to run on this project. Common commands:
    -   `poe lint` runs all linters and tests
-   Run `poetry add {package}` from within the development environment to install a runtime dependency and add it to `pyproject.toml` and `poetry.lock`.
-   Run `poetry remove {package}` from within the development environment to uninstall a runtime dependency and remove it from `pyproject.toml` and `poetry.lock`.
-   Run `poetry update` from within the development environment to upgrade all dependencies to the latest versions allowed by `pyproject.toml`.

## License

MIT
