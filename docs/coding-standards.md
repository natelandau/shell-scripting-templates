[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / [Installation](installation.md) / [Description](description.md) / Coding / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Coding Standards

[Getting Started](#getting-started) / [About functions and library structure](#about-functions-and-library-structure) / [About function files](#about-function-files) / [bfl::die discussion](#bfl-die-discussion) / [Naming Conventions](#naming-conventions) / [Variables](#variables) / [Coding](#coding) / [Indenting and Whitespace](#indenting-and-whitespace) / [Library Functions](#library-functions) / [Scripts template](#scripts-template)

### Getting Started

**In short: use template:** [function template](../../../templates/_library_function.sh) in order to make BFL functions similar and to folow unified coding standards.<br />
Please, use this template to create a new library function. Contributions are welcome!

#### About functions and library structure:
- All libraries are located in `lib/`, every function located in `lib/[library_name]/` (like [Jarodiv](https://github.com/Jarodiv/bash-function-libraries)).<br />
[Natelandau](https://github.com/natelandau/shell-scripting-templates) also keeps scripts in separate directory, but named `utilities`.<br />
I have refused from nonstructured script location in project root (as in [JMooring](https://github.com/jmooring/bash-function-library) and [Ariver](https://github.com/ariver/bash_functions)).
- Each library function name must begin with `bfl::` namespace prefix to avoid function name collisions (as [JMooring](https://github.com/jmooring/bash-function-library)).<br />
For example, to trim a string:
```bash
bfl::trim "${var}"
```
Some git projects uses multilevel prefix, like `System::Efi::detect()` (as [Jarodiv](https://github.com/Jarodiv/bash-function-libraries)).<br />
There is exception for MacOS library from [NateLandau](https://github.com/natelandau/shell-scripting-templates): I saved `bfl::MacOS::` prefix.<br />
For rest libraries I refused from multilevel prefix and use `bfl::` prefix only.
- Define **no more than one** library function per file (I have exception for `alert` functions-satellites).
- File and function names should be in lowercase.
- Script names use camel case with a starting underscores and should match `_function_name.sh` (like [JMooring](https://github.com/jmooring/bash-function-library)).<br />
For example, if the function is named `bfl::foo`, the file name must be `_foo.sh`.
- The file must not be executable. (don't apply `chmod +x` to scripts!).
- If you create a library function named `bfl::foo`, and you need a helper function `bar` within the same file,<br />
you can:<br />
a) surround function `bfl::foo` body not by brackets, but by parentheses. After that put helper function inside `bfl::foo`.<br />
It cause the function to execute inside other bash subshell, and helper function will not be visible in global namespace.<br />
b) if you can not follow method described above, name the helper function `bfl::foo::bar` to avoid namespace collisions.

#### About function files:

- Most of functions depend on others.<br />
In order to prevent sourcing scripts more than once there is a code at evey script header (similar to [Jarodiv](https://github.com/Jarodiv/bash-function-libraries)):
```bash
[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
```
- Each function script includes description and usage information. Read headers and inline comments within the code.
- Script `autoload.sh` has header, similar to described above.<br />
Beginning of `autoload.sh` a bit differ from scripts in `lib/*`, because `autoload.sh` doesn't not present in `lib/` structure.
- Loading process in `autoload.sh` is very simple (line 136):<br />
```bash
for f in "${BASH_FUNCTION_LIBRARY%/*}"/lib/*/_*.sh; do    # $(dirname "$BASH_FUNCTION_LIBRARY")
    source "$f" || {
      [[ $BASH_INTERACTIVE == true ]] && printf "Error while loading $f\n" # > /dev/tty;
      return 1
      }
```

### bfl die discussion

**Error handling**
- I refused from using in scripts bfl::die on error (as [JMooring](https://github.com/jmooring/bash-function-library)), because I am trying to integrate `Bash Functions Library` in all system scripts.<br />
Moreover, this library is located in /etc directory (see [Usage](../../../#usage)).<br />
Scripts should not die immediately, but write log and return code error.<br />
Accordingly, using `exit 1` replaced by `write_log ...; return 1`.<br />
I accept using `exit 1` instead of `return 1` in case of code mistakes **absolute absense**.<br />
Another problem: `trap 'bfl::write_failure ... ' ERR` doesn't work correctly from `bfl::die` - exit should be called from function which is error source.

I understand idea `bfl::die`, but I refused as `Bash` terminal halts on exit 1 (I am a novice in Bash and don't know many nuances)<br />
More about `bfl::die` at [error-handling.md](error-handling.md#bfl-die)

### Naming Conventions

- Functions, constants, and variables should be lowercase. [https://unix.stackexchange.com/questions/42847/are-there-naming-conventions-for-variables-in-shell-scripts](https://unix.stackexchange.com/questions/42847/are-there-naming-conventions-for-variables-in-shell-scripts)<br />
- Global environment variables should be uppercase, with words separated by underscores.
- Global variables defined within library functions must begin with `BFL_` or `bfl_` to avoid namespace collisions.
- Local variables names use camel case starting with underscores (as [Natelandau](https://github.com/natelandau/shell-scripting-templates)).
- **Exceptions to the variable an function naming rules** are made for alerting functions and colors to ease my speed<br />
of programming. (Breaking years of habits is hard...) I.e. `notice "Some log item: ${Blue}blue text${NC}` where `notice` is<br />
a function and `$Blue`, `$Red` and `$NC` are global variables but are not in uppercase.
- I don't agree with leading underscores in variables and functions names:<br />
**variables:**<br />
Leading underscores (`_var`) often require using brackets like `"${_var}"`. Brackets don't free from quotes using.<br />
That's why I don't see reason to use brackets inside quotes and write variables names with leading underscores: `"$var"`.<br />
**functions and procedures:**<br />
To my opinion, using for function names with camel case surround by underscores: `_nameOfFunction_`, is caused to avoid names collision.<br />
But adding prefix `bfl::` before functions' names does the same. That's why i wish to refuse from leading underscores in functions' names.<br />

**BUT** Google style code and [ShellCheck](https://github.com/koalaman/shellcheck) require functions, constants, and variables to have words separated by underscores. [https://www.bashsupport.com/manual/inspections/](https://www.bashsupport.com/manual/inspections/)<br />
With minor exceptions, this library follows Google's [Shell Style Guide](https://google.github.io/styleguide/shell.xml).

### Variables

* Use double quotes instead of single quotes when it is possible: `var="foo"`.
* Use double quotes with variables when it does not conflict with code purpose: `var="foo"`.
* Use braces when referencing a constant, variable, or environment variable. (Overly verbose true and a safe practice)<br />
```bash
printf "%s" "${var}"
```
**BUT** I am trying to **NOT** overload brackets using: `"$1"`, not `"${1}"`
* Do not use braces when referring to `$@`, `$*`, `$#`, `$1`, `$2`, `$3` ... unless required to disambiguate a string.

### Coding

* Use `printf` instead of `echo`.
* Use `local` instead of `declare`. IMHO `local ` is more simple to check script.<br />
[in-bash-should-i-use-declare-instead-of-local-and-export](https://stackoverflow.com/questions/56627534/in-bash-should-i-use-declare-instead-of-local-and-export). Counter arguments for `declare` are welcome!

* Use `declare -r` instead of `readonly`, because readonly uses the default scope of global even inside functions.<br />
[https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash](https://stackoverflow.com/questions/30362831/what-is-difference-in-declare-r-and-readonly-in-bash)
* **Avoid global variables**. Use `declare -g` when creating a global variable.
* Declare and assign on the same line `declare -r foo="$1"`.
* Declare and assign on separate lines when using command substitution. Don't do this:
  `declare foo=$(whoami)`
do so:
```bash
declare foo
foo=$(whoami)
```
* If you need to use nested local functions inside other functions, use parentheses instead of braces, in order to avoid declare them in global scope:
```bash
foo() ( # !!!
  new_foo={
...
}
) # !!!
```
[https://stackoverflow.com/questions/38264873/nested-functions-on-bash](https://stackoverflow.com/questions/38264873/nested-functions-on-bash)

* All scripts and functions are fully [Shellcheck](https://github.com/koalaman/shellcheck) compliant
* Where possible, we should follow [defensive BASH programming](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/) principles.

### Indenting and Whitespace

* Indent with spaces, not tabs. My xed editor (standard for Cinnamon) follow this.<br />
Indent with 2 spaces for first indent (is provided by [shfmt](https://github.com/mvdan/sh)) and per 4 spaces for next indents.
* Remove trailing whitespace at the end of each line. My xed editor (standard for Cinnamon) does it automatically.
* Files should have Unix line endings `\n`, not Windows line endings `\r\n`.
* ~~Line length should not exceed 79 characters.~~
* ~~All files should end with a single newline `\n`~~ My xed editor (standard for Cinnamon) cuts them.

### Library Functions

#### Housekeeping Sequence

1. Verify argument count.
2. Verify dependencies.
3. Declare positional arguments (readonly, sorted by position).
4. Declare other readonly variables (sorted by name).
5. Declare all other variables (sorted by name).
6. Verify argument values.

#### File and Function Headers

Every library function must have a file header and a function header. Please review the [example function](../../../examples/_introduce.sh) for more information.

The library's documentation generator, makedoc, parses documentation tags in the file and function headers.

* File headers must include a `@file` tag.
* Function headers must include a `@function` tag.
* If a function takes arguments, it must include a `@param` tag for each argument.
* If a function takes arguments, it must include an `@example` tag.
* If a function "returns" anything, there must one or more `@return` tags.

From the [example function](../../../examples/_introduce.sh):

```bash
# Note that @return is misleading. Bash functions cannot return an arbitrary
# value. They return an exit status (0-255) where zero indicates success. To
# return an arbitrary value to the caller this library relies on command
# substitution. Each library function that "returns" a value does so by
# printing the value to stdout. The caller uses command substitution to capture
# this value.
#
# For example, to capture the "return" value of this function from a script:
#
#   introduction=$(bfl::introduce "John" "25") ||
#     bfl::die "Unable to create introduction."
#
# Note that we test the exit status of the command substitution, and in this
# case call bfl::die with an error message upon failure.
#
# If the library function "returns" a value by printing, assign the value to a
# variable, then print the variable. Reference this variable name in the
# function header's "@return" declaration.
#
# Although discouraged, if you choose to create a global variable within the
# library function:
#
#   a) Use "declare -g" syntax.
#   b) Prepend `bfl_` to the variable name to avoid namespace collisions.
#   c) Include a @return declaration in the function header. For example:
#
#   @return global string $foo
#     The foo, which can either be "bar" or "baz".
```

### Scripts template
* When create a new script that leverages this library, you may find it useful to start with the [script template](../../../templates/script).
* Please review the [examples](../../../examples/).
