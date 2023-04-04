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
    target="bash $HOME/$dir/run.sh"
    add_alias "{{cookiecutter.__package_name}}_run" "$target"
}

function install {
    echo "{{cookiecutter.__project_slug}} dev environment installed!"
    # Installs a_test and its dependencies.
    echo "1. Installing dependencies..."
    install_dependencies

    # Sets up tmuxinator aliases and .config files
    echo "2. Setting up tmuxinator..."
    add_alias_for_run_commands

    # Adds the {{cookiecutter.__project_slug}}-api.local domain to /etc/hosts
    echo "3. Adding {{cookiecutter.__project_slug}}-api.local to /etc/hosts..."
    add_domain_to_hosts {{cookiecutter.__project_slug}}-api.local

    # Installs local certificates
    echo "4. Installing local certificates..."

    # Updates the env file with the correct values
    echo "5. Updating .env file..."

    # Tells user to go to firebase and download the google-services.json file
    echo "6. Set up firebase..." 

    echo "{{cookiecutter.__project_slug}} dev environment installed!"
}

install