#!/bin/sh


# Migrate all apps assigned to a VPP account in Jamf Pro to another VPP account.
# If any apps do not have licenses on the new VPP account they will not be migrated, and will need to be handled manually.


################ USER DEFINED VARIABLES START #############################

# Enter credentials and the token id's. If hosting locally use the format https://your.url:8443
# Special characters in the user or password may cause issues with parsing the script
jssURL="https://yoururl.jamfcloud.com"
apiUser="admin"
apiPass="password"
newToken="999"
oldToken="999"

# specify the endpoint and xml node name for applications

# comment this out to switch to mac applications
endpoint="mobiledeviceapplications"
xmlEndpoint="mobile_device_application"

# comment this back in to switch to mac applications
# endpoint="macapplications"
# xmlEndpoint="mac_application"

################ USER DEFINED VARIABLES END #############################


# get all id's and names from the endpoints
allApps=$(curl -H "Content-Type: application/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/$endpoint" -X GET)

allIDs=$( echo "$allApps" | xpath "//id[not(ancestor::site)]" 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/' '/g)

appNames=$( echo "$allApps" | xmllint --xpath '//name' - | sed s/'<name>'//g | sed s/'<\/name>'/','/g)
IFS=',' read -r -a allNames <<< "${appNames}"

# initialize variables to collect failed updates
failedName=""
failedID=""

# loop over each id
for index in ${!allIDs[@]};
do
    echo "checking ${allIDs[index]}"

    # get the VPP xml subset
    token=$(curl -H "Accept : text/xml" -H "Content-Type: text/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/$endpoint/id/${allIDs[index]}/subset/vpp" -X GET | xpath //vpp/vpp_admin_account_id/text\(\) 2> /dev/null)

    # if the old token is being used then switch tokens
	if [ "$token" == "$oldToken" ]; then
		    update=$(curl -H "Accept : text/xml" -H "Content-Type: text/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/$endpoint/id/${allIDs[index]}" -w '%{http_code}' -X PUT -d  "<${xmlEndpoint}>
                <vpp>
                    <vpp_admin_account_id>$newToken</vpp_admin_account_id>
                </vpp>
            </${xmlEndpoint}>" --output /dev/null)
        	echo "******* updating ${allIDs[index]}"
		# report and gather failed updates
		if [ "$update" != "201" ]; then
		    echo "failed $update"
		    failedName+="${allNames[index]}, "
		    failedID+="${allIDs[index]} "
		fi
	fi
done

# Report failed token updates.
if [ "$failedName" != "" ]; then 
    echo "The following apps did not migrate to the new token and will need to be managed manually"
    echo "$failedName"
    echo "The ID's of those apps are as follows"
    echo  "$failedID"
else
    echo "All apps on the old token have been migrated to the new token"
fi
