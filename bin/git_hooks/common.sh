# shellcheck shell=bash
# Shared helpers and checks for the hooks in this directory. Sourced by the hooks, not run.
# The same file in every repo; the generic version is in ~/workspace/templates/git-hooks.
# Only checks that several repos use live here. A check for one repo (or one kind of repo, e.g. secret repos)
# goes into that repo's own pre-commit. Tools come from the repo's dev shell (flake.nix, devShells.default),
# never from the system: see devshell and require below.

# --- settings ---
PROTECTED_BRANCHES="main master"
# Commit subjects: "<type>: <lowercase summary>" with one of these types.
COMMIT_TYPES='feat|fix|chore|refactor|docs|test|perf|ci|build|revert|release'
# Pushes go to Forgejo, through the ssh alias only: forgejo:homelab/<repo>.git.
FORGE_RE='^forgejo:'
# Paths that look like secrets or runtime data. Exceptions: *.example, *.pub.
SENSITIVE_RE='(^|/)(\.env([.-][^/]*)?|[^/]+\.env|acme\.json|id_(rsa|ecdsa|ed25519)[^/]*|[^/]*credentials[^/]*\.(json|ya?ml))$|\.(log|pem|key|p12|pfx|kdbx|sqlite3?|db)$|(^|/)(logs?|letsencrypt)/'
SENSITIVE_OK_RE='\.(example|pub)$'
COMPOSE_RE='(^|/)(docker-)?compose[^/]*\.ya?ml$'
# Staged files above this size are refused, unless their path (or a glob) is listed in ALLOW_LARGE.
MAX_FILE_BYTES=$((2 * 1024 * 1024))
ALLOW_LARGE=bin/git_hooks/allow-large

if [ -t 2 ]; then
  RED=$'\e[31m' YELLOW=$'\e[33m' BOLD=$'\e[1m' RESET=$'\e[0m'
else
  RED='' YELLOW='' BOLD='' RESET=''
fi
HOOK=$(basename "$0")
FAILED=0
STAGE_DIR=''
trap '[ -z "$STAGE_DIR" ] || rm -rf "$STAGE_DIR"' EXIT

# --- helpers ---

# fail <check> <message> [hint]: report a failed check. finish exits 1 if any check failed.
fail() {
  printf '%s%s [%s]%s %s\n' "$RED$BOLD" "$HOOK" "$1" "$RESET" "$2" >&2
  [ -z "${3:-}" ] || printf '    %s-> %s%s\n' "$YELLOW" "$3" "$RESET" >&2
  FAILED=1
}

finish() {
  if [ "$FAILED" -ne 0 ]; then
    printf '%s%s: refused.%s Fix the above and try again.\n' "$RED$BOLD" "$HOOK" "$RESET" >&2
    exit 1
  fi
  exit 0
}

# devshell: load the repo's dev shell (flake.nix devShells.default) into this hook, so the checks use its tools.
# Call it first thing in hooks that need tools. Skipped when nix can't reach its daemon (the Claude Code sandbox,
# for one): require then says what is missing. HOOKS_DEVSHELL=<repo root> marks it as loaded already (e.g. in CI).
devshell() {
  local root v unset=()
  root=$(git rev-parse --show-toplevel)
  [ "${HOOKS_DEVSHELL:-}" != "$root" ] || return 0
  [ -f "$root/flake.nix" ] && command -v nix >/dev/null && nix store info >/dev/null 2>&1 || return 0
  # nix's git fetcher must not see git's GIT_* variables (GIT_DIR, GIT_INDEX_FILE, ...); only the nix call loses them.
  for v in $(compgen -e | grep '^GIT_'); do unset+=(-u "$v"); done
  local env
  if ! env=$(env "${unset[@]}" nix print-dev-env --option warn-dirty false "$root"); then
    fail devshell "the dev shell of flake.nix doesn't evaluate (above)" "fix flake.nix; --no-verify only if this failure is expected and intended (e.g. a commit that fixes flake.nix itself)"
    finish
  fi
  eval "$env"
  set +e -uo pipefail # print-dev-env's script may change shell options
  export HOOKS_DEVSHELL=$root
}

# require <tool...>: the tools are on PATH; otherwise fail and return 1.
require() {
  local t rc=0
  for t in "$@"; do
    command -v "$t" >/dev/null && continue
    fail "$t" "$t is not on PATH" "add it to devShells.default in flake.nix; inside the Claude Code sandbox the dev shell can't load: commit outside it"
    rc=1
  done
  return "$rc"
}

