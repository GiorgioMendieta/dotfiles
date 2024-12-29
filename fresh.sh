#!/usr/bin/env bash
# Thanks to https://mths.be/macos
# More info : https://macos-defaults.com


# Script's color palette (https://misc.flogisoft.com/bash/tip_colors_and_formatting)
COLOR_BLACK=0
COLOR_YELLOW=3
COLOR_BLUE=4
# Use tput to get the escape codes for the colors
reset=$(tput sgr0) # Reset text attributes to normal
dim=$(tput dim)
bold=$(tput bold)
highlight=$(tput setab $COLOR_BLUE; tput setaf $COLOR_BLACK) # Highlight text with blue background
arrow="$(tput setaf $COLOR_YELLOW)▸ $reset" # Print an arrow with yellow foreground

# Get full directory name of this script
cwd="$(cd "$(dirname "$0")" && pwd)"

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

headline() {
    printf "${highlight} %s ${reset}\n" "$@"
}

# Increase chapter count and print out a chapter title
chapter_count=1
chapter() {
    echo -e "${highlight} $((chapter_count++)).) $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
# i.e. ▸ Step 1 [Y/n]:
step() {
    if [ $# -eq 1 ]
    then echo -e "${arrow}$@"
    else echo -ne "${arrow}$@"
    fi
}

# Print the executed command with a dim color
run() {
    echo -e "${dim}▹ $@ $reset"
    eval $@
    echo ""
}

############################################################################################

# Just a little welcome screen
echo ""
headline "                                                "
headline "        We are about to pimp your  Mac!        "
headline "     Follow the prompts and you'll be fine.     "
headline "                                                "
echo ""

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
if [ $(sudo -n uptime 2>&1|grep "load"|wc -l) -eq 0 ]
then
    step "Some of these settings are system-wide, therefore we need your permission."
    sudo -v
    echo ""
fi

##############################################
chapter "Adjusting general settings"
##############################################


# step "Setting your computer name (as done via System Preferences → Sharing)."
# echo -ne "  What would you like it to be? (e.g. Macbook NAME) $bold"
# read computer_name
# echo -e "$reset"
# run sudo scutil --set ComputerName "'$computer_name'"
# run sudo scutil --set HostName "'$computer_name'"
# run sudo scutil --set LocalHostName "'$computer_name'"
# run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "'$computer_name'"

step "Disable OS X Gate Keeper? (You'll be able to install any app you want from here on, not just Mac App Store apps) [Y/n]: "
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run sudo spctl --master-disable
        run sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
        ;;
esac

step "Disable the “Are you sure you want to open this application?” dialog? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.LaunchServices LSQuarantine -bool false
        ;;
esac

# Flash clock time separators every second
run defaults write com.apple.menuextra.clock "FlashDateSeparators" -bool "true"

# Prevent Photos from opening automatically when devices are plugged in
run defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Set sidebar icon size to medium
run defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Set Launchpad Icon columns to 8
run defaults write com.apple.dock "springboard-columns" -int 8

# Automatically quit printer app once the print jobs complete
run defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
run defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Prevent Time Machine from prompting to use new hard drives as backup volume
run defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Use plain text mode for new TextEdit documents
run defaults write com.apple.TextEdit RichText -int 0

# Disable shadow in screenshots
run defaults write com.apple.screencapture disable-shadow -bool true

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
run defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add 'com.apple.mail'
run defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"


##############################################
chapter "Adjusting input device settings"
##############################################

step "Enable tap to click for this user and for the login screen? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        ;;
esac

step "Enable full keyboard access for all controls? (e.g. enable Tab in modal dialogs) [Y/n]: "
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
        ;;
esac

step "Disable press-and-hold for keys in favor of key repeat? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
        ;;
esac

step "Use scroll gesture with the Ctrl (^) modifier key to zoom? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
        run defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
        ;;
esac

step "Disable auto-correct? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
        ;;
esac

step "Stop iTunes from responding to the keyboard media keys? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
        ;;
esac

step "Set click weight (0, 1, 2): " ""
read clickweight
case $clickweight in
    [nN] )
        echo ""
        ;;
    * )
        echo ""
        run defaults write com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int ${clickweight:-0}
        ;;
esac

step "Enable three finger drag? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool true
        ;;
esac

###############################################################################
chapter "Energy saving settings"
# More info : https://www.dssw.co.uk/reference/pmset/
###############################################################################

