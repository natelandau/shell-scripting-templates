### Usage

Before loading `Bash Functions Library` to any script your should declare it's location in global variable like `$BASH_FUNCTION_LIBRARY`.<br />
Since I source functions from current project to many system scripts, I have to define the file where this variable is declared.<br />
In my system this variable and some other exported variables of common used tools are declared in `${HOME}/getConsts`.<br />
This way I can change `Bash Functions Library` locaton without rewriting source in many system files.<br />
I have to change variable `$BASH_FUNCTION_LIBRARY` only. The method you load `${HOME}/getConsts` or other script as system starting you should define **by yourself** (maybe from `/etc/profile` or `/etc/profile.d/script.sh` ... )

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
Note: readonly is a "Special Builtin". If Bash is in POSIX mode then readonly (and not declare) has the effect "returning an error status will not cause the shell to exit" [https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash](https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash)<br />

In this case location of `Bash Functions Library` will be exported variable.<br />
In my system I put current project directly to `/etc` directory because of integrating `Bash Functions Library` in many system scripts.<br />
Every script like `/etc/bash.bashrc`, `/etc/bashrc`, `~/.bashrc`, `~/.profile` and others at script' beginning loads `Bash Functions Library` and `${HOME}/getConsts` together:
```bash
# Plug in external script libarary
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY" ; }
```
As a result, `getConsts` will be loaded no more than once.<br />
**Source in your scripts `autoload.sh`**, because most of the `BFL` functions depend on one or more of the others.<br />
It is very important to handle errors. I have `trap` function declaration in my `.bashrc` **after**  $BASH\_FUNCTION_LIBRARY sourcing:
```bash
set -o functrace
trap 'bfl::trap_cleanup "$?" "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]}" "$BASH_COMMAND" "$0" "${BASH_SOURCE[0]} "$*" "$HOME/.faults"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
```
where `"$HOME/.faults"` is my log file.

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
