#!/bin/sh

#use  the format https://your.url:8443/JSSResource if served on port 8443
jssURL="https://yoururl.jamfcloud.com/JSSResource"
jssUser="admin"
jssPass="password"
newToken="999"
oldToken="999"

# get the ids from the endpoint
ids=$(curl -H "Content-Type: application/xml" -ksu "$jssUser":"$jssPass" "${jssURL}/macapplications" -X GET | xpath "//id[not(ancestor::site)]" 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/','/g)
# parse those ids into an array
IFS=', ' read -r -a allIDs <<< ${ids}

# loop over each id
for curID in ${allIDs[@]};
do
    echo "checking $curID"
    # get the VPP xml subset
    vpp=$(curl -H "Accept : text/xml" -H "Content-Type: text/xml" -ksu "$jssUser":"$jssPass" "$jssURL/macapplications/id/$curID/subset/vpp" -X GET)
    # parse that into the token the current id is using
    token=$(echo $vpp | xpath //vpp/vpp_admin_account_id/text\(\) 2> /dev/null)
    
    # if the old token is being used then switch tokens
	if [ "$token" == "$oldToken" ]; then
		    update=$(curl -H "Accept : text/xml" -H "Content-Type: text/xml" -ksu "$jssUser":"$jssPass" "$jssURL/macapplications/id/$curID" -X PUT -d  "<mac_application>
                <vpp>
                    <vpp_admin_account_id>$newToken</vpp_admin_account_id>
                </vpp>
            </mac_application>")
    echo "******* updated $curID"
	fi
done