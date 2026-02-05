#!/usr/bin/env bash

###############################################################################
# macOS Defaults Configuration Script
# Safe to run multiple times (idempotent)
###############################################################################

set -e

echo ""
echo "=================================================="
echo "Configuring macOS system defaults..."
echo "=================================================="
echo ""

###############################################################################
# General UI/UX                                                               #
###############################################################################

echo "› General: Disabling the sound effects on boot"
sudo nvram SystemAudioVolume=" "

echo "› General: Expanding save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "› General: Expanding print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "› General: Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "› General: Automatically quit printer app once print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "› General: Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

###############################################################################
# Trackpad, Mouse, Keyboard, Bluetooth Accessories, Input                    #
###############################################################################

echo "› Trackpad: Enabling tap to click for this user and for the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "› Trackpad: Setting tracking speed to reasonably fast"
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

echo "› Keyboard: Setting key repeat rate to fast (requires logout)"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "› Keyboard: Disabling press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "› Keyboard: Disabling automatic capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "› Keyboard: Disabling smart dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "› Keyboard: Disabling automatic period substitution"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "› Keyboard: Disabling smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "› Keyboard: Disabling auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Screen                                                                      #
###############################################################################

echo "› Screen: Requiring password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "› Screen: Saving screenshots to ~/Pictures/Screenshots"
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

echo "› Screen: Saving screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

echo "› Screen: Disabling shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

echo "› Screen: Enabling subpixel font rendering on non-Apple LCDs"
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

###############################################################################
# Finder                                                                      #
###############################################################################

echo "› Finder: Showing all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "› Finder: Showing status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "› Finder: Showing path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "› Finder: Displaying full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "› Finder: Keeping folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "› Finder: Searching the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "› Finder: Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "› Finder: Avoiding creating .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "› Finder: Automatically opening a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

echo "› Finder: Showing hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "› Finder: Showing Library folder"
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true

echo "› Finder: Showing /Volumes folder"
sudo chflags nohidden /Volumes

echo "› Finder: Using list view in all Finder windows by default"
# Four-letter codes for view modes: icnv, clmv, glyv, Nlsv
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

echo "› Finder: Disabling the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

###############################################################################
# Dock, Dashboard, Hot Corners                                               #
###############################################################################

echo "› Dock: Setting icon size to 48 pixels"
defaults write com.apple.dock tilesize -int 48

echo "› Dock: Enabling magnification"
defaults write com.apple.dock magnification -bool true

echo "› Dock: Setting magnification icon size to 64 pixels"
defaults write com.apple.dock largesize -int 64

echo "› Dock: Automatically hiding and showing the Dock"
defaults write com.apple.dock autohide -bool true

echo "› Dock: Removing the auto-hiding delay"
defaults write com.apple.dock autohide-delay -float 0

echo "› Dock: Making Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo "› Dock: Disabling recent applications"
defaults write com.apple.dock show-recents -bool false

echo "› Dock: Disabling Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

echo "› Dock: Not showing Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true

echo "› Dock: Speeding up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1

echo "› Dock: Grouping windows by application in Mission Control"
defaults write com.apple.dock expose-group-by-app -bool true

###############################################################################
# Safari & WebKit                                                            #
###############################################################################

echo "› Safari: Enabling the Develop menu and the Web Inspector"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "› Safari: Enabling 'Do Not Track'"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "› Safari: Updating extensions automatically"
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Activity Monitor                                                           #
###############################################################################

echo "› Activity Monitor: Showing all processes"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "› Activity Monitor: Sorting results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit                                                                    #
###############################################################################

echo "› TextEdit: Using plain text mode for new documents"
defaults write com.apple.TextEdit RichText -int 0

echo "› TextEdit: Opening and saving files as UTF-8"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Time Machine                                                                #
###############################################################################

echo "› Time Machine: Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Kill affected applications                                                 #
###############################################################################

echo ""
echo "=================================================="
echo "Applying settings by restarting affected apps..."
echo "=================================================="
echo ""

for app in "Activity Monitor" \
    "cfprefsd" \
    "Dock" \
    "Finder" \
    "Safari" \
    "SystemUIServer"; do
    killall "${app}" &> /dev/null || true
done

echo ""
echo "✓ macOS defaults configured successfully!"
echo ""
echo "Note: Some changes require logout/restart to take full effect:"
echo "  - Keyboard key repeat rate"
echo "  - Trackpad tap to click (login screen)"
echo "  - Dashboard settings"
echo ""
