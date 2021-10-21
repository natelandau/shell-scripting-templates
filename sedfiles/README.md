# Sed Files

These files are used by utility functions to perform complex operations with `sed`. If you plan on using those functions, ensure they point to these files.

The functions which use these files are:

- `_stripStopwords_`
- `_encodeHTML_`
- `_decodeHTML_`

## Installation

To use these files without needing to edit their location within the utility functions themselves, follow these steps in your terminal at the root level of this repository:

```bash
mkdir "${HOME}/.sed"
ln -s "$(git rev-parse --show-toplevel)/sedfiles/stopwords.sed" "${HOME}/.sed/stopwords.sed"
ln -s "$(git rev-parse --show-toplevel)/sedfiles/stopwords.sed" "${HOME}/.sed/htmlEncode.sed"
ln -s "$(git rev-parse --show-toplevel)/sedfiles/stopwords.sed" "${HOME}/.sed/htmlDecode.sed"
```