# staged_files [regex]: staged files (added, copied, modified, renamed) whose path matches regex, one per line.
staged_files() {
  git diff --cached --name-only --diff-filter=ACMR | grep -E "${1:-.}"
}

# added_lines <file>: the lines the staged change adds to <file>.
added_lines() {
  git diff --cached -U0 --no-color -- "$1" | grep -E '^\+' | grep -vE '^\+\+\+ ' | cut -c2-
}

# staged_copy <files...>: writes the staged version of the files into $STAGE_DIR (same relative paths).
# Files that aren't in the index are skipped, so optional config files can be passed along.
staged_copy() {
  [ -n "$STAGE_DIR" ] || STAGE_DIR=$(mktemp -d)
  local f
  for f in "$@"; do
    git cat-file -e ":$f" 2>/dev/null || continue
    mkdir -p "$STAGE_DIR/$(dirname "$f")"
    git show ":$f" >"$STAGE_DIR/$f"
  done
}

current_branch() { git branch --show-current; }

is_protected() { [ -n "$1" ] && [[ " $PROTECTED_BRANCHES " == *" $1 "* ]]; }

# The commit message rules: shown in the editor by prepare-commit-msg and on a refusal by commit-msg.
commit_rules() {
  cat <<EOF
<type>: <lowercase summary>    e.g. "fix: pin the traefik image tag"
  type: ${COMMIT_TYPES//|/, }
  optional body after a blank line: what changed and why
  no Co-Authored-By or other AI attribution lines
EOF
}

# --- checks ---

# No commits on main/master (the first commit of a new repo is fine). --no-verify only for an intended commit on main.
check_protected_branch() {
  local b
  b=$(current_branch)
  git rev-parse -q --verify HEAD >/dev/null || return 0
  is_protected "$b" || return 0
  fail protected-branch "no commits on '$b': it only changes through pull requests on Forgejo" \
    "work on a task branch: git switch -c <task>, or a worktree (see AGENTS.md)"
}

# Branch names are short kebab-case task names (they double as worktree directory names).
check_branch_name() {
  local b
  b=$(current_branch)
  [ -n "$b" ] && ! is_protected "$b" || return 0
  [[ $b =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && return 0
  fail branch-name "branch '$b' is not a kebab-case task name (e.g. git-hooks)" "rename it: git branch -m <task>"
}

# Secret files and runtime data never get staged. Optional argument: extra regex for this repo.
check_sensitive_paths() {
  local re="$SENSITIVE_RE${1:+|$1}" f
  while IFS= read -r f; do
    fail sensitive-path "$f looks like a secret or runtime file" \
      "unstage it (git rm --cached -- '$f') and add it to .gitignore"
  done < <(staged_files "$re" | grep -vE "$SENSITIVE_OK_RE")
}

# No staged file over MAX_FILE_BYTES, unless ALLOW_LARGE (its staged version) lists it: one path or glob per line.
check_large_files() {
  local f p size allow=()
  if git cat-file -e ":$ALLOW_LARGE" 2>/dev/null; then
    mapfile -t allow < <(git show ":$ALLOW_LARGE" | sed -E 's/#.*//; s/[[:space:]]+$//' | grep -v '^$')
  fi
  while IFS= read -r -d '' f; do
    size=$(git cat-file -s ":$f")
    [ "$size" -gt "$MAX_FILE_BYTES" ] || continue
    for p in "${allow[@]}"; do
      # shellcheck disable=SC2053 # $p is a glob on purpose
      [[ $f == $p ]] && continue 2
    done
    fail large-file "$f is $(awk -v s="$size" 'BEGIN { printf "%.2f", s / 1048576 }') MB (limit $((MAX_FILE_BYTES / 1048576)) MB)" \
      "keep it out of git; if it really belongs here, add its path to $ALLOW_LARGE"
  done < <(git diff --cached --name-only --diff-filter=ACMR -z)
}

# Secret scan of the staged changes (betterleaks).
check_secrets() {
  require betterleaks || return 0
  local out rc
  out=$(betterleaks git --pre-commit --staged --redact --no-banner --verbose --exit-code 3 . 2>&1)
  rc=$?
  if [ "$rc" -eq 3 ]; then
    printf '%s\n' "$out" >&2
    fail secrets "betterleaks found a possible secret in the staged changes (above, redacted)" \
      "remove it; a false positive gets a 'betterleaks:allow' comment on its line"
  elif [ "$rc" -ne 0 ]; then
    printf '%s\n' "$out" >&2
    fail secrets "betterleaks failed to run (above)"
  fi
}

# Staged .nix files are nixfmt-formatted and statix-clean (generated hardware-configuration.nix excepted).
# A staged statix.toml at the repo root applies.
check_nix() {
  local files f
  mapfile -t files < <(staged_files '\.nix$' | grep -v 'hardware-configuration\.nix$')
  [ ${#files[@]} -gt 0 ] || return 0
  require nixfmt statix || return 0
  staged_copy "${files[@]}" statix.toml
  (cd "$STAGE_DIR" && nixfmt --check "${files[@]}") ||
    fail nixfmt "staged .nix files are not formatted (above)" "run nixfmt on them, then git add"
  for f in "${files[@]}"; do
    (cd "$STAGE_DIR" && statix check -o errfmt "$f" >&2) ||
      fail statix "$f has statix warnings (above)" "fix them, or try: statix fix $f"
  done
}

# Staged YAML passes yamllint: relaxed rules and errors only, or the repo's staged .yamllint config if there is one.
check_yaml() {
  local files conf=(-d relaxed) c
  mapfile -t files < <(staged_files '\.ya?ml$')
  [ ${#files[@]} -gt 0 ] || return 0
  require yamllint || return 0
  staged_copy "${files[@]}" .yamllint .yamllint.yaml .yamllint.yml
  for c in .yamllint .yamllint.yaml .yamllint.yml; do
    [ -f "$STAGE_DIR/$c" ] && conf=(-c "$c") && break
  done
  (cd "$STAGE_DIR" && yamllint "${conf[@]}" --no-warnings -f parsable "${files[@]}" >&2) ||
    fail yamllint "staged YAML has errors (above)"
}

# A changed compose file still parses: docker-compose config on the staged version, no .env needed.
check_compose() {
  local files f
  mapfile -t files < <(staged_files "$COMPOSE_RE")
  [ ${#files[@]} -gt 0 ] || return 0
  require docker-compose || return 0
  staged_copy "${files[@]}"
  for f in "${files[@]}"; do
    (cd "$STAGE_DIR/$(dirname "$f")" &&
      docker-compose -f "$(basename "$f")" config -q --no-interpolate --no-env-resolution) ||
      fail compose "$f: docker-compose config failed (above)"
  done
}

# New or changed image: lines pin a version (no :latest, :pr-*, or missing tag).
check_image_tags() {
  local files f line img tag
  mapfile -t files < <(staged_files "$COMPOSE_RE")
  for f in "${files[@]}"; do
    while IFS= read -r line; do
      img=$(sed -E 's/^[[:space:]]*image:[[:space:]]*//; s/[[:space:]]+#.*//; s/["'"'"']//g; s/\$\{[A-Za-z0-9_]+:-([^}]*)\}/\1/g' <<<"$line")
      [[ $img == *@sha256:* ]] && continue
      tag=${img##*/}
      if [[ $tag == *:* ]]; then tag=${tag##*:}; else tag=''; fi
      if [ -z "$tag" ] || [ "$tag" = latest ] || [[ $tag == pr-* ]]; then
        fail image-tag "$f: image '$img' is not pinned" "use a fixed version tag or an @sha256 digest"
      fi
    done < <(added_lines "$f" | grep -E '^[[:space:]]*image:')
  done
}

# pre-push: the remote is Forgejo (ssh alias). Arguments: remote name, remote URL.
check_push_remote() {
  [[ $2 =~ $FORGE_RE ]] && return 0
  fail remote "remote '$1' ($2) is not Forgejo: pushes go through the ssh alias forgejo: only" \
    "push to origin (forgejo:homelab/<repo>.git)"
}

# pre-push: no ref update of main/master. Argument: the remote ref.
check_push_ref() {
  local b=${1#refs/heads/}
  [ "$b" != "$1" ] && is_protected "$b" || return 0
  fail protected-branch "no pushes to '$b': it only changes through pull requests on Forgejo" \
    "push your task branch (git push -u origin <task>) and open a pull request"
}
