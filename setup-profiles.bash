#!/bin/bash

BASEDIR=$(cd "$(dirname "$0")" && pwd)

echo "BASEDIR=$BASEDIR"

# Prerequisite check for yq
if ! command -v yq &> /dev/null
then
    echo "Error: yq is not installed."
    echo "Please install yq to use this script. Refer to https://github.com/mikefarah/yq#install for installation methods."
    exit 1
fi

update_profile() {
    local profile_file="$1"
    local profile_name
    profile_name=$(yq --expression '.name' "$profile_file")

    if [ -z "$profile_name" ]; then
        echo "Error: Could not extract profile name from $profile_file. Skipping."
        return 1
    fi

    echo "--- Profile ${profile_name} (from ${profile_file}) ---"
    if lxc profile show "${profile_name}" &> /dev/null; then
        echo "Profile ${profile_name} already exists. Skipping creation."
    else
        echo "Profile ${profile_name} does not exist. Creating..."
        lxc profile create "${profile_name}"
    fi
    echo "Updating profile..."
    lxc profile edit "${profile_name}" < "${profile_file}"
}

cd "$BASEDIR" || exit

if [ "$#" -eq 0 ]; then
    # No arguments, update all profiles
    echo "No profile specified, updating all profiles..."
    find profiles -type f -name "*.profile.yaml" -print0 | while IFS= read -r -d '' file; do
        update_profile "$file"
    done
else
    # Arguments provided, treat them as file paths
    for file_path in "$@"; do
        if [ -f "$file_path" ]; then
            update_profile "$file_path"
        else
            echo "Error: Profile file '$file_path' not found. Skipping."
        fi
    done
fi
