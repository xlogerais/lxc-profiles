# Demos

🇫🇷 [Lire en français](README.md)

The animations of the [README](../README.en.md) are recorded with
[autocast](https://github.com/k9withabone/autocast) from scenarios written in
YAML (`<scenario>.yaml`): the commands really run in a bash shell and the
session is written as an [asciinema](https://asciinema.org) recording
(`<scenario>.cast`), then rendered as a GIF with
[agg](https://github.com/asciinema/agg).

The `.cast` files can be played in Gitea's file view (asciinema player).

| Scenario | Demo | Prerequisites |
|---|---|---|
| `tour.yaml` | welcome message, `list`, `show`, `diff` (read only) | LXD |
| `lxc.yaml` | plain `lxc`, without mise: create a profile from its YAML file | LXD, profile `unattended-upgrades` not installed |
| `install.yaml` | `install`, diff and confirmation after a change in LXD, `import` | LXD, profile `unattended-upgrades` not installed |
| `docker/install.yaml` | [Docker tutorial](docker/README.en.md): clone the repository, install the `docker-unprivileged` profile, launch an instance and follow cloud-init | LXD, mise, no instance `docker` nor profile `docker-unprivileged` |
| `docker/usage.yaml` | [Docker tutorial](docker/README.en.md): `lxc exec`, then `lxc shell` and Docker commands in the instance | LXD, mise |

## Recording a demo

The recording tools live in a separate mise environment (`mise.demo.toml`), so
they are only installed when making demos:

```shell
MISE_ENV=demo mise run demo <scenario>   # demo/<scenario>.cast and demo/<scenario>.gif
```

`setup.sh` is the hidden preamble of every scenario (mise activated, `delta` as
git pager). `lxc.yaml` and `install.yaml` install the profile
`unattended-upgrades` in LXD (`install.yaml` also modifies it and imports it
into the repository); their hidden epilogue restores the repository file as it
was and deletes the profile. These scenarios refuse to start if that profile is
already installed.

The scenarios of a tutorial live in a subdirectory (`docker/`), with their own
`setup.sh` preamble: it creates or checks what the scenario needs (instance,
profile, clone of the repository in a temporary directory), and its epilogue
removes what the demo created. These scenarios let the shell display its own
prompt (`prompt: ""` for autocast), so that the instance root shell opened by
`lxc shell` keeps its own.

`castfix.py` touches up each recording: it puts back the shell prompt that
autocast drops (at the start and after a `!Clear`) and speeds up the progress
dots of `cloud-init status --wait`.

agg draws the text itself, with fonts installed by mise in the demo environment
(nothing is installed on the system, which can be headless):
[Inconsolata Nerd Font](https://www.nerdfonts.com) and
[Noto Color Emoji](https://github.com/googlefonts/noto-emoji), passed with
`--font-dir`.
