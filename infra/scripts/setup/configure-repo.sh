#!/usr/bin/env bash
# =====================================================================
#  Configura el repositorio de la app móvil igual que integradora:
#  dev como rama por defecto, solo squash merge y ramas borradas al fusionar.
#  Uso:   infra/scripts/setup/configure-repo.sh <owner>/<repo>
#  Requiere: gh (autenticado con `gh auth login`).
# =====================================================================
set -euo pipefail
REPO="${1:?Uso: configure-repo.sh <owner>/<repo>}"

# dev por defecto: los PR apuntan ahí y workflow_dispatch lee sus workflows
gh repo edit "$REPO" --default-branch dev --delete-branch-on-merge \
  --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false
echo "✔ dev por defecto, solo squash merge, ramas borradas al fusionar"

if ! gh api "repos/$REPO/branches/main" >/dev/null 2>&1; then
  echo "⚠ No existe la rama main. Créala desde dev cuando haya una versión estable:"
  echo "    git switch dev && git pull && git switch -c main && git push -u origin main"
fi
