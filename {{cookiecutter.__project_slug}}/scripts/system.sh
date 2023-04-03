#!/usr/bin/env bash

set -eo pipefail

DC="${DC:-exec}"

# If we're running in CI we need to disable TTY allocation for docker-compose
# commands that enable it by default, such as exec and run.
TTY=""
if [[ ! -t 1 ]]; then
  TTY="-T"
fi


# -----------------------------------------------------------------------------
# Helper system functions start with __ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function __check_arm64() {
    # This function checks whether a given package has a bottle available for the current architecture.
    # It returns true if a bottle is available, false otherwise.
    # Usage: __check_arm64 <package>

    # Accept the package name as an argument
    package="$1"

    # Check if the current architecture is arm64 and set the arch variable
    arch=$(sysctl -n hw.optional.arm64 2>/dev/null | tr -d '\n' | tr -d '\r' && echo "$(uname -m)")

    # Check if the package has a bottle available for the current architecture
    if brew info --json=v1 "$package" | \
        grep -Eo '"bottle":\s*\[[^]]*\]' | \
        sed -E 's/.*"files":\s*\{([^}]*)\}.*/\1/' | \
        awk -v arch="$arch" -F ': ' '$1 == arch { exit 0 } END { exit 1 }'; then
        # If the bottle is available for the current architecture, return true
        return 0
    else
        # If the bottle is not available for the current architecture, return false
        return 1
    fi
}
function __is_package_installed() {
    # Checks if a package is installed using brew and returns true or false accordingly. 
    # Usage: __is_pacakge_installed <package>

    # Accept the package name as an argument
    package="$1"
    if [ -n "$(brew ls --versions $package)" ]; then
        # If the package is installed, return true
        echo "true"
    else
        # If the package is not installed, return false
        echo "false"
    fi
}

function __install_dependencies {
    # Installs a list of dependencies with the appropriate arch flag, depending on the architecture of the system. 
    # Usage: __install_dependencies <dependencies>

    # Define a list of dependencies
    dependencies=("jq" "tmux" "tmuxinator")

    # Iterate over the dependencies and install them with the appropriate arch flag
    for package in "${dependencies[@]}"; do
        if ! ($(is_package_installed "$package")); then
            # If the package is not installed, install it with the appropriate arch flag
            echo "$package: installing"
            if check_arm64 "$package"; then
                brew install "$package"
            else
                arch -arm64 brew install "$package"
            fi
        else
            # If the package is already installed, skip it
            echo "$package: already installed"
        fi
    done
}

function {{cookiecutter.__package_name}}_is_live {
    # Checks the status of an API endpoint and returns whether it is live or not. 
    # Usage: __is_live 

    # Send a GET request to the API endpoint and get the response
    response=$(curl -s -w "\n%{http_code}" -X GET https://{{cookiecutter.__package_name}}-api.local)

    # Get the body of the response
    body=$(echo "$response" | head -n 1)

    # Get the HTTP status code of the response
    status=$(echo "$response" | tail -n 1)

    # Check if the status code is 200 and if the database in the response body is "ok"
    if [ "$status" -eq 200 ] && [ "$(echo "$body" | jq -r '.database')" == "ok" ]; then
        # If the status code is 200 and the database is "ok", return "{{cookiecutter.__package_name}} status: live"
        echo "{{cookiecutter.__package_name}} status: live"
    else
        echo "{{cookiecutter.__package_name}} status: error"
    fi
}

function __build_from_ndp {
    # Builds the {{cookiecutter.__package_name}}-api container from the NDP.
    # Usage: __build_from_ndp

    # Create a virtual environment to isolate our cookiecutter locally
    python3 -m venv env
    source env/bin/activate  # On Windows use `env\Scripts\activate`

    # Install cookiecutter into the virtual environment
    pip install cookiecutter

    # Set up a new ndp project 
    cookiecutter https://github.com/whiskey-chocolate/ndp-cookie.git
}
# -----------------------------------------------------------------------------
# System functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function install_{{cookiecutter.__package_name}} {
    # Installs {{cookiecutter.__package_name}} and its dependencies.
    __build_from_ndp

    # Sets up tmuxinator aliases and .config files

    # Adds the {{cookiecutter.__package_name}}-api.local domain to /etc/hosts

    # Installs local certificates

    # Updates the env file with the correct values

    # Tells user to go to firebase and download the google-services.json file
}

function start_{{cookiecutter.__package_name}} {
    # Starts {{cookiecutter.__package_name}} via docker-compose.

    # Checks the /status API endpoint

    # Enters PSQL in the db container

}
