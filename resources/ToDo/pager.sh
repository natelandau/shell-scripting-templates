#! /dev/null/bash

function pager () { [[ -t 1 ]] && ${PAGER:-less -isR} || cat -; }
