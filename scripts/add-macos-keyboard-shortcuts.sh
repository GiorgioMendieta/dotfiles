#!/usr/bin/env bash

# https://gist.github.com/scottrbaxter/8a150546cd4a306cbd8adcf3ce52fe8b

set -e

addEntries() {
  # check if universal access / custom menu key exists
  if defaults read com.apple.universalaccess com.apple.custommenu.apps >/dev/null 2>&1; then
    defaults delete com.apple.universalaccess com.apple.custommenu.apps
  fi
  # defaults write com.apple.universalaccess com.apple.custommenu.apps -array

  # write all apps to custommenu
  defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add $(echo -e "$appList")
  echo "All apps with custom shortcuts:"
  defaults read com.apple.universalaccess com.apple.custommenu.apps

  # Restart cfprefsd and Finder for changes to take effect.
  # You may also have to restart any apps that were running
  # when you changed their keyboard shortcuts. There is some
  # amount of voodoo as to what you do or do not have to
  # restart, and when.
  killall cfprefsd
  killall Finder
}

# We need the bundleid for each app
get_BundleId() {
  mdls -raw -name kMDItemCFBundleIdentifier "$1"
}

createKeyboardShortcuts() {
  # make life easier
  app=""
  appList=""
  # Key codes
  CMD="@"
  CTRL="^"
  OPT="~"
  SHIFT="$"
  UP='\U2191'
  DOWN='\U2193'
  LEFT='\U2190'
  RIGHT='\U2192'
  ENTER='\U21a9'
  F2='\Uf705'
  HYPER="${SHIFT}${CMD}${CTRL}${OPT}"
  # TAB='\U21e5'

  # All Apps
  # Global
  # defaults write NSGlobalDomain NSUserKeyEquivalents "{
  #     'About This Mac' = '${CMD}${SHIFT}${OPT}A';
  # }"

  # Finder
  app=/System/Library/CoreServices/Finder.app
  if [ -a "$app" ]; then
    bundleid=$(get_BundleId "$app")
    echo "Adding: $app $bundleid"
    appList+="$bundleid\n"
    defaults write "$bundleid" NSUserKeyEquivalents "{
            'Rename' = '${F2}';
        }"
    defaults read "$bundleid" NSUserKeyEquivalents
    echo
  fi

  # Safari
  app=/Applications/Safari.app
  if [ -a "$app" ]; then
    echo "Adding: $app"
    bundleid=$(get_BundleId "$app")
    appList+="$bundleid\n"
    defaults write "$bundleid" NSUserKeyEquivalents "{
            'Open Location...' = '\\Uf709';
            'Quit Safari' = '${CMD}${OPT}q';
            'Reload Page' = '\\b';
            'Reload Page From Origin' = '$\\b';
            'Show Sidebar' = '${CMD}$\\U00f1';
            'Show Reader' = '${HYPER}r';
            'Hide Reader' = '${HYPER}r';
        }"
    defaults read "$bundleid" NSUserKeyEquivalents
    echo
  fi

  # Mail
  app=/Applications/Mail.app
  if [ -a "$app" ]; then
    bundleid=$(get_BundleId "$app")
    echo "Adding: $app"
    appList+="$bundleid\n"
    defaults write "$bundleid" NSUserKeyEquivalents "{
            'Send' = '${CMD}${ENTER}';
        }"
    defaults read "$bundleid" NSUserKeyEquivalents
    echo
  fi

  # Mela
  app=/Applications/Mela.app
  if [ -a "$app" ]; then
    bundleid=$(get_BundleId "$app")
    echo "Adding: $app"
    appList+="$bundleid\n"
    defaults write "$bundleid" NSUserKeyEquivalents "{
            'Hide Sidebar' = '${CMD}b';
            'Show Sidebar' = '${CMD}b';
        }"
    defaults read "$bundleid" NSUserKeyEquivalents
    echo
  fi
}

# Make it happen
createKeyboardShortcuts
addEntries
