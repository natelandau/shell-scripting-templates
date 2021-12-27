# Functions for use on computers running MacOS

_haveScriptableFinder_() {
    # DESC:
    #         Determine whether we can script the Finder or not
    # ARGS:
    #         None
    # OUTS:
    #         0 if we can script the Finder
    #         1 if not

    local _finder_pid
    _finder_pid="$(pgrep -f /System/Library/CoreServices/Finder.app | head -n 1)"

    if [[ (${_finder_pid} -gt 1) && (${STY-} == "") ]]; then
        return 0
    else
        return 1
    fi
}

_guiInput_() {
    # DESC:
    #         Ask for user input using a Mac dialog box
    # ARGS:
    #         $1 (Optional) - Text in dialogue box (Default: Password)
    # OUTS:
    #         MacOS dialog box output
    #         1 if no output
    # CREDIT
    #         https://github.com/herrbischoff/awesome-osx-command-line/blob/master/functions.md
    if _haveScriptableFinder_; then
        local _guiPrompt="${1:-Password:}"
        local _guiInput
        _guiInput=$(
            osascript &>/dev/null <<GUI_INPUT_MESSAGE
      tell application "System Events"
          activate
          text returned of (display dialog "${_guiPrompt}" default answer "" with hidden answer)
      end tell
GUI_INPUT_MESSAGE
        )
        printf "%s\n" "${_guiInput}"
    else
        error "No GUI input without macOS"
        return 1
    fi

}

_useGNUutils_() {
    # DESC:
    #					Add GNU utilities to PATH to allow consistent use of sed/grep/tar/etc. on MacOS
    # ARGS:
    #					None
    # OUTS:
    #					0 if successful
    #         1 if unsuccessful
    #         PATH: Adds GNU utilities to the path
    # USAGE:
    #					# if ! _useGNUUtils_; then exit 1; fi
    # NOTES:
    #					GNU utilities can be added to MacOS using Homebrew

    ! declare -f "_setPATH_" &>/dev/null && fatal "${FUNCNAME[0]} needs function _setPATH_"

    if _setPATH_ \
        "/usr/local/opt/gnu-tar/libexec/gnubin" \
        "/usr/local/opt/coreutils/libexec/gnubin" \
        "/usr/local/opt/gnu-sed/libexec/gnubin" \
        "/usr/local/opt/grep/libexec/gnubin" \
        "/usr/local/opt/findutils/libexec/gnubin" \
        "/opt/homebrew/opt/findutils/libexec/gnubin" \
        "/opt/homebrew/opt/gnu-sed/libexec/gnubin" \
        "/opt/homebrew/opt/grep/libexec/gnubin" \
        "/opt/homebrew/opt/coreutils/libexec/gnubin" \
        "/opt/homebrew/opt/gnu-tar/libexec/gnubin"; then
        return 0
    else
        return 1
    fi

}

_homebrewPath_() {
    # DESC:
    #					Add homebrew bin dir to PATH
    # ARGS:
    #					None
    # OUTS:
    #					0 if successful
    #         1 if unsuccessful
    #         PATH: Adds homebrew bin directory to PATH
    # USAGE:
    #					# if ! _homebrewPath_; then exit 1; fi

    ! declare -f "_setPATH_" &>/dev/null && fatal "${FUNCNAME[0]} needs function _setPATH_"

    if _uname=$(command -v uname); then
        if "${_uname}" | tr '[:upper:]' '[:lower:]' | grep -q 'darwin'; then
            if _setPATH_ "/usr/local/bin" "/opt/homebrew/bin"; then
                return 0
            else
                return 1
            fi
        fi
    else
        if _setPATH_ "/usr/local/bin" "/opt/homebrew/bin"; then
            return 0
        else
            return 1
        fi
    fi
}
