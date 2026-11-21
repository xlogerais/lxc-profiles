# LXD Profiles

This repository contains a collection of LXD profiles and network configurations designed to streamline the deployment and management of LXD containers.

## Directory Structure

- `profiles/`: Contains various LXD profile definitions categorized by their purpose (e.g., applications, networking, storage).
- `network/`: Defines LXD network configurations.
- `docs/`: Additional documentation and helper scripts.
- `demo/`: Animated demos of the mise tasks ([how they are made](demo/README.md)).
- `mise.toml`, `.mise/`: [mise](https://mise.jdx.dev) tasks to manage LXD profiles.

## Demo

![Welcome message, profile list, profile content and diff](demo/tour.gif)

![Install a profile, update it after a change in LXD, import it back](demo/install.gif)

## Usage

Prerequisites: [mise](https://mise.jdx.dev) and the `lxc` client. mise installs the
other tools declared in `mise.toml` (`yq`, `gum`, `delta`, `bat`) with `mise install`.

A short help message is displayed when entering the directory (mise `enter` hook),
and `mise tasks` lists all available tasks.

A profile can be designated by its name (`docker`) or its file
(`profiles/containerization/docker.profile.yaml`).

| Task | Description |
|---|---|
| `mise run list [--all]` | Repository profiles and their state in LXD: ✅ up to date, ⚠️ installed but different, ⬜ not installed. `--all` also shows 🔹 profiles installed in LXD but missing from the repository |
| `mise run show [profile] [--lxd]` | Displays a repository profile (YAML highlighted with `bat`), or with `--lxd` the version installed in LXD |
| `mise run diff [profile...]` | Diff between the installed profile (LXD) and the repository file. Without argument, every installed profile that differs. `--exit-code` returns 1 when there are differences |
| `mise run install [profile...]` | Creates or updates profiles. An existing profile that differs shows its diff and asks for confirmation (`--yes` to skip). Without argument, interactive selection; `--all` for every profile |
| `mise run import [profile] [file]` | Writes an installed LXD profile to the repository (without `used_by`, `project`, empty `config`/`devices`). Defaults to the repository file declaring that name, or `profiles/<profile>.profile.yaml`. Review with `git diff` before committing |

Differences are computed on a normalized form (keys sorted, values as strings,
read-only fields dropped), so formatting or quoting alone never shows up as a
change. Top-level keys unknown to LXD (silently ignored by `lxc profile edit`)
are reported, and `install` refuses such files.

```bash
mise run list --all
mise run diff docker
mise run install docker profiles/applications/traefik.profile.yaml
mise run import s3 profiles/applications/s3.profile.yaml && git diff
```
