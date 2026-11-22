# Démos

🇬🇧 [Read in English](README.en.md)

Les animations du [README](../README.md) sont enregistrées avec
[autocast](https://github.com/k9withabone/autocast) à partir de scénarios
écrits en YAML (`<scénario>.yaml`) : les commandes sont réellement exécutées
dans un shell bash et la session est enregistrée au format
[asciinema](https://asciinema.org) (`<scénario>.cast`), puis convertie en GIF
avec [agg](https://github.com/asciinema/agg).

Les fichiers `.cast` se lisent dans la vue fichier de Gitea (lecteur asciinema).

| Scénario | Démo | Prérequis |
|---|---|---|
| `tour.yaml` | message d'accueil, `list`, `show`, `diff` (lecture seule) | LXD |
| `lxc.yaml` | `lxc` seul, sans mise : création d'un profil à partir de son fichier YAML | LXD, profil `unattended-upgrades` non installé |
| `install.yaml` | `install`, diff et confirmation après une modification dans LXD, `import` | LXD, profil `unattended-upgrades` non installé |
| `docker/install.yaml` | [tutoriel Docker](docker/README.md) : clone du dépôt, installation du profil `docker-unprivileged`, lancement d'une instance et suivi de cloud-init | LXD, mise, ni instance `docker` ni profil `docker-unprivileged` |
| `docker/usage.yaml` | [tutoriel Docker](docker/README.md) : `lxc exec`, puis `lxc shell` et commandes Docker dans l'instance | LXD, mise |
| `backrest/install.yaml` | [tutoriel Backrest](backrest/README.md) : profil `app-backrest`, volumes, instance de sauvegarde | LXD, mise, ni instances `backrest` et `app`, ni volumes `backups` et `app-data`, ni profil `app-backrest` |
| `backrest/restore.yaml` | [tutoriel Backrest](backrest/README.md) : restic en ligne de commande, restauration d'un fichier | LXD, mise |

## Enregistrer une démo

Les outils d'enregistrement sont déclarés dans un environnement mise à part
(`mise.demo.toml`) : ils ne sont installés que pour produire les démos.

```shell
MISE_ENV=demo mise run demo <scénario>   # demo/<scénario>.cast et demo/<scénario>.gif
```

`setup.sh` est le préambule masqué de chaque scénario (mise activé, `delta`
comme pager de git). `lxc.yaml` et `install.yaml` installent le profil
`unattended-upgrades` dans LXD (`install.yaml` le modifie aussi et l'importe
dans le dépôt) ; leur épilogue masqué remet le fichier du dépôt dans son état
d'origine et supprime le profil. Ces scénarios refusent de démarrer si ce
profil est déjà installé.

Les scénarios d'un tutoriel sont rangés dans un sous-dossier (`docker/`,
`backrest/`), avec leur propre préambule `setup.sh` (fonctions communes dans
`lib.sh`) : il crée ou vérifie ce dont le scénario a
besoin (instance, profil, clone du dépôt dans un dossier temporaire) et son
épilogue supprime ce que la démo a créé. Ces scénarios laissent le shell
afficher lui-même son prompt (`prompt: ""` côté autocast), pour que le shell
root de l'instance ouvert par `lxc shell` garde le sien.

Les captures d'écran d'une interface web (`backrest/*.png`) sont produites par
`backrest/screenshots.sh` : une instance Debian avec Chromium, pilotée par
Playwright (`screenshots.mjs`), remplit les formulaires de l'interface ; tout
est supprimé à la fin.

`castfix.py` retouche chaque enregistrement : il remet le prompt du shell que
autocast efface (au début et après un `!Clear`) et accélère les points de
progression de `cloud-init status --wait`.

agg dessine lui-même le texte, avec des polices installées par mise dans
l'environnement de démo (rien n'est installé sur le système, qui peut être
sans interface graphique) :
[Inconsolata Nerd Font](https://www.nerdfonts.com) et
[Noto Color Emoji](https://github.com/googlefonts/noto-emoji), passées avec
`--font-dir`.
