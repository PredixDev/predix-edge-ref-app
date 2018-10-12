# get command line paramaters
CLIENT_ID=$1
SECRET=$2
UAA_URL=$3

echo "usage: get-access-token.sh <clientId> <secret> <uaa-issuerid-url>"

# base64 encide the client and secret
AUTH='Authorization: Basic '$(echo -n $CLIENT_ID:$SECRET | base64)

# curl the UAA token url to get an access tojken
RESULT=$(curl -X POST $UAA_URL  -H "$AUTH" -H 'Content-Type: application/x-www-form-urlencoded' -d grant_type=client_credentials)

# parse out the access token from the result - this requires jq to be installed on your machine (brew install jq)
ACCESS_TOKEN=$( echo "$RESULT" | jq -r '.["access_token"]' )

# copy the access token to the access_token file in the data folder of your app - where the Cloud Gateway container will look for it
printf "%s" "$ACCESS_TOKEN" > ./data/access_token

echo 'token refreshed'
