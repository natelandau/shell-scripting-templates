This directory contains the shared libraries and functions that are required by the scripts within this repository.

# utils.sh
This script must be sourced from all my additional scripts.  Contained within this are two important functions.  

1. **Logging** -  All scripts use the logging functions.  There are nine different levels of logs.  All log levels are called from within a script in the format `info "some message"`.  The levels of logging are:
	* **die** - Prints an error and exits the script 
	* **error** - prints an error and continues to run the script
	* **warning** - prints a warning
	* **notice** - prints a notice to the user
	* **info** - prints information to the user
	* **debug** - prints debug information.  This output hidden unless scripts are run with the verbose (`-v`) flag
	* **success** - prints success to a user
	* **input** - Asks the user for input
	* **header** - Prints a header to help format logs
2. **Sourcing Additional Files** - This script reads a list of additional files and sources them.

# setupScriptFunctions.sh
This script contains different functions used to install software and configure Mac computers from the scripts contained in the `setupScripts` directory.

# sharedVariables.sh
This script contains variables that can be called from any other script.

# sharedFunctions.sh
This script contains many different functions which can be used throughout different scripts.  The script is well commented.