# The −a, −b, −c, −u flags determine whether the settings apply to:
# battery ( −b ), AC power ( −c ), UPS ( −u ) or all ( −a ).

# Disable low power mode
run sudo pmset -a lowpower 0

# Enable lid wakeup
run sudo pmset -a lidwake 1

# Enable wake for network access while charging
run sudo pmset -c womp 1

# Restart automatically on power loss
run sudo pmset -a autorestart 1

# Restart automatically if the computer freezes
run sudo systemsetup -setrestartfreeze on

# Sleep the display after x minutes
run sudo pmset -b displaysleep 5
run sudo pmset -c displaysleep 20

# Disable machine sleep while charging and 5 minutes on battery
run sudo pmset -c sleep 0
run sudo pmset -b sleep 5

##############################################
chapter "Adjusting locale settings"
##############################################

step "Set custom language and text formats? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        # Note: Replace to your locale
        run defaults write NSGlobalDomain AppleLanguages -array "en-MX" "es-MX" "ru-MX"
        run defaults write NSGlobalDomain AppleLocale -string "en_MX@currency=MXN"
        run defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
        run defaults write NSGlobalDomain AppleMetricUnits -bool true
        # Show language menu in the top right corner of the boot screen
        run sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
        # Set the timezone; see `sudo systemsetup -listtimezones` for other values
        run sudo systemsetup -settimezone "Europe/Paris" > /dev/null
        # run sudo systemsetup -settimezone "America/Mexico_City" > /dev/null
        ;;
esac

##############################################
chapter "Adjusting Finder settings"
##############################################

step "Show icons for hard drives, servers, and removable media on the desktop? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
        run defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
        run defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
        run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
        ;;
esac

# Finder: disable window animations and Get Info animations
run defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show all filename extensions
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
run defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
run defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
run defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
run defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
run defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

step "Enable AirDrop over Ethernet and on unsupported Macs running Lion? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
        ;;
esac

# Show the ~/Library folder
run chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
run defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
run /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
run /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
run /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
run /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist


##############################################
chapter "Adjusting Dock, Dashboard, and hot corners"
##############################################

step "Set Dock orientation to the left?: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.dock orientation -string "left"
        ;;
esac

step "Change the icon size (in px) of Dock items? [54/n]: " ""
read tilesize
case $tilesize in
    [nN] )
        echo ""
        ;;
    * )
        echo ""
        run defaults write com.apple.dock tilesize -int ${tilesize:-54}
        ;;
esac

step "Change the magnification size (in px) of Dock items when hovering over them? [82/n]: " ""
read largesize
case $largesize in
    [nN] )
        echo ""
        ;;
    * )
        echo ""
        run defaults write com.apple.dock largesize -int ${largesize:-82}
        ;;
esac

step "Automatically hide and show the Dock? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.dock autohide -bool true
        # Speed-up or remove the animation when hiding/showing the Dock
        run defaults write com.apple.dock autohide-delay -float 0
        # Speed-up or remove the animation when hiding/showing the Dock
        run defaults write com.apple.dock autohide-time-modifier -float 0.15
        ;;
esac


# Change minimize/maximize window effect
run defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
run defaults write com.apple.dock expose-group-apps -bool false

# Disable Dashboard
run defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
# run defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
run defaults write com.apple.dock mru-spaces -bool false

# Make Dock icons of hidden applications translucent
run defaults write com.apple.dock showhidden -bool true

# Don’t show recent applications in Dock
run defaults write com.apple.dock show-recents -bool false

# Hot corners
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
# 13: Lock Screen

step "Set custom Hot corners? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        echo "Top right screen corner → Mission Control"
        run defaults write com.apple.dock wvous-tr-corner -int 2
        defaults write com.apple.dock wvous-tr-modifier -int 0
        
        echo "Top left screen corner → Nothing"
        run defaults write com.apple.dock wvous-tl-corner -int 1
        defaults write com.apple.dock wvous-tl-modifier -int 0
        
        echo "Bottom left screen corner → Launchpad"
        run defaults write com.apple.dock wvous-bl-corner -int 11
        defaults write com.apple.dock wvous-bl-modifier -int 0
        
        echo "Bottom right screen corner → Desktop"
        run defaults write com.apple.dock wvous-br-corner -int 4
        defaults write com.apple.dock wvous-br-modifier -int 0
        ;;
esac

##############################################
chapter "Safari & WebKit settings"
##############################################

