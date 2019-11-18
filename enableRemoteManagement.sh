#!/bin/sh

# enable a specific user for remote access
# set parameter 4 to the username that remote access should be enabled for

# NOTE: The user must exist for this to work

# note that if this is called from within terminal, even if via the jamf binary, then terminal will need to have full disk access
# If it is run by a recurring check-in via Jamf then it will automatically have full disk access

adminUser="$4"

# change the the name to access_ssh to limit it to specific users
/usr/bin/dscl . change /Groups/com.apple.access_ssh-disabled RecordName com.apple.access_ssh-disabled com.apple.access_ssh

# in some instances the group may have been deleted. Uncomment this to recreate the group
# dscl . create /Groups/com.apple.access_ssh

# Add the user's uuid to access_ssh group members
/usr/bin/dscl . append /Groups/com.apple.access_ssh groupmembers $(dscl . read /Users/"$adminUser" GeneratedUID | cut -d " " -f 2)
/usr/sbin/systemsetup -setremotelogin on

# Enable remote management via kickstart
# NOTE: for full access the screensharing agent must be whitelisted via a PPPC payload as per: https://support.apple.com/en-us/HT209161
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users $adminUser -access -on -privs -all
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -activate -restart -console