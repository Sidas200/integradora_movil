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
