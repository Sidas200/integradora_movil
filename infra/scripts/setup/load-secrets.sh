#!/usr/bin/env bash
# =====================================================================
#  Paso 4 de la práctica: carga secretos y variables desde archivos locales
#  que NUNCA se versionan (están en .gitignore como .env).
#  Uso:   infra/scripts/setup/load-secrets.sh <owner>/<repo>
#  Espera:  secrets.repo.env  (formato CLAVE=valor), p. ej. ANDROID_KEYSTORE_BASE64,
#           ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD,
#           VAR_API_BASE_URL_STAGING, VAR_API_BASE_URL_PROD
#  Las líneas que empiezan con VAR_ se guardan como variables (no secretas) sin el prefijo.
# =====================================================================
set -euo pipefail
REPO="${1:?Uso: load-secrets.sh <owner>/<repo>}"
cd "$(dirname "$0")/../../.."

load() {
  local file="$1" env="${2:-}"
  [[ -f "$file" ]] || { echo "↷ $file no existe, se omite"; return; }
  # Se separa solo en el primer "=": el relleno "=" del base64 del keystore se conserva.
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
    local key="${line%%=*}" value="${line#*=}"
    local scope=()
    [[ -n "$env" ]] && scope=(--env "$env")
    if [[ "$key" == VAR_* ]]; then
      gh variable set "${key#VAR_}" --repo "$REPO" "${scope[@]}" --body "$value"
    else
      gh secret set "$key" --repo "$REPO" "${scope[@]}" --body "$value"
    fi
    echo "  ✔ ${env:-repo}: $key"
  done < "$file"
}

load secrets.repo.env
echo "✔ Secretos cargados. Borra los archivos .env locales si ya no los necesitas."
