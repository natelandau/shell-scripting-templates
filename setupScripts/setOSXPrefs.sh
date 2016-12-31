#!/usr/bin/env bash

# ##################################################
#
version="1.0.0"              # Sets version variable
#
# ##################################################

function mainScript() {
  header  "Beginning script to set OSX preferences"
  info "This script runs a series of commands to pre-configure OSX."

  function setComputerName() {
    seek_confirmation "Would you like to set your computer name (as done via System Preferences >> Sharing)?"
    if is_confirmed; then
      input "What would you like the name to be?"
      read COMPUTER_NAME
      sudo scutil --set ComputerName "$COMPUTER_NAME"
      sudo scutil --set HostName "$COMPUTER_NAME"
      sudo scutil --set LocalHostName "$COMPUTER_NAME"
      sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
    fi
  }

  function generalUITPrefs() {
    seek_confirmation "Run General UI Tweaks?"
    if is_confirmed; then

      success "Disabled Sound Effects on Boot"
      sudo nvram SystemAudioVolume=" "

      success "Hide the Time Machine, Volume, User, and Bluetooth icons"
        # Get the system Hardware UUID and use it for the next menubar stuff
        for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
            defaults write "${domain}" dontAutoLoad -array \
          "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
          "/System/Library/CoreServices/Menu Extras/Volume.menu" \
          "/System/Library/CoreServices/Menu Extras/User.menu"
        done

        defaults write com.apple.systemuiserver menuExtras -array \
          "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
          "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
          "/System/Library/CoreServices/Menu Extras/Battery.menu" \
          "/System/Library/CoreServices/Menu Extras/Clock.menu"

      success "Set highlight color to yellow"
      defaults write NSGlobalDomain AppleHighlightColor -string '0.984300 0.929400 0.450900'

      success "Set sidebar icon size to small"
      defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
      # Possible values for int: 1=small, 2=medium

      success "Always show scrollbars"
      defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
      # Possible values: `WhenScrolling`, `Automatic` and `Always`

      #success "Disable transparency in the menu bar and elsewhere on Yosemite"
      #defaults write com.apple.universalaccess reduceTransparency -bool true

      success "Disable opening and closing window animations"
      defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

      success "Expand save panel by default"
      defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
      defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

      success "Expand print panel by default"
      defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
      defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

      success "Save to disk (not to iCloud) by default"
      defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

      success "Automatically quit printer app once the print jobs complete"
      defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

      success "Disable the 'Are you sure you want to open this application?' dialog"
      defaults write com.apple.LaunchServices LSQuarantine -bool false

      success "General:Display ASCII control characters using caret notation in standard text views"
      # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
      defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

      success "Disable automatic termination of inactive apps"
      defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

      success "Disable Resume system-wide"
      defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

      success "Set Help Viewer windows to non-floating mode"
      defaults write com.apple.helpviewer DevMode -bool true

      success "Reveal info when clicking the clock in the login window"
      sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

      #success "Restart automatically if the computer freezes"
      #systemsetup -setrestartfreeze on

      #success "Never go into computer sleep mode"
      #systemsetup -setcomputersleep Off > /dev/null

      success "Check for software updates daily, not just once per week"
      defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

      #success "Disable Notification Center and remove the menu bar icon"
      #launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

      success "Disabled smart quotes as they are annoying when typing code"
      defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

      success "Disabled smart dashes as they are annoying when typing code"
      defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

      success "Removing duplicates in the 'Open With' menu"
      #/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

      #success "Disable hibernation? (speeds up entering sleep mode)"
      #sudo pmset -a hibernatemode 0

    fi
  }

  function inputDevicePrefs() {
    seek_confirmation "Run Trackpad, Mouse, Keyboard Tweaks?"
    if is_confirmed; then

      #success "Trackpad: enable tap to click for this user and for the login screen"
      #defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
      #defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
      #defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

      # success "Trackpad: map bottom right corner to right-click"
      # defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
      # defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
      # defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
      # defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

      # success "Disable “natural” (Lion-style) scrolling"
      # defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

      success "Setting trackpad & mouse speed to a reasonable number"
      defaults write -g com.apple.trackpad.scaling 2
      defaults write -g com.apple.mouse.scaling 2.5

      success "Increase sound quality for Bluetooth headphones/headsets"
      defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

      success "Enable full keyboard access for all controls"
      # (e.g. enable Tab in modal dialogs)
      defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

      success "Use scroll gesture with the Ctrl (^) modifier key to zoom"
      defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
      defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
      # Follow the keyboard focus while zoomed in
      defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

      success "Disable press-and-hold for keys in favor of key repeat"
      defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

      success "Set a blazingly fast keyboard repeat rate"
      defaults write NSGlobalDomain KeyRepeat -int 0.02

      success "Automatically illuminate built-in MacBook keyboard in low light"
      defaults write com.apple.BezelServices kDim -bool true

      success "Turn off keyboard illumination when computer is not used for 5 minutes"
      defaults write com.apple.BezelServices kDimTime -int 300

      success "Set language and text formats"
      # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
      # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
      defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
      defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
      defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
      defaults write NSGlobalDomain AppleMetricUnits -bool false

      success "Set the timezone"
      systemsetup -settimezone "America/New_York" > /dev/null
      #see `systemsetup -listtimezones` for other values

      #success "Disable spelling auto-correct"
      #defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

      # Stop iTunes from responding to the keyboard media keys
      #launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
    fi
  }

  function screenPrefs() {
    seek_confirmation "Run Screen Configurations?"
    if is_confirmed; then
      success "Require password immediately after sleep or screen saver begins"
      defaults write com.apple.screensaver askForPassword -int 1
      defaults write com.apple.screensaver askForPasswordDelay -int 0

      success "Save screenshots to the desktop"
      defaults write com.apple.screencapture location -string "${HOME}/Desktop"

      success "Save screenshots in PNG format"
      defaults write com.apple.screencapture type -string "png"
      # other options: BMP, GIF, JPG, PDF, TIFF, PNG

      #success "Disable shadow in screenshots"
      #defaults write com.apple.screencapture disable-shadow -bool true

      success "Enable subpixel font rendering on non-Apple LCDs"
      defaults write NSGlobalDomain AppleFontSmoothing -int 2

      #success "Enabling HiDPI display modes (requires restart)"
      #sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    fi
  }

  function finderPrefs() {
    seek_confirmation "Run Finder Tweaks?"
    if is_confirmed; then
      success "Finder: allow quitting via ⌘ + Q"
      defaults write com.apple.finder QuitMenuItem -bool true

      success "Finder: disable window animations and Get Info animations"
      defaults write com.apple.finder DisableAllAnimations -bool true

      success "Set Home Folder as the default location for new Finder windows"
      # For other paths, use `PfLo` and `file:///full/path/here/`
      defaults write com.apple.finder NewWindowTarget -string "PfHm"
      defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

      success "Show icons for hard drives, servers, and removable media on the desktop"
      defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
      defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
      defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
      defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

      #success "Finder: show hidden files by default"
      #defaults write com.apple.finder AppleShowAllFiles -bool true

      success "Finder: show all filename extensions"
      defaults write NSGlobalDomain AppleShowAllExtensions -bool true

      success "Finder: show status bar"
      defaults write com.apple.finder ShowStatusBar -bool true

      success "Finder: show path bar"
      defaults write com.apple.finder ShowPathbar -bool true

      success "Finder: allow text selection in Quick Look"
      defaults write com.apple.finder QLEnableTextSelection -bool true

      #success "Display full POSIX path as Finder window title"
      #defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

      success "When performing a search, search the current folder by default"
      defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

      success "Disable the warning when changing a file extension"
      defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

      success "Enable spring loading for directories"
      defaults write NSGlobalDomain com.apple.springing.enabled -bool true

      success "Remove the spring loading delay for directories"
      defaults write NSGlobalDomain com.apple.springing.delay -float 0

      success "Avoid creating .DS_Store files on network volumes"
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
      defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

      success "Disable disk image verification"
      defaults write com.apple.frameworks.diskimages skip-verify -bool true
      defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
      defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

      # success "Automatically open a new Finder window when a volume is mounted"
      # defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
      # defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
      # defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

      success "Show item info to the right of the icons on the desktop"
      /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

      success "Enable snap-to-grid for icons on the desktop and in other icon views"
      /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
      /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

      success "Increase grid spacing for icons on the desktop and in other icon views"
      /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
      /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

      success "Increase the size of icons on the desktop and in other icon views"
      /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:iconSize 40" ~/Library/Preferences/com.apple.finder.plist
      /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:iconSize 40" ~/Library/Preferences/com.apple.finder.plist

      success "Use column view in all Finder windows by default"
      defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
      # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`

      success "Disable the warning before emptying the Trash"
      defaults write com.apple.finder WarnOnEmptyTrash -bool false

      # success "Empty Trash securely by default"
      # defaults write com.apple.finder EmptyTrashSecurely -bool true

      success "Show the ~/Library folder"
      chflags nohidden ${HOME}/Library

      success "Show the /Volumes folder"
      sudo chflags nohidden /Volumes

      #success "Remove Dropbox’s green checkmark icons in Finder"
      #file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
      #[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

      success "Expand File Info panes"
      # “General”, “Open with”, and “Sharing & Permissions”
      defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

      # Enable AirDrop over Ethernet and on unsupported Macs running Lion
      # defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
    fi
  }

  function dockDashPrefs() {
    seek_confirmation "Configure Dock, Dashboard, Corners?"
    if is_confirmed; then

      success "Enable highlight hover effect for the grid view of a stack"
      defaults write com.apple.dock mouse-over-hilite-stack -bool true

      success "Change minimize/maximize window effect"
      defaults write com.apple.dock mineffect -string "genie"

      success "Set the icon size of Dock items to 36 pixels"
      defaults write com.apple.dock tilesize -int 36

      success "Show only open applications in the Dock"
      defaults write com.apple.dock static-only -bool true

      success "Minimize windows into their application’s icon"
      defaults write com.apple.dock minimize-to-application -bool true

      success "Enable spring loading for all Dock items"
      defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

      success "Show indicator lights for open applications in the Dock"
      defaults write com.apple.dock show-process-indicators -bool true

      success "Wipe all (default) app icons from the Dock"
      # This is only really useful when setting up a new Mac, or if you don’t use
      # the Dock to launch apps.
      defaults write com.apple.dock persistent-apps -array

      success "Disable App Persistence (re-opening apps on login)"
      defaults write -g ApplePersistence -bool no

      success "Don’t animate opening applications from the Dock"
      defaults write com.apple.dock launchanim -bool false

      success "Speed up Mission Control animations"
      defaults write com.apple.dock expose-animation-duration -float 0.1

      # success "Don’t group windows by application in Mission Control"
      # # (i.e. use the old Exposé behavior instead)
      # defaults write com.apple.dock expose-group-by-app -bool false

      success "Disable Dashboard"
      defaults write com.apple.dashboard mcx-disabled -bool true

      success "Don’t show Dashboard as a Space"
      defaults write com.apple.dock dashboard-in-overlay -bool true

      # success "Don’t automatically rearrange Spaces based on most recent use"
      # defaults write com.apple.dock mru-spaces -bool false

      success "Remove the auto-hiding Dock delay"
      defaults write com.apple.dock autohide-delay -float 0

      #success "Remove the animation when hiding/showing the Dock"
      #defaults write com.apple.dock autohide-time-modifier -float 0

      success "Automatically hide and show the Dock"
      defaults write com.apple.dock autohide -bool true

      success "Make Dock icons of hidden applications translucent"
      defaults write com.apple.dock showhidden -bool true


      # Add a spacer to the left side of the Dock (where the applications are)
      #defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
      # Add a spacer to the right side of the Dock (where the Trash is)
      #defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

      success "Disabled hot corners"
      # Possible values:
      #  0: no-op
      #  2: Mission Control
      #  3: Show application windows
      #  4: Desktop
      #  5: Start screen saver
      #  6: Disable screen saver
      #  7: Dashboard
      # 10: Put display to sleep
      # 11: Launchpad
      # 12: Notification Center
      # Top left screen corner → Mission Control
      defaults write com.apple.dock wvous-tl-corner -int 0
      defaults write com.apple.dock wvous-tl-modifier -int 0
      # Top right screen corner → Desktop
      defaults write com.apple.dock wvous-tr-corner -int 0
      defaults write com.apple.dock wvous-tr-modifier -int 0
      # Bottom left screen corner → Start screen saver
      defaults write com.apple.dock wvous-bl-corner -int 0
      defaults write com.apple.dock wvous-bl-modifier -int 0
    fi
  }

  function safariPrefs() {
    seek_confirmation "Safari & Webkit tweaks?"
    if is_confirmed; then

      success "Privacy: don’t send search queries to Apple"
      defaults write com.apple.Safari UniversalSearchEnabled -bool false
      defaults write com.apple.Safari SuppressSearchSuggestions -bool true

      success "Show the full URL in the address bar (note: this still hides the scheme)"
      defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

      success "Set Safari’s home page to about:blank for faster loading"
      defaults write com.apple.Safari HomePage -string "about:blank"

      success "Prevent Safari from opening safe files automatically after downloading"
      defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

      # success "Allow hitting the Backspace key to go to the previous page in history"
      # defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

      # # Hide Safari’s bookmarks bar by default
      # defaults write com.apple.Safari ShowFavoritesBar -bool false

      # # Hide Safari’s sidebar in Top Sites
      # defaults write com.apple.Safari ShowSidebarInTopSites -bool false

      # # Disable Safari’s thumbnail cache for History and Top Sites
      # defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

      success "Enable Safari’s debug menu"
      defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

      success "Make Safari’s search banners default to Contains instead of Starts With"
      defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

      success "Remove useless icons from Safari’s bookmarks bar"
      defaults write com.apple.Safari ProxiesInBookmarksBar "()"

      success "Enable the Develop menu and the Web Inspector in Safari"
      defaults write com.apple.Safari IncludeDevelopMenu -bool true
      defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
      defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

      success "Add a context menu item for showing the Web Inspector in web views"
      defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
    fi
  }

  function mailPrefs() {
    seek_confirmation "Configure Mail.app?"
    if is_confirmed; then

      success "Disable send and reply animations in Mail.app"
      defaults write com.apple.mail DisableReplyAnimations -bool true
      defaults write com.apple.mail DisableSendAnimations -bool true

      success "Copy sane email addresses to clipboard"
      # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
      defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

      #success "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
      #defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

      success "Display emails in threaded mode, sorted by date (newest at the top)"
      defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
      defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "no"
      defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

      #success "Disable inline attachments (just show the icons)"
      #defaults write com.apple.mail DisableInlineAttachmentViewing -bool false

    fi
  }

  function spotlightPrefs() {
    seek_confirmation "Configure Spotlight?"
    if is_confirmed; then

      # Hide Spotlight tray-icon (and subsequent helper)
      #sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

      success "Disabled Spotlight indexing for any new mounted volume"
      # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
      sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

      success "Change indexing order and disable some file types"
        # Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
        #   MENU_DEFINITION
        #   MENU_CONVERSION
        #   MENU_EXPRESSION
        #   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
        #   MENU_WEBSEARCH             (send search queries to Apple)
        #   MENU_OTHER
        # defaults write com.apple.spotlight orderedItems -array \
        #   '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        #   '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        #   '{"enabled" = 1;"name" = "DIRECTORIES";}' \
        #   '{"enabled" = 1;"name" = "PDF";}' \
        #   '{"enabled" = 1;"name" = "FONTS";}' \
        #   '{"enabled" = 0;"name" = "DOCUMENTS";}' \
        #   '{"enabled" = 0;"name" = "MESSAGES";}' \
        #   '{"enabled" = 0;"name" = "CONTACT";}' \
        #  '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        #   '{"enabled" = 0;"name" = "IMAGES";}' \
        #   '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        #   '{"enabled" = 0;"name" = "MUSIC";}' \
        #   '{"enabled" = 0;"name" = "MOVIES";}' \
        #   '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        #   '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        #   '{"enabled" = 0;"name" = "SOURCE";}' \
        #   '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        #   '{"enabled" = 0;"name" = "MENU_OTHER";}' \
        #   '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
        #   '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
        #   '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        #   '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
        # Load new settings before rebuilding the index
        # killall mds > /dev/null 2>&1
        # Make sure indexing is enabled for the main volume
        #sudo mdutil -i on / > /dev/null
        # Rebuild the index from scratch
        #sudo mdutil -E / > /dev/null
    fi
  }

  function terminalPrefs() {
    seek_confirmation "Configure Terminal.app?"
    if is_confirmed; then

      success "Only use UTF-8 in Terminal.app"
      defaults write com.apple.terminal StringEncodings -array 4

      # Use a modified version of the Pro theme by default in Terminal.app
      open "${HOME}/Dropbox/sharedConfiguration/App Configuration Files/Terminal/solarizedDark.terminal"
      sleep 2 # Wait a bit to make sure the theme is loaded
      defaults write com.apple.terminal "Default Window Settings" -string "solarizedDark"
      defaults write com.apple.terminal "Startup Window Settings" -string "solarizedDark"

      # Enable “focus follows mouse” for Terminal.app and all X11 apps
      # i.e. hover over a window and start typing in it without clicking first
      #defaults write com.apple.terminal FocusFollowsMouse -bool true
      #defaults write org.x.X11 wm_ffm -bool true
    fi

    seek_confirmation "Configure iTerm2?"
    if is_confirmed; then
      success "Installed pretty iTerm colors"
      open "${HOME}/Dropbox/sharedConfiguration/App Configuration Files/iTerm/nate.itermcolors"

      success "Don't display the annoying prompt when quitting iTerm"
      defaults write com.googlecode.iterm2 PromptOnQuit -bool false
    fi
  }

  function timeMachinePrefs() {
    seek_confirmation "Disable Time Machine?"
    if is_confirmed; then
      success "Prevent Time Machine from prompting to use new hard drives as backup volume"
      defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

      success "Disable local Time Machine backups"
      hash tmutil &> /dev/null && sudo tmutil disablelocal
    fi
  }

  function applicationPrefs() {
    seek_confirmation "Configure Activity Monitor?"
    if is_confirmed; then
      success "Show the main window when launching Activity Monitor"
      defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

      success "Visualize CPU usage in the Activity Monitor Dock icon"
      defaults write com.apple.ActivityMonitor IconType -int 5

      success "Show all processes in Activity Monitor"
      defaults write com.apple.ActivityMonitor ShowCategory -int 0

      success "Sort Activity Monitor results by CPU usage"
      defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
      defaults write com.apple.ActivityMonitor SortDirection -int 0
    fi

    seek_confirmation "Stop Photos from opening whenever a camera is connected?"
    if is_confirmed; then
      defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES
    fi

    seek_confirmation "Configure Google Chrome?"
    if is_confirmed; then
      # Use the system-native print preview dialog
      defaults write com.google.Chrome DisablePrintPreview -bool true
      defaults write com.google.Chrome.canary DisablePrintPreview -bool true
    fi

    seek_confirmation "Configure Contacts, Calendar, TextEdit, Disk Util?"
    if is_confirmed; then
      success "Enable the debug menu in Address Book"
      defaults write com.apple.addressbook ABShowDebugMenu -bool true

      # Enable Dashboard dev mode (allows keeping widgets on the desktop)
      # defaults write com.apple.dashboard devmode -bool true

      # Enable the debug menu in iCal (pre-10.8)
      # defaults write com.apple.iCal IncludeDebugMenu -bool true

      success "Use plain text mode for new TextEdit documents"
      defaults write com.apple.TextEdit RichText -int 0
      success "Open and save files as UTF-8 in TextEdit"
      defaults write com.apple.TextEdit PlainTextEncoding -int 4
      defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

      success "Enable the debug menu in Disk Utility"
      defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
      defaults write com.apple.DiskUtility advanced-image-options -bool true
    fi

    seek_confirmation "Configure Sublime Text 3 in Terminal?"
    if is_confirmed; then
      if [ ! -e "/Applications/Sublime Text.app" ]; then
        error "We don't have Sublime Text.app.  Get it installed and try again."
      else
        if [ ! -e "/usr/local/bin/subl" ]; then
          ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
          success "Symlink created."
        else
          notice "Symlink already exists. Nothing done."
        fi
      fi
    fi

    seek_confirmation "Configure Messages.app?"
    if is_confirmed; then
      success "Disable automatic emoji substitution in Messages.app? (i.e. use plain text smileys) (y/n)"
      defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

      success "Disable smart quotes in Messages.app? (it's annoying for messages that contain code) (y/n)"
      defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

      success "Disabled continuous spell checking in Messages.app? (y/n)"
      defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
    fi
  }

  function ssdPrefs() {
    seek_confirmation "Confirm that you have an SSD Hard Drive and want to disable sudden motion sensor."
    if is_confirmed; then

      success "Remove the sleep image file to save disk space"
      sudo rm /Private/var/vm/sleepimage
      success "Create a zero-byte file instead…"
      sudo touch /Private/var/vm/sleepimage
      success "…and make sure it can’t be rewritten"
      sudo chflags uchg /Private/var/vm/sleepimage

      success "Disable the sudden motion sensor as it’s not useful for SSDs"
      sudo pmset -a sms 0
    fi
  }

  function cleanup() {
    seek_confirmation "Kill all effected applications?"
    if is_confirmed; then
      for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
        "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
        "Terminal" "iCal"; do
        killall "${app}" > /dev/null 2>&1
      done
      success "Apps killed"
    fi

    notice "Some of these changes require a logout/restart to take effect."
  }

  # Run the script
  # ###############

  # Ask for the administrator password upfront
  sudo -v
  setComputerName
  generalUITPrefs
  inputDevicePrefs
  screenPrefs
  finderPrefs
  dockDashPrefs
  safariPrefs
  mailPrefs
  spotlightPrefs
  terminalPrefs
  timeMachinePrefs
  applicationPrefs
  ssdPrefs
  cleanup
}

