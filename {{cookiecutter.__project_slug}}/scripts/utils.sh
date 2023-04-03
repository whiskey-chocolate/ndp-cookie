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
    bash_profile="$HOME/.bash_profile"

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

