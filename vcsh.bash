#! /dev/null/bash

function vcsh_untracked ()
{
    {
        printf '/%s\n' \
                .DS_Store .Trash .cache .local .opt .rnd Applications Desktop Documents Downloads Library Maildirs Movies Music Pictures Public
        vcsh list-tracked |
            sed "s=^${HOME}\(/[^/]*\).*=\1=" |
            sort -u
    } > "${XDG_CONFIG_HOME:-${HOME}/.config}/vcsh/ignore.d/vcsh-untracked"
    vcsh run vcsh-untracked git status -sb
}
