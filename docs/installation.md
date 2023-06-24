[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / Installation / [Description](description.md) / [Coding](coding-standards.md) / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Installation

1\. Clone this repository into `${HOME}/.lib/bfl`.

```bash
git clone git@github.com:/jmooring/bash-function-library.git "${HOME}/.lib/bfl"
or
git clone git@github.com:/AlexeiKharchev/bash-function-library.git "${HOME}/.lib/bfl"
```

2\. Create a permanent environment variable containing the path to the autoloader.

```bash
heredoc=$(cat<<EOT
set -o allexport  # == set -a Enable using full option name syntax
# -------------------------------------------------------------------
readonly BASH_FUNCTION_LIBRARY='/etc/bash_functions_library/autoload.sh'
# -------------------------------------------------------------------
set +o allexport  # == set +a Disable using full option name syntax
EOT
)
sudo printf "\\n%s\\n" "${heredoc}" >> ${HOME}/getConsts

sed -i '2iset +u' "${HOME}/.bashrc"
sed -i '3i[[ $_GUARD_BFL_autoload -ne 1 ]] && . ${HOME}/getConsts && . "$BASH_FUNCTION_LIBRARY"' "${HOME}/.bashrc"
```

3\. Verify that the BASH_FUNCTION_LIBRARY environment variable is correct.

Open new terminal (Ctrl + Shift + T) and type:
```bash
echo "$BASH_FUNCTION_LIBRARY"
```

4\. Test using the `bfl::repeat` library function.

```bash
[[ $_GUARD_BFL_autoload -eq 1 ]] && printf "%s\\n" "$(bfl::repeat "=" "40")" || printf "Error. Unable to load BASH_FUNCTION_LIBRARY.\\n" 1>&2
```

I load these functions in my own shell environment.
If they're useful for anyone else, then great! :)
