#function brew ()
#{
#
#    #
#    # Clean run of Homebrew
#    #
#
#    # Obtain Homebrew prefix.
#    declare prefix="$( command brew --prefix )"
#
#    # Only change PATHs for this function and any sub-procs
#    declare -x PATH MANPATH
#
#    # Reset PATHs
#    eval "$( PATH= MANPATH= /usr/libexec/path_helper -s )"
#
#    # Add Homebrew PATHs
#    PATH="${prefix}/bin:${prefix}/sbin:${PATH}"
#    MANPATH="${prefix}/man:${MANPATH}"
#
#    # Run Homebrew
#    hash -r
#    command brew "${@}"
#
#}

# brew install
function brewI() { brew_actioner "${@}"; }

# brew uninstall
function brewU() { brew_actioner "${@}"; }

# brew update
function brewu() { brew_actioner "${@}"; }

# brew upgrade
function brewUp() { brew_actioner "${@}"; }

# brew uninstall/install (actual-reinstall)
function brewR() { brew_actioner "${@}"; }

# brew home
function brewh() { brew_actioner "${@}"; }

# brew search
function brews() { brew_actioner "${@}"; }

# brew list
function brewl() { brew_actioner "${@}"; }

# brew info
function brewi() { brew_actioner "${@}"; }
