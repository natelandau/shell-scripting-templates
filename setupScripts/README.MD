# Setup Scripts Readme File
These are the files I have created to mange the configuration of new computers.

## File Manifest

### Actively in use
These files are actively maintained and in use.

* **casks.sh** - Installs native Mac applications via [Homebrew Cask](https://github.com/caskroom/homebrew-cask) casks and runs Brew maintenance scripts
* **dropbox.sh** - Installs [Dropbox](http://dropbox.com) if not already installed
* **fileTest.sh** - Maintenance script to run occasionally.  This ensures that the files called from the `mackup.sh` actually exist.  If any of these files fail `mackup.sh` will fail as well.
* **fileTest.txt** - Text files containing the paths to documents and directories within Dropbox.  This list is called from `mackup.sh` as well as `dropboxFileTest.sh` and is used to ensure that files have synced correctly.
* **functions.sh** - The backbone of my process.  Contains most of the logic for the other scripts that are in use and makes them available as shared functions.
* **homebrew.sh** - Installs unix based [Homebrew](http://brew.sh/) packages and runs Brew maintenance scripts
* **mackup.sh** - This script configures and installs [mackup](https://github.com/lra/mackup), and then restores my files from Dropbox to their correct locations.  **Note:** *This script relies on the existence of certain files in Dropbox to ensure that synching has completed.  This list of files needs maintenance from time to time.*
* **newMackSetup.sh** - This is script calls all of the other scripts in the correct order to configure a new computer from scratch.  
* **osx.sh** - This script contains the Mac OSX specific settings.
* **ruby.sh** - This script installs [RVM (Ruby Version Manager)](http://rvm.io/) and certain Gems including Jekyll.
* **ssd.sh** - Optional script for configuring non-Apple native SSDs
* **ssh.sh** - Script to configure SSH and link it to Github
* **utils.sh** - This is a utilities script containing common BASH scripting utilities.

### Scratch files
These files are not actively in use.  They are either old and for reference purposes or test files.

* **dropboxsymlinks.sh** - Before discovering [mackup](https://github.com/lra/mackup) I wrote this script to symlink my own files through Dropbox.  Saved for posterity to remind myself that I don't know how to code.
* **otherPeopleMackupScript.sh** - Hacked together script to attempt to get Mackup running on someone else's computer without any of the other scripts listed above.
* **testScript.sh** - A scratch file used to test different BASH functions.  Erase at will.

## USAGE
To configure a new computer simply run the script `newMacSetup.sh` in Terminal.app and follow the instructions.
