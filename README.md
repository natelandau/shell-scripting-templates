# Shell Scripting Templates and Utilities
A collection of shell scripting utilities and templates used to ease the creation of BASH scripts. [BATS](https://github.com/bats-core/bats-core) provides unit testing capabilities.  All tests are in the `tests/` repo.

## Bash Script Template Usage
To create a new script, copy `scriptTemplate.sh` to a new file and make it executable `chmod 755 [newscript].sh`.  Place your custom script logic within the `_mainScript_` function at the top of the script.

### Script Template Usage
Default flags included in the base template are:

  * `-h`: Prints the contents of the `_usage_` function. Edit the text in that function to provide help
  * `-l [level]`: Log level of the script. One of: `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `ALL`, `OFF`  (Default is '`ERROR`')
  * `-n`: Dryrun, sets `$DRYRUN` to `true` allowing you to write functions that will work non-destructively using the `_execute_` function
  * `-v`: Sets `$VERBOSE` to `true` and prints all debug messages to stdout
  * `-q`: Runs in quiet mode, suppressing all output to stdout. Will still write to log files
  * `--force`: If using the `_seekConfirmation_` utility function, this skips all user interaction.  Implied `Yes` to all confirmations.

You can add custom script options and flags to the `_parseOptions_` function.

### Script Template Functions
scriptTemplate.sh includes some helper functions to perform common tasks.

  * `_alert_` Provides alerting and logging functionality. See notes below.
  * `_trapCleanup_` Cleans up files on error
  * `_makeTempDir_` Creates a temp directory to house temporary files
  * `_acquireScriptLock_` Acquires script lock to avoid race conditions on files
  * `_functionStack_` Prints the function stack in use to aid debugging
  * `_parseOptions_` Parse options and take user input (`-a`, `--some-flag`, and `--some-file [filename]` supported)
  * `_usage_` Prints help text when `-h` passed
  * `_safeExit_` Used to exit gracefully, cleaning up all temporary files etc.

### Script Initialization
The bottom of the script template file contains a block which initializes the script.  Comment, uncomment, or change the settings here for your needs

```bash
trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' \
  EXIT INT TERM SIGINT SIGQUIT
set -o errtrace                           # Trap errors in subshells and functions
set -o errexit                            # Exit on error. Append '||true' if you expect an error
set -o pipefail                           # Use last non-zero exit code in a pipeline
# shopt -s nullglob globstar              # Make `for f in *.txt` work when `*.txt` matches zero files
IFS=$' \n\t'                              # Set IFS to preferred implementation
# set -o xtrace                           # Run in debug mode
set -o nounset                            # Disallow expansion of unset variables
# [[ $# -eq 0 ]] && _parseOptions_ "-h"   # Force arguments when invoking the script
_parseOptions_ "$@"                       # Parse arguments passed to script
# _makeTempDir_ "$(basename "$0")"        # Create a temp directory '$tmpDir'
# _acquireScriptLock_                     # Acquire script lock
_mainScript_                              # Run the main logic script
_safeExit_                                # Exit cleanly
```

# Utility Files
The files within `utilities/` contain BASH functions which can be used in your scripts.  Each included function includes detailed usage information. Read the code for instructions.

## Including Utility Functions
Within the `utilities` folder are many BASH functions meant to ease development of more complicated scripts.  These can be included in the template in two ways.

#### 1. Copy and Paste
You can copy any complete function from the Utilities and place it into your script.  Copy it beneath the end of `_mainscript_()`

#### 2. Source entire utility files
You can source entire utility files by pasting the following snippet into your script beneath `_mainScript_()`. Be sure to replace `[PATH_TO]` with the full path to this repository.

```bash
_sourceHelperFiles_() {
  # DESC: Sources script helper files.
  local filesToSource
  local sourceFile
  filesToSource=(
    "[PATH_TO]/shell-scripting-templates/utilities/baseHelpers.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/arrays.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/files.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/macOS.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/numbers.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/services.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/textProcessing.bash"
    "[PATH_TO]/shell-scripting-templates/utilities/dates.bash"
  )
  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "${sourceFile}" ] \
      && {
        echo "error: Can not find sourcefile '${sourceFile}'."
        echo "exiting..."
        exit 1
      }
    source "${sourceFile}"
  done
}
_sourceHelperFiles_
```

## alerts.bash
Basic alerting, logging, and setting color functions (included in scriptTemplate.sh by default).  Print messages to stdout and to a user specified logfile using the following functions.

```bash
debug "some text"     # Printed only when in Verbose mode
info "some text"      # Basic informational messages
notice "some text"    # Messages which should be read. Brighter than 'info'
warning "some text"   # Non-critical warnings
error "some text"     # Error state warnings. (Does not stop the script)
fatal "some text"     # Fatal errors. Exits the script
success "some text"   # Prints a success message
header "some text"    # Prints a header element
```

Set the following variables for the alert functions to work.

* `$LOGFILE` - Location of a log file
* `$LOGLEVEL` - One of: FATAL, ERROR, WARN, INFO, DEBUG, ALL, OFF  (Default is 'ERROR')
* `$QUIET` - If `true`, nothing will print to STDOUT (Logs files will still be populated)

## arrays.bash
Common functions for working with BASH arrays.

  * `_inArray_` Determine if a value is in an array
  * `_join_` Joins items together with a user specified separator
  * `_setdiff_` Return items that exist in ARRAY1 that are do not exist in ARRAY2
  * `_removeDupes_` Removes duplicate array elements
  * `_randomArrayElement_` Selects a random item from an array

## baseHelpers.bash
Commonly used functions in many scripts

  * `_execute_` Executes commands with safety and logging options. Respects `DRYRUN` and `VERBOSE` flags.
  * `_findBaseDir_` Locates the real directory of the script being run. Similar to GNU readlink -n
  * `_checkBinary_` Check if a binary exists in the search PATH
  * `_haveFunction_` Tests if a function exists
  * `_pauseScript_` Pause a script at any point and continue after user input
  * `_progressBar_` Prints a progress bar within a for/while loop
  * `_rootAvailable_` Validate we have superuser access as root (via sudo if requested)
  * `_runAsRoot_` Run the requested command as root (via sudo if requested)
  * `_seekConfirmation_` Seek user input for yes/no question
  * `_setPATH_` Add directories to $PATH so script can find executables

## csv.bash
Functions to write to a CSV file.
  * `_makeCSV_` Creates a new CSV file if one does not already exist
  * `_writeCSV_` Takes passed arguments and writes them as a comma separated line

## dates.bash
Common utilities for working with dates in BASH scripts.

  * `_monthToNumber_` Convert a month name to a number
  * `_numberToMonth_` Convert a month number to its name
  * `_parseDate_` Takes a string as input and attempts to find a date within it to parse into component parts (day, month, year)
  * `_formatDate_` Reformats dates into user specified formats

## files.bash
Common utilities for working with files.

  * `_listFiles_` Find files in a directory.  Use either glob or regex.
  * `_backupFile_` Creates a backup of a specified file with .bak extension or optionally to a specified directory.
  * `_cleanFilename_` Cleans a filename of all non-alphanumeric (or user specified) characters and overwrites original
  * `_parseFilename_` Break a filename into its component parts which and place them into prefixed variables (dir, basename, extension, full path, etc.)
  * `_decryptFile_` Decrypts a file with `openssl`
  * `_encryptFile_` Encrypts a file with `openssl`
  * `_ext_` Extract the extension from a filename
  * `_extract_` Extract a compressed file
  * `_json2yaml_` Convert JSON to YAML uses python
  * `_makeSymlink_` Creates a symlink and backs up a file which may be overwritten by the new symlink. If the exact same symlink already exists, nothing is done.
  * `_parseYAML_` Convert a YANML file into BASH variables for use in a shell script
  * `_readFile_` Prints each line of a file
  * `_sourceFile_` Source a file into a script
  * `_uniqueFileName_` Ensure a file to be created has a unique filename to avoid overwriting other files
  * `_yaml2json_` Convert a YAML file to JSON with python

## macOS.bash
Functions useful when writing scripts to be run on macOS

  * `_haveScriptableFinder_` Determine whether we can script the Finder or not
  * `_guiInput_` Ask for user input using a Mac dialog box

## numbers.bash
Helpers to work with numbers

  * `_fromSeconds_` Convert seconds to HH:MM:SS
  * `_toSeconds_` Converts HH:MM:SS to seconds
  * `_countdown_` Sleep for a specified amount of time

## services.bash
Functions to work with external services

  * `_haveInternet_` Tests to see if there is an active Internet connection
  * `_httpStatus_` Report the HTTP status of a specified URL
  * `_pushover_` Sends a notification via Pushover (Requires API keys)

## testProcessing.bash
Work with strings in your script

  * `_cleanString_` Cleans a string of text
  * `_stopWords_` Removes common stopwords from a string. Requires a sed stopwords file.  Customize to your needs.
  * `_escape_` Escapes a string by adding `\` before special chars
  * `_htmlDecode_` Decode HTML characters with sed. (Requires sed file)
  * `_htmlEncode_` Encode HTML characters with sed (Requires sed file)
  * `_lower_` Convert a string to lowercase
  * `_upper_` Convert a string to uppercase
  * `_ltrim_` Removes all leading whitespace (from the left)
  * `_regex_` Use regex to validate and parse strings
  * `_rtrim_` Removes all leading whitespace (from the right)
  * `_trim_` Removes all leading/trailing whitespace
  * `_urlEncode_` URL encode a string
  * `_urlDecode_` Decode a URL encoded string

## A Note on Code Reuse
I compiled these scripting utilities over many years without having an intention to make them public.  As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs. I often lift a function whole-cloth from a GitHub repo don't keep track of its original location. I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible. Unfortunately, I fear that I missed as many as I found. My goal in making this repository public is not to take credit for the code written by others. If you recognize something that I didn't credit, please let me know.

## License
MIT
