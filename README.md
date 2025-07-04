# LXD Profiles

This repository contains a collection of LXD profiles and network configurations designed to streamline the deployment and management of LXD containers.

## Directory Structure

- `profiles/`: Contains various LXD profile definitions categorized by their purpose (e.g., applications, networking, storage).
- `network/`: Defines LXD network configurations.
- `docs/`: Additional documentation and helper scripts.
- `setup-profiles.bash`: A utility script to manage LXD profiles.

## Usage

### `setup-profiles.bash`

This script allows you to create and update LXD profiles based on the YAML files in the `profiles/` directory.

#### Update all profiles

To update all profiles defined in this repository, run the script without any arguments:

```bash
./setup-profiles.bash
```

#### Update specific profiles

To update one or more specific profiles, provide their names as arguments to the script:

```bash
./setup-profiles.bash docker traefik
```

This will update only the `docker` and `traefik` profiles.