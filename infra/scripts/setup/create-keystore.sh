#!/usr/bin/env bash
# =====================================================================
#  Crea el keystore de liberación del APK (una sola vez para todo el proyecto)
#  y agrega sus cuatro secretos a secrets.repo.env para load-secrets.sh.
#  El .jks queda FUERA del repo (por defecto en ~/.tdimp/). Guárdalo en un lugar
#  seguro: si se pierde, las nuevas versiones ya no podrán instalarse encima de
#  las anteriores.
#  Uso:   infra/scripts/setup/create-keystore.sh [ruta.jks]
#  Requiere: keytool (viene con el JDK / Android Studio).
# =====================================================================
set -euo pipefail
KEYSTORE="${1:-$HOME/.tdimp/tdimp-upload-keystore.jks}"
ALIAS="upload"
cd "$(dirname "$0")/../../.."

[[ -e "$KEYSTORE" ]] && { echo "✘ $KEYSTORE ya existe; no se sobrescribe." >&2; exit 1; }
mkdir -p "$(dirname "$KEYSTORE")"

read -rsp "Contraseña del keystore (mín. 6 caracteres): " PASS; echo
keytool -genkeypair -v -keystore "$KEYSTORE" \
  -keyalg RSA -keysize 2048 -validity 10000 -alias "$ALIAS" \
  -storepass "$PASS" -keypass "$PASS" \
  -dname "CN=The Day I Made That Promise, OU=IDGS, O=UTCH, L=Chihuahua, ST=Chihuahua, C=MX"

B64="$(base64 < "$KEYSTORE" | tr -d '\n')"
{
  echo "ANDROID_KEYSTORE_BASE64=$B64"
  echo "ANDROID_KEYSTORE_PASSWORD=$PASS"
  echo "ANDROID_KEY_ALIAS=$ALIAS"
  echo "ANDROID_KEY_PASSWORD=$PASS"
} >> secrets.repo.env

echo "✔ Keystore en $KEYSTORE y secretos agregados a secrets.repo.env"
echo "  Siguiente: infra/scripts/setup/load-secrets.sh <owner>/<repo>"
