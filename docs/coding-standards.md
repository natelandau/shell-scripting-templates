# Bash Function Library

## Coding Standards

### Getting Started

* When creating a new function for this library, please start with the
  [function template](../templates/_library_function.sh).
* When create a new script that leverages this library, you may find it useful
  to start with the [script template](../templates/script).
* Please review the [examples](../examples/).

With minor exceptions, this library follows Google's [Shell Style
Guide](https://google.github.io/styleguide/shell.xml).

### Indenting and Whitespace

* Line length should not exceed 79 characters.
* Indent with 2 spaces, not tabs.
* Remove trailing whitespace at the end of each line.
* Files should have Unix line endings `\n`, not Windows line endings `\r\n`.
* All files should end with a single newline `\n`.

### Naming Conventions

* Functions, constants, and variables should be lowercase, with words separated
  by underscores.
* Environment variables should be uppercase, with words separated by
  underscores.

### Syntax

* Use double quotes instead of single quotes when possible.  
  `var="foo"`
* Use braces when referencing a constant, variable, or environment variable.  
  `printf "%s" "${var}"`
* Do not use braces when referring to `$@`, `$*`, `$#`, `$1`, `$2`, `$3`, etc.
  unless required to disambiguate a string.

### Other

* Use `printf` instead of `echo`.
* Use `declare` instead of `local`.
* Use `declare -r` instead of `readonly`.
* Use `declare -g` when creating a global variable. Don't create global variables.
* Declare and assign literals on same line.  
  `declare -r foo="$1"`
* Declare and assign literals on separate lines when using command
  substitution. Don't do this:  
  `declare foo=$(whoami)`

### Library Functions

#### General

* Library function names must begin with `bfl::` to avoid namespace collisions.
* The file name must begin with an underscore.
* The file name must end with `.sh`.
* The file name must match the function name. For example, if the function is
  named `bfl::foo`, the file name must be `_foo.sh`.
* The file must not be executable.
* Define no more than one library function per file.
* If you create a library function named `bfl::foo`, and you need a helper
  function `bar` within the same file, name the helper function `bfl::foo::bar`
  to avoid naming collisions.
* Global variables defined within library functions must begin with `bfl_` to
  avoid namespace collisions.

#### Housekeeping Sequence

1. Verify argument count.
2. Verify dependencies.
3. Declare positional arguments (readonly, sorted by position).
4. Declare other readonly variables (sorted by name).
5. Declare all other variables (sorted by name).
6. Verify argument values.

#### File and Function Headers

Every library function must have a file header and a function header. Please
review the [example function](../examples/_introduce.sh) for more information.

The library's documentation generator, makedoc, parses documentation tags in
the file and function headers.

* File headers must include a `@file` tag.
* Function headers must include a `@function` tag.
* If a function takes arguments, it must include a `@param` tag for each
  argument.
* If a function takes arguments, it must include an `@example` tag.
* If a function "returns" anything, there must one or more `@return` tags.

From the [example function](../examples/_introduce.sh):

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
#   introduction=$(bfl::introduce "John" "25") \
#     || bfl::die "Unable to create introduction."
#
# Note that we test the exit status of the command substitution, and in this
# case call bfl::die with an error message upon failure.
#
# If the library function "returns" a value by printing, assign the value to a
# variable, then print the variable. Reference this variable name in the
# function header's "@return" declaration.
#
# Although global variables are discouraged, if you choose to create a global
# variable within this function:
#
#   a) Use "declare -g foo" syntax.
#   b) Include a @return declaration in the function header. For example:
#
#   @return global string $foo
#     The foo, which can either be "bar" or "baz".
```
