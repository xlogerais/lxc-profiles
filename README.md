# LXD Profiles

This repository contains a collection of LXD profiles and network configurations designed to streamline the deployment and management of LXD containers.

## Directory Structure

- `profiles/`: Contains various LXD profile definitions categorized by their purpose (e.g., applications, networking, storage).
- `network/`: Defines LXD network configurations.
- `docs/`: Additional documentation and helper scripts.
- `install.bash`: A utility script to manage LXD profiles.

## Usage

### `install.bash`

This script allows you to create and update LXD profiles based on the YAML files in the `profiles/` directory.

#### Update all profiles

To update all profiles defined in this repository, run the script without any arguments:

```bash
./install.bash
```

#### Update specific profiles

To update one or more specific profiles, provide their file paths as arguments to the script:

```bash
./install.bash profiles/containerization/docker.profile.yaml profiles/applications/traefik.profile.yaml
```

This will update only the `docker` and `traefik` profiles.
