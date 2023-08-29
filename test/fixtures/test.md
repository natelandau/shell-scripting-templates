# About

This repository contains everything needed to bootstrap and configure new Mac computer. Included here are:

-   dotfiles
-   ~/bin/ scripts
-   Configuration files
-   Scripting templates and utilities
-   `install.sh`, a script to put everything where it needs to go

**Disclaimer:** _I am not a professional programmer and I bear no responsibility whatsoever if any of these scripts wipes your computer, destroys your data, crashes your car, or otherwise causes mayhem and destruction. USE AT YOUR OWN RISK._

## install.sh

This script runs through a series of tasks to configure a new computer. There are three distinct areas of `install.sh` which are executed in order. These are:

1. **Bootstrapping** - Installing base components such as Command Line Tools, Homebrew, Node, RVM, etc.
2. **Installation** - Symlinking dotfiles and installing executables such as NPM Packages, Homebrew Casks, etc.
3. **Configuration** - Configures installed packages and apps.

The files are organized into three subdirectories.

```
dotfiles
├── bin/
├── config/
│   ├── bash/
│   └── shell/
├── install.sh
├── install-config.yaml
├── lib/
│   ├── bootstrap/
│   └── configure/
└── scripting/
```

-   **bin** - Symlinked to `~/bin` and is added to your `$PATH`.
-   **config** - Contains the elements needed to configure your environment and specific apps.
-   config/**bash** - Files in this directory are _sourced_ by `.bash_profile`.
-   config/**shell** - Files here are symlinked to your local environment. Ahem, dotfiles.
-   **lib** - Contains the scripts and configuration for `install.sh`
-   lib/**bootstrap** - Scripts here are executed by `install.sh` first.
-   lib/**configure** - Scripts here are executed by `install.sh` after packages have been installed
-   **config-install.yaml** - This YAML file contains the list of symlinks to be created, as well as the packages to be installed.
-   **scripting** - This directory contains bash scripting utilities and templates which I re-use often.

**IMPORTANT:** Unless you want to use my defaults, make sure you do the following:

-   Edit `config-install.yaml` to reflect your preferred packages
-   Review the files in `config/` to configure your own aliases, preferences, etc.

#### Private Files

Sometimes there are files which contain private information. These might be API keys, local directory structures, or anything else you want to keep hidden.

Private files are held in a separate folder named `private`. This repository is added as a git-submodule and files within it are symlinked to `$HOME` or sourced to the Bash terminal.

Since you're not me, you should **fork this repository and replace the `private` directory with a git submodule of your own.**

Within the private directory you can write your own install script to configure and install your own files. This script should be named: `privateInstall.sh`

If `private/privateInstall.sh` exists, `install.sh` will invoke it.

## Cloning this repo to a new computer

The first step needed to use these dotfiles is to clone this repo into the $HOME directory. To make this easy, I created [a gist](https://gist.github.com/natelandau/b6ec165862277f3a7a4beff76da53a9c) which can easily be run with the following command:

```
curl -SL https://gist.githubusercontent.com/natelandau/b3e1dfba7491137f0a0f5e25721fffc2/raw/d98763695a0ddef1de9db2383f43149005423f20/bootstrapNewMac | bash
```

This gist creates a script `~/bootstrap.sh` in your home directory which completes the following tasks

1. Creates a new public SSH key if needed
2. Copies your public key to your clipboard
3. Opens Github to allow you to add this public key to your 'known keys'
4. Clones this dotfiles repo to your home directory

See. Easy. Now you're ready to run `~/dotfiles/install.sh` and get your new computer working.

### A Note on Code Reuse

Many of the scripts, configuration files, and other information herein were created by me over many years without ever having the intention to make them public. As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs. Quite often I would lift a function whole-cloth from a GitHub repo and not keep track of it's original location. I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible. Unfortunately, I fear that I missed as many as I found. My goal of making this repository public is not to take credit for the wonderful code written by others. If you recognize or wrote something here that I didn't credit, please let me know.
