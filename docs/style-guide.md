# Bash Function Library

## Style Guide


One function per file.
If you need helper functions, namespace them. For example, if the new library
function is bfl::foo, and you need to create a helper function to bar, the
helper function must be named bfl::foo:bar.


1. File Header

Foo.

2. ddd

1. The line after @function must describe what the function does in 

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
