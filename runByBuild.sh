#!/bin/sh

# Run a policy trigger based on != to a target build
# set parameter 4 in the script policy to the target build to not run for
# set parameter 5 to the name of the trigger of the policy that should run

targetBuild=$4
policyTrigger=$5

OSbuild=$(sw_vers -buildVersion)

echo "$OSbuild"
if [ "$OSbuild" != "$targetBuild" ]; then
    echo "running policy"
    /usr/local/bin/jamf policy -event "$policyTrigger"
else 
    echo "Already on target build, not running policy"
    exit 0
fi
