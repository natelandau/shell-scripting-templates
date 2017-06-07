#! /dev/null/bash

ldaps() {
    #
    ## lsaps - Unwrap ldif output
    #
    ldapsearch "$@" \
    | awk '(!sub(/^[[:blank:]]/,"")&&FNR!=1){printf("\n")};{printf("%s",$0)};END{printf("\n")}'
    #
}
