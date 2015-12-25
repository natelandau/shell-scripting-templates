#! /dev/null/bash

function find_broken_symlinks ()
{
    find -L "${@:-.}" -type l -exec ls -lond '{}' \;
}
