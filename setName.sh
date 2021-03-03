#!/bin/sh

# set the computer name, host name, and local host name of a computer to string + serial + string

prepend=$4
append=$5

serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
compName="$prepend""$serial""$append"

echo "setting computer name:""$compName"
scutil --set ComputerName "$compName"
scutil --set HostName "$compName"
scutil --set LocalHostName "$compName"
