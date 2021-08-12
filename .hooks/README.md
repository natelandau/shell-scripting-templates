This folder contains git hooks which will be executed on the client side before certain git actions are completed.

## Usage
On each local system these files must be symlinked into `repo/.git/hooks` directory.

```bash
ln -s "$(git rev-parse --show-toplevel)/.hooks/pre-commit.sh" "$(git rev-parse --show-toplevel)/.git/hooks/pre-commit"
```
