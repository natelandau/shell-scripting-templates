This folder contains git hook scripts which will be executed on the client side before/after certain git actions are completed.

## Usage
To install these hooks, create a symlink to `/path/to/repo/.git/hooks` directory.


```bash
ln -s "$(git rev-parse --show-toplevel)/.hooks/pre-commit.sh" "$(git rev-parse --show-toplevel)/.git/hooks/pre-commit"
```
