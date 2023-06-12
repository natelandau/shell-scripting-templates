[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / [Installation](installation.md) / Description / [Coding](coding-standards.md) / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Description

### Color Output

Library functions such as `bfl::die` and `bfl::warn` produce color output via
ANSI escape sequences. For example, `bfl::die` prints error messages in red,
while `bfl::warn` prints warning messages in yellow.

Instead of hardcoding ANSI escape sequences to produce color output, the
`bfl::declare_ansi_escape_sequences` library function defines global variables
for common color and formatting cases. This function is called when the Bash
Function Library is initially sourced.

The documentation contains a [complete
list](docs/function-list.md#bfl_declare_ansi_escape_sequences) of the defined
ANSI escape sequence variables.

Each of the following examples prints the word "foo" in yellow:

```bash
echo -e "${bfl_aes_yellow}foo${bfl_aes_reset}"
printf "${bfl_aes_yellow}%s${bfl_aes_reset}\\n" "foo"
printf "%b\\n" "${bfl_aes_yellow}foo${bfl_aes_reset}"
```

In some cases it may be desirable to disable color output. For example, let's
say you've written a script leveraging this library. When you run the script in
a terminal, you'd like to see the error messages in color. However, when run as
a cron job, you don't want to see the ANSI escape sequences surrounding error
messages when viewing logs or emails sent by cron.

To disable color output, set the BASH_FUNCTION_LIBRARY_COLOR_OUTPUT environment
variable to "disabled" before sourcing the autoloader. For example:

```bash
export BASH_FUNCTION_LIBRARY_COLOR_OUTPUT=disabled
if ! source "${BASH_FUNCTION_LIBRARY}"; then
  printf "Error. Unable to source BASH_FUNCTION_LIBRARY.\\n" 1>&2
  exit 1
fi
```
