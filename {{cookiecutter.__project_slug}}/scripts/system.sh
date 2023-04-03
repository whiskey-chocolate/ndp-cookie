#!/usr/bin/env bash

set -eo pipefail

DC="${DC:-exec}"

# If we're running in CI we need to disable TTY allocation for docker-compose
# commands that enable it by default, such as exec and run.
TTY=""
if [[ ! -t 1 ]]; then
  TTY="-T"
fi


function a_test_is_live {
    # Checks the status of an API endpoint and returns whether it is live or not. 
    # Usage: __is_live 

    # Send a GET request to the API endpoint and get the response
    response=$(curl -s -w "\n%{http_code}" -X GET https://a_test-api.local)

    # Get the body of the response
    body=$(echo "$response" | head -n 1)

    # Get the HTTP status code of the response
    status=$(echo "$response" | tail -n 1)

    # Check if the status code is 200 and if the database in the response body is "ok"
    if [ "$status" -eq 200 ] && [ "$(echo "$body" | jq -r '.database')" == "ok" ]; then
        # If the status code is 200 and the database is "ok", return "a_test status: live"
        echo "a_test status: live"
    else
        echo "a_test status: error"
    fi
}

# -----------------------------------------------------------------------------
# System functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function start_a_test {
    # Starts a_test via docker-compose.
    echo "Starts a_test via docker-compose."

    # Checks the /status API endpoint

    # Enters PSQL in the db container

}
