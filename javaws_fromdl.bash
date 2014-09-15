#! /dev/null/bash

function javaws_fromdl ()
{

    #
    # Find lastest java web app file in downloads and run it.
    #

    find ~/Downloads/. -type f -name "*.jnlp*" -mmin -5 -print0 |
        xargs -0 ls -1rt |
        tail -1 |
        xargs -tI@ javaws -verbose -wait "@"

}
