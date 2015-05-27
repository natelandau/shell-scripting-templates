# Setup Scripts Readme File
These are the files I have created to mange the configuration of new computers.

## File Manifest
* **casks.sh** - Installs native Mac applications via [Homebrew Cask][1] casks and runs Brew maintenance scripts.
* **dropbox.sh** - Installs [Dropbox][2] if not already installed.
* **fileTest.sh** - Maintenance script to run occasionally.  This ensures that the files called from the `mackup.sh` actually exist.  If any of these files fail `mackup.sh` will fail as well.
* **homebrew.sh** - Installs [Homebrew][3] and associated packages and runs Brew maintenance scripts
* **mackup.sh** - This script configures and installs [mackup][4], and then restores my files from Dropbox to their correct locations.  **Note:** *This script relies on the existence of certain files in Dropbox to ensure that synching has completed.  This list of files needs maintenance from time to time.  You can test these files using `fileeTest.sh`*
* **newMackSetup.sh** - This is script calls all of the other scripts in the correct order to configure a new computer from scratch.  **Start here**.
* **osx.sh** - This script contains the Mac OSX specific settings.
* **ruby.sh** - This script installs [RVM (Ruby Version Manager)][5] and certain Gems including Jekyll.
* **ssh.sh** - Script to configure SSH and link it to Github.


## USAGE
To configure a new computer simply run the script `newMacSetup.sh` in Terminal.app and follow the onscreen instructions.

[1]: https://github.com/caskroom/homebrew-cask
[2]: http://dropbox.com
[3]: http://brew.sh/
[4]: https://github.com/lra/mackup
[5]: http://rvm.io/