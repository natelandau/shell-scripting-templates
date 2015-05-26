# My Shell Scripts
This is the centralized repository of all the shell scripts which I use for a number of different purposes.

**Important:**  *I am a novice programmer and I bear no responsibility whatsoever if any of these scripts that I have written wipes your computer, destroys your data, crashes your car, or otherwise causes mayhem and destruction.  USE AT YOUR OWN RISK.*

## What's here

* **etc/** - Many of my scripts and shared functions call for configuration files.  These configs are saved here.
* **lib/** - Shared functions and libraries that are used throughout the scripts.
* **setupScripts/** - Scripts that configure new Mac computers from scratch.  These scripts perform such tasks as:
	* Insalling [Homebrew][1] & associated packages
	* Installing mac applications using [Homebrew Cask][2]
	* Configuring OSX to my liking
	* Syncing user preferences and files using [Mackup][3]
	* Installing [RVM][4] and associated Gems
	* Pushing a new SSH key to Github
* **syncScripts/** - Scripts which use [RSYNC][5] and [Unison][6] to keep different directories and computers in sync. 

## Usage
Each of the directories has its own `README` describing in more depth how to use the files contained within.  Most of the scripts here won't work without the scripting utilities in `lib/`.

## Versioning

This project implements the [Semantic Versioning][7] guidelines.

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and patch)
* New additions without breaking backward compatibility bumps the minor (and resets the patch)
* Bug fixes and misc changes bumps the patch

For more information on SemVer, please visit [SemVer][7].

## A Note on Code Reuse
The scripts herein were created by me over many years without ever having the intention to make them public.  As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs.  Quite often I would lift a function whole-cloth from a GitHub repo and not keep track of it's original location.  I have done my best within the scripts to recreate my footsteps and give credit to the original creators of the code when possible.  Unfortunately, I fear that I missed as many as I found.  My goal of making these scripts public is not to take credit for the wonderful code written by others.  If you recognize or wrote something here that I didn't credit, please let me know.

[1]: http://brew.sh
[2]: http://caskroom.io
[3]: https://github.com/lra/mackup
[4]: https://rvm.io
[5]: http://en.wikipedia.org/wiki/Rsync
[6]: http://www.cis.upenn.edu/~bcpierce/unison/
[7]: http://semver.org
[8]: http://www.controlplaneapp.com/
