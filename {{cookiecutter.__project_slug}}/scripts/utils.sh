#!/usr/bin/env bash


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


function add_alias {
    alias_name="$1"
    alias_command="$2"
    bash_profile="$HOME/.dotfiles/chocolate/.aliases"

    # Check if alias already exists
    if grep -q "alias $alias_name=" "$bash_profile"; then
        echo "Alias $alias_name already exists"
    else
        echo "Adding alias $alias_name..."
        echo "alias $alias_name=\"$alias_command\"" >> "$bash_profile"
        source "$bash_profile"
    fi
}

function get_script_dir() {
  local script="$0"
  local dir="$(cd "$(dirname "$script")" >/dev/null 2>&1 && pwd)"
  echo "$dir"
}
function add_alias_for_tmuxinator {
    # Adds an alias for tmuxinator
    # Usage: add_alias_for_tmuxinator

    unlink "$HOME/.config/tmuxinator/{{cookiecutter.__project_slug}}.yml" 2>/dev/null
    # Get the path to the tmuxinator config file
    tmuxinator_config_file="./.tmuxinator.yml"
    ln "$tmuxinator_config_file" "$HOME/.config/tmuxinator/{{cookiecutter.__project_slug}}.yml"

    # Add an alias for tmuxinator
    add_alias "{{cookiecutter.__package_name}}_tmuxinator" "tmuxinator start {{cookiecutter.__project_slug}}"

}

function add_domain_to_hosts {
  local domain="$1"
  local hosts_file="/private/etc/hosts"
  local existing_entry=$(grep -E "^127\.0\.0\.1\s+" "$hosts_file")

  if [[ -n "$existing_entry" ]]; then
    echo "Appending domain to existing entry in hosts file..."
    sudo sed -i '' "s|^127\.0\.0\.1\s*.*|& $domain|" "$hosts_file"
    echo "Domain appended to existing entry in hosts file."
  else
    echo "Adding new entry to hosts file..."
    echo "127.0.0.1 $domain" | sudo tee -a "$hosts_file" > /dev/null
    echo "New entry added to hosts file."
  fi
}

function install_local_certificates {
    local domain="$1"
    (mkdir certs && cd certs && mkcert -key-file "domain-key.pem" -cert-file "domain.pem" "$domain" localhost 127.0.0.1 ::1 )
}

function move_env_example() {
    if [ -f ".env.example" ]; then
        mv .env.example .env
        echo ".env.example moved to .env"
    else
        echo "No .env.example file found"
    fi
}

function update_secret_key() {
    # Generate a new key and save it to a file
    # openssl rand -out /tmp/newkey.key 32
    openssl rand -out /tmp/newkey.key -base64 32 | tr -d '/+' | head -c 32
    echo "Generated new key: $(cat /tmp/newkey.key)"

    # Read the .env file into a variable
    env_file=".env"
    env_contents=$(cat "$env_file")

    # Replace the existing SECRET_KEY value with the new key (with quotes)
    # new_contents=$(echo "$env_contents" | sed -E "s/^SECRET_KEY=.*/SECRET_KEY=\"$(cat /tmp/newkey.key )\"/")
    new_contents=$(echo "$env_contents" | sed -E "s#^SECRET_KEY=.*#SECRET_KEY=\"$(cat /tmp/newkey.key)\"#")

    # Save the updated contents back to the .env file
    echo "$new_contents" > "$env_file"

    # Clean up the temporary key file
    rm /tmp/newkey.key

    # Print a message to confirm the key was updated
    echo "SECRET_KEY updated."
}
