# get command line paramaters

set -e

CLIENT_ID=$1
SECRET=$2
UAA_URL=$3

echo "usage: createAccessTokenFile <clientId> <secret> <uaa-issuerid-url>"

# base64 encide the client and secret
AUTH='Authorization: Basic '$(echo -n $CLIENT_ID:$SECRET | base64)

# curl the UAA token url to get an access tojken
RESULT=$(curl -X POST $UAA_URL  -H "$AUTH" -H 'Content-Type: application/x-www-form-urlencoded' -d grant_type=client_credentials)

# parse out the access token from the result - this requires jq to be installed on your machine (brew install jq)
if [[ $( echo "$RESULT" | jq 'has("access_token")') == true ]]; then
  ACCESS_TOKEN=$( echo "$RESULT" | jq -r '.["access_token"]' )
  # copy the access token to the access_token file in the data folder of your app - where the Cloud Gateway container will look for it
  mkdir -p ./data
  printf "%s" "$ACCESS_TOKEN" > ./data/access_token
  chmod -R 777 data
  echo 'token refreshed'
else
  echo "Coult not fetch token : $RESULT"
  echo "Please check if the paramters passed are correct"
  echo "$CLIENT_ID $SECRET $UAA_URL"
  echo "CURL COMAND : curl -X POST $UAA_URL  -H "$AUTH" -H 'Content-Type: application/x-www-form-urlencoded' -d grant_type=client_credentials"
  mkdir -p ./data
  printf "%s" "" > ./data/access_token
  chmod -R 777 data
  exit 1
fi
