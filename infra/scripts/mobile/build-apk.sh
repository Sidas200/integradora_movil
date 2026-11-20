#!/usr/bin/env bash
# =====================================================================
#  Compila el APK de release y lo deja en artifacts/<archivo>.
#   - API_BASE_URL (variable de entorno): se pasa con --dart-define. Si está
#     vacía se usa el valor por defecto de lib/core/config/api_config.dart.
#     Debe incluir /api/v1, p. ej. https://tdimp-api-staging.onrender.com/api/v1
#   - versionCode = número de commits (mismo commit → mismo versionCode).
#   - versionName = segundo argumento (p. ej. 1.2.0); si se omite, el de pubspec.yaml.
#  Uso:   API_BASE_URL=<url> infra/scripts/mobile/build-apk.sh <archivo.apk> [version]
# =====================================================================
set -euo pipefail
OUT_FILE="${1:?Uso: build-apk.sh <archivo.apk> [version]}"
BUILD_NAME="${2:-}"
cd "$(dirname "$0")/../../.."

summary() { echo "$1" >> "${GITHUB_STEP_SUMMARY:-/dev/null}"; echo "$1"; }

args=(--release "--build-number=$(git rev-list --count HEAD)")
[[ -n "$BUILD_NAME" ]] && args+=("--build-name=$BUILD_NAME")

if [[ -n "${API_BASE_URL:-}" ]]; then
  args+=("--dart-define=API_BASE_URL=$API_BASE_URL")
  summary "- API: \`$API_BASE_URL\`"
else
  summary "- ⚠ API: variable no configurada; se usa la URL por defecto de \`api_config.dart\`"
fi

flutter build apk "${args[@]}"

mkdir -p artifacts
cp build/app/outputs/flutter-apk/app-release.apk "artifacts/$OUT_FILE"
summary "- APK: \`$OUT_FILE\` ($(du -h "artifacts/$OUT_FILE" | cut -f1))"
