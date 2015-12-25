#! /dev/null/bash

function javaws_fromdl ()
{

    #
    # Find lastest java web app file in downloads and run it.
    #

    declare tmp

    tmp="$( find ~/Downloads/. -type f -name "*.jnlp*" -mmin -5 -print0 | xargs -0 ls -1rUd )"

    declare -p tmp
   
    echo "${tmp}" |
        sed -n '$p' |
        xargs -tI@ javaws -verbose -wait "@"

}