## SET SCRIPTNAME VARIABLE ##
scriptName=$(basename "$0")

function trapCleanup() {
  # trapCleanup Function
  # -----------------------------------
  # Any actions that should be taken if the script is prematurely
  # exited.  Always call this function at the top of your script.
  # -----------------------------------
  echo ""
  # Delete temp files, if any
  if [ -d "${tmpDir}" ] ; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."
}

function safeExit() {
  # safeExit
  # -----------------------------------
  # Non destructive exit for when script exits naturally.
  # Usage: Add this function at the end of every script.
  # -----------------------------------
  # Delete temp files, if any
  if [ -d "${tmpDir}" ] ; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit
}

function seek_confirmation() {
  # Asks questions of a user and then does something with the answer.
  # y/n are the only possible answers.
  #
  # USAGE:
  # seek_confirmation "Ask a question"
  # if is_confirmed; then
  #   some action
  # else
  #   some other action
  # fi
  #
  # Credt: https://github.com/kevva/dotfiles
  # ------------------------------------------------------
  # echo ""
  input "$@"
  if ${force}; then
    notice "Forcing confirmation with '--force' flag set"
  else
    read -p " (y/n) " -n 1
    echo ""
  fi
}

function is_confirmed() {
  if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

function is_not_confirmed() {
  if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
    return 0
  fi
  return 1
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=false
printLog=false
verbose=false
force=false
strict=false
debug=false
args=()

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="${HOME}/Library/Logs/${scriptBasename}.log"


# Options and Usage
# -----------------------------------
# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This script configures Mac OS default preferences.  Common usage is to bootstrap
a new computer at first use.


 ${bold}Options:${reset}

  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# -------------------------------------
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "$(basename $0) ${version}"; safeExit ;;

    -v|--verbose) verbose=true ;;
    -l|--log) printLog=true ;;
    -q|--quiet) quiet=true ;;
    -s|--strict) strict=true;;
    -d|--debug) debug=true;;
    --force) force=true ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")


