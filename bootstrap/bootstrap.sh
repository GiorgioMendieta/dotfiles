#!/usr/bin/env bash
# Thanks to https://mths.be/macos
# More info : https://macos-defaults.com

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"
export DOTFILES

# Load helper functions
source "$DOTFILES/bin/link_dotfiles.sh"

function getAdminPassword() {
  # Ask for the administrator password upfront.
  step "Admin password is required for install..."
  sudo -v
  echo ""
  # Keep-alive: update existing `sudo` time stamp until the script has finished.
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

confirm() {
  local prompt="$1"
  local default="${2:-no}"
  local answer

  while true; do
    if [[ "$default" == "yes" ]]; then
      step_prompt "$prompt [Y/n]: "
    else
      step_prompt "$prompt [y/N]: "
    fi

    answer=""
    if ! IFS= read -r answer; then
      printf '\n'
      return 1
    fi
    case "${answer,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      "")
        [[ "$default" == "yes" ]]
        return
        ;;
      *)
        printf 'Please answer yes or no.\n'
        ;;
    esac
  done
}

# Script's color palette (https://misc.flogisoft.com/bash/tip_colors_and_formatting)
COLOR_BLACK=0
COLOR_RED=1
COLOR_GREEN=2
COLOR_YELLOW=3
COLOR_BLUE=4
COLOR_MAGENTA=5
COLOR_CYAN=6
COLOR_WHITE=7

# Use tput to get the escape codes for the colors
reset=$(tput sgr0) # Reset text attributes to normal
dim=$(tput dim)
bold=$(tput bold)
highlight=$(
  tput setab ${COLOR_BLUE}
  tput setaf ${COLOR_BLACK}
)                                               # Highlight text with blue background
arrow="$(tput setaf ${COLOR_YELLOW})▸ ${reset}" # Print an arrow with yellow foreground

headline() {
  printf "${highlight} %s ${reset}\n" "$@"
}

# Increase chapter count and print out a chapter title
chapter_count=1
chapter() {
  echo -e "${highlight} $((chapter_count++)). $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
# i.e. ▸ Step 1 [Y/n]:
step() {
  if [ $# -eq 1 ]; then
    echo -e "${arrow}$@"
  else
    echo -ne "${arrow}$@"
  fi
}

step_prompt() {
  printf '%s%s' "$arrow" "$1"
}

# Print the executed command with a dim color
run() {
  local status

  printf '%s▹' "$dim"
  printf ' %q' "$@"
  printf '%s\n' "$reset"
  if "$@"; then
    printf '\n'
  else
    status=$?
    printf 'Command failed with status %d.\n' "$status" >&2
    return "$status"
  fi
}

_getBundleID() {
  mdls -raw -name kMDItemCFBundleIdentifier "$1"
}

clone_git_checkout() {
  local repository="$1"
  local destination="$2"

  if [[ -d "$destination/.git" || -f "$destination/.git" ]]; then
    return 0
  fi
  if [[ -e "$destination" ]]; then
    printf 'Clone destination exists but is not a Git checkout: %s\n' "$destination" >&2
    return 1
  fi
  run git clone --depth=1 "$repository" "$destination"
}

# Check for Xcode Command Line Tools before changing any system settings.
step "Checking Xcode Command Line Tools\n"
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
  echo "Complete the Command Line Tools installation, then run this bootstrap again."
  exit 0
else
  echo "Xcode Command Line Tools already installed."
fi

############################################################################################

# Just a little welcome screen
echo ""
headline "                                                "
headline "        We are about to pimp your  Mac!        "
headline "     Follow the prompts and you'll be fine.     "
headline "                                                "
echo ""

# Close any open System Settings panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Settings" to quit'

getAdminPassword


##############################################
chapter "Adjusting general settings"
##############################################

#step "Setting your computer name (as done via System Preferences → Sharing)."
#echo -ne "  What would you like it to be? (e.g. <name>-Macbook) ${bold}"
#read computer_name
#echo -e "${reset}"
#run sudo scutil --set ComputerName "'$computer_name'"
#run sudo scutil --set HostName "'$computer_name'"
#run sudo scutil --set LocalHostName "'$computer_name'"
#run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "'$computer_name'"


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

# Increase time screenshots stay in the corner of the screen
run defaults write com.apple.screencaptureui "thumbnailExpiration" -float 10

# Move windows by clicking and dragging anywhere + ctrl + cmd
run defaults write -g NSWindowShouldDragOnGesture -bool true

if confirm "Enable using Touch ID for sudo authentication?" yes; then
  run echo "auth       sufficient     pam_tid.so" | sudo tee /private/etc/pam.d/sudo_local > /dev/null
fi

##############################################
chapter "Adjusting input device settings"
##############################################

if confirm "Enable tap to click for the trackpad?" yes; then
  run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
fi

# Enable full keyboard access for all controls? (e.g. enable Tab in modal dialogs)
run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Use scroll gesture with the Ctrl (^) modifier key to zoom
run defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
run defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Disable auto-correct
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set click weight (0, 1, 2)
run defaults write com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int 1

# Enable three finger drag
run defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool true

###############################################################################
chapter "Energy saving settings"
# More info : https://www.dssw.co.uk/reference/pmset/
###############################################################################

# The −a, −b, −c, −u flags determine whether the settings apply to:
# - Battery ( −b ),
# - AC power ( −c ),
# - UPS ( −u ) or
# - All ( −a ).

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

if confirm "Set custom language and text formats?" no; then
  # Note: Replace to your locale
  run defaults write NSGlobalDomain AppleLanguages -array "en-GB" "es-MX" "fr-MX" "ru-MX"
  run defaults write NSGlobalDomain AppleLocale -string "en_MX@currency=MXN"
  run defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  run defaults write NSGlobalDomain AppleMetricUnits -bool true
  # Show language menu in the top right corner of the boot screen
  run sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
  # Set the timezone; see `sudo systemsetup -listtimezones` for other values
  # Note: change to "America/Mexico_City" if needed
  run sudo systemsetup -settimezone "Europe/Paris" >/dev/null
fi

##############################################
chapter "Adjusting Finder settings"
##############################################

# Show icons for hard drives, servers, and removable media on the desktop
run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
run defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
run defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

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

# Show the ~/Library folder
run chflags nohidden "$HOME/Library"
if xattr -p com.apple.FinderInfo "$HOME/Library" >/dev/null 2>&1; then
  run xattr -d com.apple.FinderInfo "$HOME/Library"
fi

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

# Set Dock orientation to the left
run defaults write com.apple.dock orientation -string "left"

step_prompt "Change the icon size (in px) of Dock items? [54/n]: "
tilesize=""
read -r tilesize || true
case $tilesize in
[nN])
  echo ""
  ;;
 "")
  run defaults write com.apple.dock tilesize -int 54
  ;;
