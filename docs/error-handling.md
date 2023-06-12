# Bash Function Library

## Error Handling

[BFL die](#bfl-die) / [Verify arguments count](#verify-arguments-count) / [Guidelines](#guidelines)  / [Exit with Command Substitution](#exit-with-command-substitution)

### BFL die

The `bfl::die` function calls `exit 1`.<br />
If the chain of commands leading to `bfl::die` is direct (no command substitution), the parent script exits when `bfl::die` fires.<br />
If command substitution occurs **anywhere** in the chain of commands leading to `bfl::die`, the parent script will **not** exit because
command substitution spawns a subshell.<br />
See [Exit with Command Substitution](#exit-with-command-substitution) for a detailed explanation.<br />
Upon error, all library functions except `bfl::verify_arg_count` call `bfl::die` with an error message.<br />
For example:
```bash
bfl::foo () {
  if [[ ! -f "${file}" ]]; then
    bfl::die "${file} does not exist."
  fi
}
```

### Verify arguments count

The `bfl::verify_arg_count` function **does not** call `bfl::die` on error.<br />
Instead, `bfl::verify_arg_count` calls `return 1` upon error.<br />
This exception allows the parent script to call a usage function when the argument count is incorrect.<br />
For example:
```bash
bfl::verify_arg_count "$#" 1 3 || { usage; exit 1; }
```

### Guidelines

1\) Within the `main()` function of a script, if `bfl::verify_arg_count` fails, display the usage message.<br />
For example:
```bash
bfl::verify_arg_count "$#" 1 3 || { usage; exit 1; }
```

2\) Within any other function, if `bfl::verify_arg_count` fails, exit 1.<br />
For example:
```bash
bfl::verify_arg_count "$#" 1 3 || exit 1
```

Although you could call `bfl::die "foo"` instead of `exit 1`, it would have the same result but with a second error message.<br />
Either way is fine, but prefer the former.

3\) Except for `bfl::verify_arg_count` there is no need to test the exit status when calling a library function directly&mdash;library<br />
functions call bfl::die upon error. For example:
```bash
bfl::foo "bar"
```

3\) Always test the exit status when performing command substitution.<br />
For example:
```bash
var=$(bfl::foo "bar") || bfl::die "Unable to foo the bar."
var=$(pwd) || bfl::die "Unable to determine working directory."
```

4\) Logical library functions such as `bfl::is_empty` and `bfl::is_integer` have an exit status of 0 if true, 1 if false.<br />
By definition you will always test the exit status, either explicitly or implicitly, when using logical library functions.<br />
For example:
```bash
if bfl::is_integer "${foo}"; then
  printf "%s is an integer.\\n" "${foo}"
else
  printf "%s is not an integer.\\n" "${foo}"
fi

bfl::is_empty "${bar}" && printf "\${bar} is empty.\\n" "${bar}"
```

### Exit with Command Substitution

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
The script will exit.<br />
Now, instead of calling the function directly, use command substitution:
```bash
var=$(my_function)
```
In this case the script will *not* exit because command substitution occurs in a subshell.<br />
The subshell exits, not the shell or script that invoked it. There are two ways to address this:

1\) Test the exit status of command substitution. For example:

```bash
var=$(bfl::trim "${foo}") || exit 1
```

2\) Configure the shell or script to exit if any command exits with a non-zero status with `set -e`.<br />
In this configuration, the shell or script that invokes command substitution will exit when the subshell exits.

Recommendation: code defensively by testing the exit status of all but the most trivial commands, and invoke<br />
`set -euo pipefail` at the beginning of the script. While we don't want to rely on `set -e`, it may catch items we miss.

Do both&mdash;take no chances!
