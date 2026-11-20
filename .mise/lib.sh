# shellcheck shell=bash
# Fonctions partagées par les tâches mise (sourcé, non exécutable).

PROFILES_DIR="${MISE_PROJECT_ROOT:-.}/profiles"

# shellcheck disable=SC2034 # couleurs utilisées par les tâches
if [ -t 1 ]; then
  B=$'\033[1m'; D=$'\033[2m'; R=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'
else
  B=""; D=""; R=""; RED=""; GREEN=""; YELLOW=""; CYAN=""
fi

die()  { echo "${RED}✖${R} $*" >&2; exit 1; }
warn() { echo "${YELLOW}⚠${R} $*" >&2; }
info() { echo "${CYAN}▸${R} $*"; }

# Forme canonique d'un profil, pour comparer dépôt et LXD :
# - seules name/description/config/devices sont conservées (used_by, project... écartés)
# - les valeurs sont converties en chaînes (LXD stocke `cpu: 1` sous la forme "1")
# - les clés sont triées
# Les clés inconnues (ex. `limits:` imbriqué au lieu de `limits.cpu`) sont gardées
# côté dépôt pour apparaître dans le diff : LXD les ignorerait silencieusement.
YQ_NORMALIZE='
  . as $p
  | {
      "name": ($p.name // ""),
      "description": ($p.description // ""),
      "config": (($p.config // {}) | map_values(tostring)),
      "devices": (($p.devices // {}) | map_values(map_values(tostring)))
    }
  + ($p | del(.name, .description, .config, .devices, .used_by, .project))
  | sort_keys(..)
  | (.. | select(tag == "!!str")) style = ""
  | (.. | select(tag == "!!str" and test("\n"))) style = "literal"
'

# Liste "nom<TAB>fichier" des profils du dépôt, triée par nom.
repo_index() {
  local f name
  while IFS= read -r -d '' f; do
    name=$(yq -r '.name // ""' "$f")
    printf '%s\t%s\n' "$name" "${f#"${MISE_PROJECT_ROOT:-.}"/}"
  done < <(find "$PROFILES_DIR" -type f -name '*.profile.yaml' -print0) | sort
}

# Résout un argument (chemin de fichier ou nom de profil) en chemin de fichier.
resolve_file() {
  local arg="$1" matches
  if [ -f "$arg" ]; then
    echo "$arg"
    return
  fi
  matches=$(repo_index | awk -F'\t' -v n="$arg" '$1 == n { print $2 }')
  case "$(printf '%s' "$matches" | grep -c '^')" in
    0) die "Profil '$arg' introuvable dans le dépôt (ni fichier, ni nom)" ;;
    1) echo "$matches" ;;
    *) die "Plusieurs fichiers déclarent le profil '$arg' :"$'\n'"$matches" ;;
  esac
}

profile_name() { yq -r '.name // ""' "$1"; }

is_installed() { lxc profile show "$1" >/dev/null 2>&1; }

normalize_file()      { yq "$YQ_NORMALIZE" "$1"; }
normalize_installed() { lxc profile show "$1" | yq "$YQ_NORMALIZE"; }

# Clés de premier niveau du fichier que LXD ne prendrait pas en compte
# (used_by et project, en lecture seule, sont tolérés : fichiers importés).
unknown_keys() {
  yq -r 'keys - ["name", "description", "config", "devices", "used_by", "project"] | join(", ")' "$1"
}

# 0 si le profil installé est identique au fichier du dépôt.
is_same() {
  local file="$1" name="$2"
  cmp -s <(normalize_file "$file") <(normalize_installed "$name")
}

# Diff unifié : LXD (installé) → dépôt (ce que `install` appliquerait).
# Rendu avec delta dans un terminal. Retourne 1 s'il y a des différences.
show_diff() {
  local file="$1" name="$2" out
  out=$(diff -u --label "lxd:$name (installé)" --label "$file (dépôt)" \
    <(normalize_installed "$name") <(normalize_file "$file")) && return 0
  if [ -t 1 ] && command -v delta >/dev/null 2>&1; then
    delta --paging=never <<<"$out"
  else
    printf '%s\n' "$out"
  fi
  return 1
}

has_tty() { [ -t 1 ] && { : </dev/tty; } 2>/dev/null; }

# Sélection interactive (gum filter) parmi des lignes lues sur stdin.
pick() {
  has_tty && command -v gum >/dev/null 2>&1 || die "Sélection interactive impossible (pas de terminal ou gum absent) : préciser le profil"
  gum filter --header "$1" "${@:2}" </dev/tty
}

# Demande une confirmation oui/non (défaut : non).
confirm() {
  local answer
  if ! has_tty; then
    warn "Pas de terminal pour confirmer (utiliser --yes)"
    return 1
  fi
  if command -v gum >/dev/null 2>&1; then
    gum confirm --default=false --affirmative "Oui" --negative "Non" "$1" </dev/tty >/dev/tty
  else
    read -r -p "$1 [o/N] " answer </dev/tty
    [[ "$answer" =~ ^[oOyY] ]]
  fi
}