# Logging and Colors
# -----------------------------------------------------
# Here we set the colors for our script feedback.
# Example usage: success "sometext"
#------------------------------------------------------

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
underline=$(tput sgr 0 1)

function _alert() {
  if [ "${1}" = "emergency" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${red}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "debug" ]; then local color="${purple}"; fi
  if [ "${1}" = "header" ]; then local color="${bold}${tan}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}"; printLog="false"; fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color=""; fi
  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then color=""; reset=""; fi

  # Print to $logFile
  if ${printLog}; then
    echo -e "$(date +"%m-%d-%Y %r") $(printf "[%9s]" "${1}") ${_message}" >> "${logFile}";
  fi

  # Print to console when script is not 'quiet'
  if ${quiet}; then
   return
  else
   echo -e "$(date +"%r") ${color}$(printf "[%9s]" "${1}") ${_message}${reset}";
  fi
}

function die ()       { local _message="${*} Exiting."; echo "$(_alert emergency)"; safeExit;}
function error ()     { local _message="${*}"; echo "$(_alert error)"; }
function warning ()   { local _message="${*}"; echo "$(_alert warning)"; }
function notice ()    { local _message="${*}"; echo "$(_alert notice)"; }
function info ()      { local _message="${*}"; echo "$(_alert info)"; }
function debug ()     { local _message="${*}"; echo "$(_alert debug)"; }
function success ()   { local _message="${*}"; echo "$(_alert success)"; }
function input()      { local _message="${*}"; echo -n "$(_alert input)"; }
function header()     { local _message="${*}"; echo "$(_alert header)"; }

# Log messages when verbose is set to "true"
verbose() { if ${verbose}; then debug "$@"; fi }

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript

# Exit cleanly
safeExit