*)
  if [[ "$tilesize" =~ ^[0-9]+$ ]]; then
    run defaults write com.apple.dock tilesize -int "$tilesize"
  else
    printf 'Invalid Dock icon size: %s\n' "$tilesize" >&2
    exit 1
  fi
  ;;
esac

step_prompt "Change the magnification size (in px) of Dock items when hovering over them? [82/n]: "
largesize=""
read -r largesize || true
case $largesize in
[nN])
  echo ""
  ;;
 "")
  run defaults write com.apple.dock largesize -int 82
  ;;
*)
  if [[ "$largesize" =~ ^[0-9]+$ ]]; then
    run defaults write com.apple.dock largesize -int "$largesize"
  else
    printf 'Invalid Dock magnification size: %s\n' "$largesize" >&2
    exit 1
  fi
  ;;
esac

# Automatically hide and show the Dock?
run defaults write com.apple.dock autohide -bool true
# Speed-up or remove the animation when hiding/showing the Dock
run defaults write com.apple.dock autohide-delay -float 0
# Speed-up or remove the animation when hiding/showing the Dock
run defaults write com.apple.dock autohide-time-modifier -float 0.15

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

if confirm "Set custom Hot corners?" yes; then
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
fi

##############################################
chapter "Safari & WebKit settings"
##############################################

# Enable the Developer menu and the Web Inspector in Safari
run defaults write com.apple.Safari IncludeDevelopMenu -bool true
run defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
run defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

#Disable AutoFill (in favor of Bitwarden)
run defaults write com.apple.Safari AutoFillFromAddressBook -bool false
run defaults write com.apple.Safari AutoFillPasswords -bool false
run defaults write com.apple.Safari AutoFillCreditCardData -bool false
run defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

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

run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1
run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

if confirm "Download newly available updates in background?" yes; then
  run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
fi

run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

