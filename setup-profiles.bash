#!/bin/bash

BASEDIR=$(cd "$(dirname "$0")" && pwd)

echo "BASEDIR=$BASEDIR"

update_profile() {
    local profile_name="$1"
    local profile_file="$2"

    echo "--- Profile ${profile_name} ---"
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
        name=$(basename "$file" .profile.yaml)
        update_profile "$name" "$file"
    done
else
    # Arguments provided, update specified profiles
    for profile_name in "$@"; do
        # Find the profile file. Since the directory structure is nested, use find.
        profile_file=$(find profiles -type f -name "${profile_name}.profile.yaml" | head -n 1)

        if [ -f "$profile_file" ]; then
            update_profile "$profile_name" "$profile_file"
        else
            echo "Profile file for '${profile_name}' not found in 'profiles/' directory."
        fi
    done
fi