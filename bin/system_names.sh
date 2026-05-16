#!/bin/sh

echo
echo '==== System Configuration, ComputerName:'
scutil --get ComputerName

echo
echo '==== System Configuration, LocalHostName:'
scutil --get LocalHostName

echo
echo '==== System Configuration, HostName:'
scutil --get HostName

echo
echo '==== hostname command:'
hostname

echo
echo '==== System Configuration, NetBIOS name:'
echo 'show State:/Network/NetBIOS foo' | scutil

echo
echo '==== SystemConfiguration plist file reports various Name':
plutil -p /Library/Preferences/SystemConfiguration/preferences.plist | grep '"HostName"'
plutil -p /Library/Preferences/SystemConfiguration/preferences.plist | grep '"LocalHostName"'
plutil -p /Library/Preferences/SystemConfiguration/preferences.plist | grep '"ComputerName"'

echo
echo '==== nvram reports computer-name'
nvram -p | grep computer-name

echo
echo '==== System Configuration, Setup:/System :'
echo 'show Setup:/System foo' | scutil

echo
echo '==== System Configuration, Setup:/Network/HostNames :'
echo 'show Setup:/Network/HostNames foo' | scutil

# echo
# echo '==== System Configuration, Setup:/Network/HostNames/LocalHostName :'
# echo 'show Setup:/Network/HostNames LocalHostName' | scutil

echo
echo '==== defaults system, value for NetBIOSName:'
defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName

echo
echo '==== NetworkSetup reports ComputerName:'
networksetup -getcomputername

echo
echo '==== Active Directory computer object name:'
dsconfigad -show | grep -i 'Computer' | awk -F "= " '{printf $NF}'
