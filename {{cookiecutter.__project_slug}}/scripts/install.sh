#!/usr/bin/env bash

source "scripts/utils.sh"

function install_dependencies {
    # Installs a list of dependencies with the appropriate arch flag, depending on the architecture of the system. 
    # Usage: install_dependencies 

    # Define a list of dependencies
    dependencies=("jq" "tmux" "tmuxinator")

    # Iterate over the dependencies and install them with the appropriate arch flag
    for package in "${dependencies[@]}"; do
        if ! ($(__is_package_installed "$package")); then
            # If the package is not installed, install it with the appropriate arch flag
            echo "$package: installing"
            if __check_arm64 "$package"; then
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

function add_alias_for_run_commands {
    dir="$(get_script_dir)"
    target="bash $HOME/$pwd/run.sh"
    add_alias "{{cookiecutter.__package_name}}_run" "$target"
}
function install {
    # Installs a_test and its dependencies.
    install_dependencies

    # Sets up tmuxinator aliases and .config files
    add_alias_for_run_commands

    # Adds the a_test-api.local domain to /etc/hosts

    # Installs local certificates

    # Updates the env file with the correct values

    # Tells user to go to firebase and download the google-services.json file
}

install