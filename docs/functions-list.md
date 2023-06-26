## Bash Function Library
[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / [Installation](installation.md) / [Description](description.md) / Coding / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Function List

## alerts.bash

- **`_columns_`** Prints a two column output from a key/value pair
- -**`_printFuncStack_`** Prints the function stack in use. Used for debugging, and error reporting
- **`_alert_`** Performs alerting functions including writing to a log file and printing to screen
- **`_centerOutput_`** Prints text in the center of the terminal window
- **`_setColors_`** Sets color constants for alerting (**Note:** Colors default to a dark theme.)

## arrays.bash

Utility functions for working with arrays.

- **`_dedupeArray_`** Removes duplicate array elements
- **`_forEachDo_`** Iterates over elements and passes each to a function
- **`_forEachFilter_`** Iterates over elements, returning only those that are validated by a function
- **`_forEachFind_`** Iterates over elements, returning the first value that is validated by a function
- **`_forEachReject_`** Iterates over elements, returning only those that are NOT validated by a function
- **`_forEachValidate_`** Iterates over elements and passes each to a function for validation
- **`_inArray_`** Determine if a value is in an array
- **`_isEmptyArray_`** Checks if an array is empty
- **`_joinArray_`** Joins items together with a user specified separator
- **`_mergeArrays_`** Merges the values of two arrays together
- **`_randomArrayElement_`** Selects a random item from an array
- **`_reverseSortArray_`** Sorts an array from highest to lowest
- **`_setdiff_`** Return items that exist in ARRAY1 that are do not exist in ARRAY2
- **`_sortArray_`** Sorts an array from lowest to highest

## checks.bash

Functions for validating common use-cases

- **`_commandExists_`** Check if a command or binary exists in the PATH
- **`_functionExists_`** Tests if a function is available in current scope
- **`_isInternetAvailable_`** Checks if Internet connections are possible
- **`_isAlpha_`** Validate that a given variable contains only alphabetic characters
- **`_isAlphaDash_`** Validate that a given variable contains only alpha-numeric characters, as well as dashes and underscores
- **`_isAlphaNum_`** Validate that a given variable contains only alpha-numeric characters
- **`_isDir_`** Validate that a given input points to a valid directory
- **`_isEmail_`** Validates that an input is a valid email address
- **`_isFQDN_`** Determines if a given input is a fully qualified domain name
- **`_isFile_`** Validate that a given input points to a valid file
- **`_isIPv4_`** Validates that an input is a valid IPv4 address
- **`_isIPv6_`** Validates that an input is a valid IPv6 address
- **`_isNum_`** Validate that a given variable contains only numeric characters
- **`_isTerminal_`** Checks if script is run in an interactive terminal
- **`_rootAvailable_`** Validate we have superuser access as root (via sudo if requested)
- **`_varIsEmpty_`** Checks if a given variable is empty or null
- **`_varIsFalse_`** Checks if a given variable is false
- **`_varIsTrue_`** Checks if a given variable is true

## dates.bash

Functions for working with dates and time.

- **`_convertToUnixTimestamp_`** Converts a date to unix timestamp
- **`_countdown_`** Sleep for a specified amount of time
- **`_dateUnixTimestamp_`** Current time in unix timestamp
- **`_formatDate_`** Reformats dates into user specified formats
- **`_fromSeconds_`** Convert seconds to HH:MM:SS
- **`_monthToNumber_`** Convert a month name to a number
- **`_numberToMonth_`** Convert a month number to its name
- **`_parseDate_`** Takes a string as input and attempts to find a date within it to parse into component parts (day, month, year)
- **`_readableUnixTimestamp_`** Format unix timestamp to human readable format
- **`_toSeconds_`** Converts HH:MM:SS to seconds

## debug.bash

Functions to aid in debugging BASH scripts

- **`_pauseScript_`** Pause a script at any point and continue after user input
- **`_printAnsi_`** Helps debug ansi escape sequence in text by displaying the escape codes
- **`_printArray_`** Prints the content of array as key value pairs for easier debugging

## files.bash

Functions for working with files.

- **`_backupFile_`** Creates a backup of a specified file with .bak extension or optionally to a specified directory.
- **`_decryptFile_`** Decrypts a file with `openssl`
- **`_encryptFile_`** Encrypts a file with `openssl`
- **`_extractArchive_`** Extract a compressed file
- **`_fileBasename_`** Gets the basename of a file from a file name
- **`_fileContains_`** Tests whether a file contains a given pattern
- **`_filePath_`** Gets the absolute path to a file
- **`_fileExtension_`** Gets the extension of a file
- **`_fileName_`** Prints a filename from a path
- **`_json2yaml_`** Convert JSON to YAML uses python
- **`_listFiles_`** Find files in a directory. Use either glob or regex.
- **`_makeSymlink_`** Creates a symlink and backs up a file which may be overwritten by the new symlink. If the exact same symlink already exists, nothing is done.
- **`_parseYAML_`** Convert a YAML file into BASH variables for use in a shell script
- **`_printFileBetween_`** Prints block of text in a file between two regex patterns
- **`_readFile_`** Prints each line of a file
- **`_sourceFile_`** Source a file into a script
- **`_createUniqueFilename_`** Ensure a file to be created has a unique filename to avoid overwriting other files
- **`_yaml2json_`** Convert a YAML file to JSON with python

## macOS.bash

Functions useful when writing scripts to be run on macOS

- **`_guiInput_`** Ask for user input using a Mac dialog box
- **`_haveScriptableFinder_`** Determine whether we can script the Finder or not
- **`_homebrewPath_`** Adds Homebrew bin directory to PATH
- **`_useGNUUtils_`** Add GNU utilities to PATH to allow consistent use of sed/grep/tar/etc. on MacOS

## misc.bash

Miscellaneous functions

- **`_acquireScriptLock_`** Acquire script lock to prevent running the same script a second time before the first instance exits
- **`_detectLinuxDistro_`** Detects the host computer's distribution of Linux
- **`_detectMacOSVersion_`** Detects the host computer's version of macOS
- **`_detectOS_`** Detect the the host computer's operating system
- **`_endspin_`** Clears output from the _spinner_
- **`_execute_`** Executes commands with safety and logging options. Respects `DRYRUN` and `VERBOSE` flags.
- **`_findBaseDir_`** Locates the real directory of the script being run. Similar to GNU readlink -n
- **`_generateUUID_`** Generates a unique UUID
- **`_progressBar_`** Prints a progress bar within a for/while loop
- **`_runAsRoot_`** Run the requested command as root (via sudo if requested)
- **`_seekConfirmation_`** Seek user input for yes/no question
- **`_spinner_`** Creates a spinner within a for/while loop.
- **`_trapCleanup_`** Cleans up after a trapped error.

## services.bash

Functions to work with external services

- **`_haveInternet_`** Tests to see if there is an active Internet connection
- **`_httpStatus_`** Report the HTTP status of a specified URL
- **`_pushover_`** Sends a notification via Pushover (Requires API keys)

## strings.bash

Functions for string manipulation

- **`_cleanString_`** Cleans a string of text
- **`_decodeHTML_`** Decode HTML characters with sed. (Requires sed file)
- **`_decodeURL_`** Decode a URL encoded string
- **`_encodeHTML_`** Encode HTML characters with sed (Requires sed file)
- **`_encodeURL_`** URL encode a string
- **`_escapeString_`** Escapes a string by adding `\` before special chars
- **`_lower_`** Convert a string to lowercase
- **`_ltrim_`** Removes all leading whitespace (from the left)
- **`_regexCapture_`** Use regex to validate and parse strings
- **`_rtrim_`** Removes all leading whitespace (from the right)
- **`_splitString_`** Split a string based on a given delimeter
- **`_stringContains_`** Tests whether a string matches a substring
- **`_stringRegex_`** Tests whether a string matches a regex pattern
- **`_stripANSI_`** Strips ANSI escape sequences from text
- **`_stripStopwords_`** Removes common stopwords from a string using a list of sed replacements located in an external file.
- **`_trim_`** Removes all leading/trailing whitespace
- **`_upper_`** Convert a string to uppercase

## template_utils.bash

Functions required to allow the script template and alert functions to be used

- **`_makeTempDir_`** Creates a temp directory to house temporary files
- **`_safeExit_`** Cleans up temporary files before exiting a script
- **`_setPATH_`** Add directories to $PATH so script can find executables
