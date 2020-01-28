#!/bin/sh


# Migrate a set of app id's to a given token and set them to assign or not assign vpp content


################ USER DEFINED VARIABLES START #############################

# Enter credentials and the token id's. If hosting locally use the format https://your.url:8443
# Special characters in the user or password may cause issues with parsing the script
jssURL="https://yoururl.jamfcloud.com"
apiUser="admin"
# apiPass="password"
read -s -p "Password: " apiPass

# set to "true" to turn use managed distribution, set to "false" to turn off managed distribution
assignVPPContent="true"

# set newToken to -1 to assign to no token, otherwise set to the token's id
newToken="999"

# paste space separated ids between double quotes
ids=""

# specify the endpoint and xml node name for applications

# comment this out to switch to mac applications
endpoint="mobiledeviceapplications"
xmlEndpoint="mobile_device_application"

# comment this back in to switch to mac applications
# endpoint="macapplications"
# xmlEndpoint="mac_application"

################ USER DEFINED VARIABLES END #############################


failedID=""
for id in ${ids[@]}; do
    echo "updating $id"
    update=$(curl -H "Accept : text/xml" -H "Content-Type: text/xml" -ksu "$apiUser":"$apiPass" "$jssURL/JSSResource/$endpoint/id/$id" -w '%{http_code}' -X PUT -d  "<${xmlEndpoint}>
        <vpp>
            <assign_vpp_device_based_licenses>$assignVPPContent</assign_vpp_device_based_licenses>
            <vpp_admin_account_id>$newToken</vpp_admin_account_id>
        </vpp>
    </${xmlEndpoint}>" --output /dev/null)
    # report and gather failed updates
    if [ "$update" != "201" ]; then
        echo "failed $update"
        failedID+="$id "
    fi
done


# Report failed token updates.
if [ "$failedID" != "" ]; then 

    echo "The following ids could not be set"
    echo  "$failedID"
else
    echo "All apps have been assigned"
fi
