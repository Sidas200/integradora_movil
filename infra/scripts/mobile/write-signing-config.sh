#!/usr/bin/env bash
# =====================================================================
#  Genera android/key.properties (NO versionado) a partir de los secretos
#  ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS y
#  ANDROID_KEY_PASSWORD. El keystore se escribe fuera del repo ($RUNNER_TEMP).
#  Si falta alguno, no falla: Gradle firma con la clave de depuración y se
#  deja un aviso en el resumen de la ejecución.
#  Uso:   infra/scripts/mobile/write-signing-config.sh
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")/../../.."

summary() { echo "$1" >> "${GITHUB_STEP_SUMMARY:-/dev/null}"; echo "$1"; }

for var in ANDROID_KEYSTORE_BASE64 ANDROID_KEYSTORE_PASSWORD ANDROID_KEY_ALIAS ANDROID_KEY_PASSWORD; do
  if [[ -z "${!var:-}" ]]; then
    summary "### ⚠ APK firmado con la clave de depuración: falta el secreto $var"
    rm -f android/key.properties
    exit 0
  fi
done

KEYSTORE="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/tdimp-upload-keystore.jks"
echo "$ANDROID_KEYSTORE_BASE64" | base64 --decode > "$KEYSTORE"

cat > android/key.properties <<EOF
storeFile=$KEYSTORE
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
keyPassword=$ANDROID_KEY_PASSWORD
EOF

summary "### ✔ APK firmado con el keystore de liberación (alias \`$ANDROID_KEY_ALIAS\`)"
