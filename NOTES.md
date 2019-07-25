# Notes

## Error Handling

### Guidelines

1\) The lib::die function calls exit 1.

2\) Library functions must call lib::die on error, including an error message. For example:

```bash
lib::foo () {
  if [[ "$#" -ne "1" ]]; then
    lib::die "Error: an argument was not supplied."
  fi
}
```

Exception: validate_arg_count will _return_ 1 instead of _exit_ 1 on error.

- When writing a _script_, if validate_arg_count fails, display the usage
  message. For example:  
  ```lib::validate_arg_count "$#" 1 3 || usage```

- When writing a _library function_, if validate_arg_count fails, exit. For example:  
  ```lib::validate_arg_count "$#" 1 3 || exit 1```

3\) There is no need to test the exit status when calling a library function
directly; library functions call lib::die upon error. For example:

```bash
lib::foo "bar"
```

Exception: validate_arg_count. See #2 above.

4\) Always test the exit status when performing command substitution. For example:

```bash
var=$(lib::foo "bar") || lib::die
var=$(pwd) || lib::die
```

5\) Logical library functions

Logical library functions such as lib::is_empty and lib::is_integer have an
exit status of 0 if true, 1 if false.

### Background

Define a function within a script:

```bash
my_function() {
  exit 1
}
```

Now call the function directly:

```bash
my_function
```

The script will exit.

Now, instead of calling the function directly, use command substitution:

```bash
var=$(my_function)
```

In this case the script will *not* exit because command substitution occurs in
a subshell. The subshell exits, not the shell or script that invoked it.

### Lazy Man's Approach

You can configure a shell or script to exit if a command exits with a non-zero status:

```bash
set -e
```

In this configuration, the shell or script that invokes command substitution will exit when the subshell exits.

This is a simpler approach; you do not need to check the exit code when using
command substitution. But **everything can break** if you remove ```set -e```.

Use both approaches, in case you forget to test the exit code from command substitution.

## Style Guide for Functions

1\) Parameter (@param) descriptions must reference variable names as declared in the function. Do not use $1, $2, $3, etc.

2\) Return (@return) descriptions must reference:

- Global variables created or updated by the function
- The variable that is output by the final printf or echo statement, if any. See notes 6 and 7.

3\) Declaration sequence:

- Arguments sorted by position ($1, $2, etc.)
- All arguments ($@)
- Argument count ($#)
- Global variables created or updated (sorted alphabetically)
- Other local variables (sorted alphabetically)

4\) Declare using 'declare' instead of 'local' or 'readonly'.

5\) Declare and assign literals on same line. If assigning to command output, declare on one line and assign on the next.

6\) If the function returns a value via command substitution, assign the output to a variable, then printf the variable.

7\) Generally prefer printf to echo.

8\) Do not use braces when referring to $@, $*, $#, $1, $2, $3, etc. unless
required to disambiguate a string.
