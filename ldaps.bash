#! /dev/null/bash

function ldaps ()
{ ldapsearch "${@}" | awk 'BEGIN{NLN=""};{if(sub(/^[[:blank:]]/,"")){printf($0)}else{printf("%s%s",NLN,$0);NLN="\n"}};END{printf("\n")}'; }
