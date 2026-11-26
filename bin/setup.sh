#!/usr/bin/env bash
# Enables the git hooks in bin/git_hooks for this clone. Run once after cloning.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath bin/git_hooks
echo "git hooks enabled (core.hooksPath = bin/git_hooks)"
