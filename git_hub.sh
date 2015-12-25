#! /dev/null/bash

function git_hub_init ()
{
    export GIT_HUB_CONFIG=~/.git-hub/config.d/github.com.config
}

function git_hub_unwatch_rkr_forks ()
{
    declare watching
    watching="$(
        git-hub watching |
        sed -n 's/^[0-9]*) //p'
    )"
    for repo in $(
        echo "${watching}" |
        egrep "/$(
            echo "${watching}" |
            egrep '^(racker|rackerlabs)/' |
            cut -d/ -f2 |
            sort -u |
            paste -sd'|' -
        )\$" |
        egrep -v '^(racker|rackerlabs)/'
    )
    do
        git-hub unwatch "${repo}"
    done
}

function git_hub_add_upstream ()
{
    declare repo repo_up repo_up_url
    repo="${PWD#*/Source/*/}"
    repo="${repo%.git}"
    repo_up="$( git hub repo-get "${repo}" source/full_name )"
    repo_up_url="$( git hub repo-get "${repo_up}" ssh_url )"
    [[ -n "${repo_up_url}" ]] || return 1
    declare -p repo repo_up repo_up_url
    git remote add upstream "${repo_up_url}"
    git remote -v
}

function git_hub_upstream_fetch_merge ()
{
    git remote -v
    git fetch upstream
    git merge upstream/master master
}