##############################################
chapter "Custom App shortcuts"
##############################################
if confirm "Set custom App shortcuts? (Keyboard → Keyboard Shortcuts → App Shortcuts)" yes; then
  run bash "$DOTFILES/scripts/add-macos-keyboard-shortcuts.sh"
fi


##############################################
chapter "Installing CLI utilities"
##############################################

step "Setting ssh config file"
# More info : https://linuxize.com/post/using-the-ssh-config-file/
link_dotfile "$DOTFILES/.ssh/ssh_config" "$HOME/.ssh/config"
run chmod 700 "$HOME/.ssh"
run chmod 600 "$HOME/.ssh/config"

# Check for Oh My Zsh and install if we don't have it
step "Installing Oh My Zsh\n"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh | /bin/sh
fi

# Check for Homebrew and install if we don't have it
step "Installing Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check for Git and install if we don't have it
step "Veryfing git installation\n"
if ! command -v git >/dev/null 2>&1; then
  echo "Git is not installed, installing it now...\n"
  run brew install git
fi

# Install Oh My Zsh customizations in the ZSH_CUSTOM path (cf. .zshrc)
if confirm "Install Powerlevel10k theme?" yes; then
  clone_git_checkout https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  link_dotfile "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
fi

if confirm "Install fzf-tab, autosuggestions, and syntax-highlighting plugins?" yes; then
  mkdir -p "$ZSH_CUSTOM/plugins"
  clone_git_checkout https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
  clone_git_checkout https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_git_checkout https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi


##############################################
chapter "Installing Homebrew packages…"
##############################################
step "Homebre formulae and casks\n"
# Update Homebrew recipes
run brew update

if confirm "Install Homebrew Bundle packages?" yes; then
  run brew bundle --file "$DOTFILES/homebrew/Brewfile"
fi


##############################################
chapter "Symlinking dotfiles…"
##############################################

run bash "$DOTFILES/bootstrap/symlinks.sh"

##############################################
chapter "Installing App settings"
##############################################

step "Raycast config file"
echo "Open Raycast > Settings > Advanced > Import/Export > Import and load the file located at $DOTFILES/Apps/Raycast/"

step "Little Snitch config file"
echo "Open Little Snitch > File > Restore from Backup… and load the file located at $DOTFILES/Apps/Little_Snitch/"

##############################################
chapter "Directories"
##############################################
step "Creating directories\n"
# Create a Developer directory
run mkdir -p "$HOME/Developer"

##############################################
chapter "Git configuration"
##############################################

step "Symlink Git config files"
link_dotfile "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
link_dotfile "$DOTFILES/.gitignore_global" "$HOME/.gitignore_global"

step "Clone Github repositories\n"
run bash "$DOTFILES/bootstrap/clone.sh"

step "Set GitHub signing key"
echo "Open https://github.com/settings/keys and add your SSH public key located at $HOME/.ssh/id_ed25519.pub"

##############################################
chapter "Transmission.app settings"
##############################################

# Only run if Transmission is installed
app=/Applications/Transmission.app
if [ ! -d "$app" ]; then
  echo "Transmission is not installed. Skipping."
else
  bundleid=$(_getBundleID "$app")

  # Use `~/Documents/Torrents` to store incomplete downloads
  run defaults write "$bundleid" UseIncompleteDownloadFolder -bool true
  run defaults write "$bundleid" IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

  # Use `~/Downloads` to store completed downloads
  run defaults write "$bundleid" DownloadLocationConstant -bool true

  # Don’t prompt for confirmation before downloading
  run defaults write "$bundleid" DownloadAsk -bool false
  run defaults write "$bundleid" MagnetOpenAsk -bool false

  # Don’t prompt for confirmation before removing non-downloading active transfers
  run defaults write "$bundleid" CheckRemoveDownloading -bool true

  # Trash original torrent files
  run defaults write "$bundleid" DeleteOriginalTorrent -bool true

  # Hide the donate message
  run defaults write "$bundleid" WarningDonate -bool false

  # Hide the legal disclaimer
  run defaults write "$bundleid" WarningLegal -bool false

  # IP block list.
  run defaults write "$bundleid" BlocklistNew -bool true
  run defaults write "$bundleid" BlocklistURL -string "http://list.iblocklist.com/?list=fr&fileformat=p2p&archiveformat=gz"
  run defaults write "$bundleid" BlocklistAutoUpdate -bool true

  # Randomize port on launch
  run defaults write "$bundleid" RandomPort -bool true
fi
