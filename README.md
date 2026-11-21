# integradora_movil

App móvil (Flutter) de *The Day I Made That Promise*. Consume la API de
[integradora-web](https://github.com/Sidas200/integradora-web) (`backend/`, contrato en `docs/api/openapi.yaml`).

## Arquitectura (MVVM)

```
lib/
  main.dart / app.dart        Arranque e inyección de dependencias (Provider)
  core/
    config/api_config.dart    URL base de la API
    network/                  ApiClient (Bearer + refresh automático) y ApiException (problem+json)
    storage/token_storage.dart Tokens en flutter_secure_storage
    utils/                    Formato de fechas y duraciones
  data/                       Model
    models/                   Account, Achievement, SaveSummary, News, PageResult, TokenResponse
    repositories/             AuthRepository, GameRepository
  viewmodels/                 ChangeNotifiers: Session, Login, Register, Home, Saves, Achievements, News
  views/                      Pantallas (sin diseño todavía)
```

## Ejecutar

Por defecto la app usa staging: `https://tdimp-api-staging.onrender.com/api/v1`.
En el plan gratis de Render la primera petición puede tardar ~1 min mientras despierta el servicio.

```bash
flutter pub get
flutter run
# Backend local (emulador de Android; en un teléfono físico usa la IP de tu PC):
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## Pruebas

```bash
flutter test
```

## Pipelines (GitHub Actions)

| Workflow | Se dispara | Produce |
|---|---|---|
| `ci-mobile.yml` | PR y push a `dev`/`main`; ejecución manual | Check `mobile-verify` (formato, `flutter analyze`, `flutter test`) y `mobile-coverage`. Fuera de PR, `mobile-apk`: APK que apunta a pruebas (7 días desde `dev`, 90 desde `main`) |
| `release-mobile.yml` | tag `vX.Y.Z` sobre `main` | GitHub Release con `tdimp-android-vX.Y.Z.apk` que apunta a producción |

Antes de subir un PR, corre lo mismo que el check:

```bash
dart format lib test && flutter analyze && flutter test
```

Flutter fijado en CI: **3.35.2** (`FLUTTER_VERSION` en ambos workflows). Si el equipo actualiza Flutter, cámbialo ahí en un PR.

### Variables y secretos (Settings › Secrets and variables › Actions)

| Nombre | Tipo | Uso |
|---|---|---|
| `API_BASE_URL_STAGING` | Variable | URL de la API de pruebas **con `/api/v1`** para el APK de `dev`/`main` |
| `API_BASE_URL_PROD` | Variable | URL de la API de producción **con `/api/v1`**; obligatoria para publicar un release |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Secretos | Firma del APK. Sin ellos se firma con la clave de depuración (con aviso en el resumen) |

```bash
infra/scripts/setup/create-keystore.sh             # una sola vez; agrega la firma a secrets.repo.env
# agrega a secrets.repo.env: VAR_API_BASE_URL_STAGING=... y VAR_API_BASE_URL_PROD=...
infra/scripts/setup/load-secrets.sh Sidas200/integradora_movil
```

`secrets.repo.env`, `key.properties` y los `.jks` están en `.gitignore`; nunca se versionan.

### Configuración del repositorio

```bash
infra/scripts/setup/configure-repo.sh  Sidas200/integradora_movil   # dev por defecto, squash merge
infra/scripts/setup/protect-branches.sh Sidas200/integradora_movil  # después de la primera ejecución de mobile-verify
```

## Flujo de trabajo

`feature/<descripcion>` desde `dev` → PR con plantilla → `mobile-verify` en verde + 1 aprobación → `dev` → al cierre del sprint, PR `dev → main` → tag `vX.Y.Z` → Release.