step "Enable the Developer menu and the Web Inspector in Safari? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.Safari IncludeDevelopMenu -bool true
        run defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
        run defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
        ;;
esac

step "Disable AutoFill? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.Safari AutoFillFromAddressBook -bool false
        run defaults write com.apple.Safari AutoFillPasswords -bool false
        run defaults write com.apple.Safari AutoFillCreditCardData -bool false
        run defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
        ;;
esac

# Restore session at launch
run defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
run defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Disable personalized advertisements and identifier tracking
run defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
run defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
run defaults write com.apple.AdLib forceLimitAdTracking -bool true

##############################################
chapter "Adjusting Mac App Store settings"
##############################################

step "Enable the automatic update check? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
        run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
        ;;
esac


step "Download newly available updates in background? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
        ;;
esac

step "Install System data files & security updates? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
        ;;
esac

# step "Turn on app auto-update? [Y/n]: " ""
# case $(read choice; echo $choice) in
#     [nN] )
#         echo ""
#         ;;
#     [yY] | * )
#         echo ""
#         run defaults write com.apple.commerce AutoUpdate -bool true
#         ;;
# esac

##############################################
chapter "Adding custom App shortcuts"
##############################################
step "Add custom App Shortcuts? (Keyboard > Keyboard Shortcuts > App Shortcuts) [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run ./scripts/add-macos-keyboard-shortcuts.sh
        ;;
esac

# TODO:
##############################################
chapter "Symlinking dotfiles…"
##############################################
# Removes .{filename} from $HOME (if it exists) and symlinks the file from ~/.dotfiles
step ".zshrc"
run rm -rf $HOME/.zshrc
run ln -s .zshrc $HOME/.zshrc

step "Seting Vim and Nano config files"
run rm -rf $HOME/.vimrc
run ln -s .vimrc $HOME/.vimrc
run rm -rf $HOME/.nanorc
run ln -s .nanorc $HOME/.nanorc

step "Setting sshconfig"
# More info : https://linuxize.com/post/using-the-ssh-config-file/
run mkdir -p ~/.ssh && chmod 700 $HOME/.ssh
run ln -s sshconfig $HOME/.ssh/config
run chmod 600 $HOME/.ssh/config

step "Mackup config file"
run rm -rf $HOME/.mackup.cfg
run ln -s .mackup.cfg $HOME/.mackup.cfg

##############################################
chapter "Installing CLI tools"
##############################################

# Check for Oh My Zsh and install if we don't have it
step "Installing Oh My Zsh\n"
if test ! $(which omz); then
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
step "Installing Homebrew" 
if test ! $(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Powerlevel10k theme on the ZSH_CUSTOM path, else to the default path
step "Install Powerlevel 10k theme? [y/n]"
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run sudo rm -R ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        run rm -rf $HOME/.p10k.zsh
        run ln -s .p10k.zsh $HOME/.p10k.zsh
        ;;
esac

step "Set fzf as the default completion engine for zsh? [y/n]"
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
        ;;
esac

##############################################
chapter "Installing Homebrew formulae and casks…"
##############################################
step "Homebrew formulae and casks\n"
# Update Homebrew recipes
run brew update
# Install all our dependencies with homebrew bundle (See Brewfile)
run brew tap homebrew/bundle
run brew bundle --file ./Brewfile

##############################################
chapter "Directories"
##############################################
step "Creating directories\n"
# Create a Developer directory
run mkdir $HOME/Developer


##############################################
chapter "GitHub configuration"
##############################################
step "Clone Github repositories\n"
run ./clone.sh

step "Symlink Git config files"
run m -rf $HOME/.gitconfig
run n -s .gitconfig $HOME/.gitconfig
run m -rf $HOME/.gitignore_global
run n -s .gitignore_global $HOME/.gitignore_global


##############################################
chapter "Transmission.app settings"
##############################################

# Use `~/Documents/Torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

# Use `~/Downloads` to store completed downloads
defaults write org.m0k.transmission DownloadLocationConstant -bool true

# Don’t prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission MagnetOpenAsk -bool false

# Don’t prompt for confirmation before removing non-downloading active transfers
defaults write org.m0k.transmission CheckRemoveDownloading -bool true

# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false

# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false

# IP block list.
# Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
defaults write org.m0k.transmission BlocklistNew -bool true
defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

# Randomize port on launch
defaults write org.m0k.transmission RandomPort -bool true