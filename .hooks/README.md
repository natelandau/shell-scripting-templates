This folder contains a git pre-commit script which will be executed on the client side before files are committed to the repository. This script provides automated linting and testing of multiple file types.

## Usage

To install the hook, create a symlink into the `/path/to/repo/.git/hooks` directory.

```bash
ln -s "$(git rev-parse --show-toplevel)/.hooks/pre-commit.sh" "$(git rev-parse --show-toplevel)/.git/hooks/pre-commit"
```
