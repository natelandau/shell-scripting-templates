# Functions for use on computers running MacOS

_haveScriptableFinder_() {
  # DESC:   Determine whether we can script the Finder or not
  # ARGS:   None
  # OUTS:   true/false

  local finder_pid
  finder_pid="$(pgrep -f /System/Library/CoreServices/Finder.app | head -n 1)"

  if [[ (${finder_pid} -gt 1) && ("${STY-}" == "") ]]; then
    return 0
  else
    return 1
  fi
}

_guiInput_() {
  # DESC:   Ask for user input using a Mac dialog box
  # ARGS:   $1 (Optional) - Text in dialogue box (Default: Password)
  # OUTS:   None
  # NOTE:   https://github.com/herrbischoff/awesome-osx-command-line/blob/master/functions.md
  if _haveScriptableFinder_; then
    guiPrompt="${1:-Password:}"
    guiInput=$(
      osascript &>/dev/null <<EOF
      tell application "System Events"
          activate
          text returned of (display dialog "${guiPrompt}" default answer "" with hidden answer)
      end tell
EOF
  )
    echo -n "${guiInput}"
  else
    error "No GUI input without macOS"
    return 1
  fi

}