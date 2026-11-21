# Demos

The animations of the [README](../README.md) are recorded with
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

agg draws the text itself, with fonts installed by mise in the demo environment
(nothing is installed on the system, which can be headless):
[Inconsolata Nerd Font](https://www.nerdfonts.com) and
[Noto Color Emoji](https://github.com/googlefonts/noto-emoji), passed with
`--font-dir`.
