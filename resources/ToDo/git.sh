#! /dev/null/bash

function gitp () { git pull "${@}"; }

function gitP () { git push "${@}"; }

function gita () { git add "${@}"; }

function gitd () { git diff "${@}"; }

function gits () { git status -sb "${@}"; }

function gitc () { git commit "${@}"; }

function git_remote_add_origin_push ()
  {
  git remote add origin "${1}"
  git push -u origin master
  }
