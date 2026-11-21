import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/game_repository.dart';
import 'viewmodels/session_view_model.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/widgets/app_widgets.dart';

/// Crea las dependencias y las expone con Provider.
class App extends StatefulWidget {
  const App({super.key, this.apiClient, this.tokenStorage});

  /// Permiten inyectar dobles en pruebas.
  final ApiClient? apiClient;
  final TokenStorage? tokenStorage;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final TokenStorage _tokens = widget.tokenStorage ?? TokenStorage();
  late final ApiClient _api =
      widget.apiClient ?? ApiClient(tokenStorage: _tokens);
  late final AuthRepository _authRepo = AuthRepository(
    api: _api,
    tokens: _tokens,
  );
  late final GameRepository _gameRepo = GameRepository(api: _api);
  late final SessionViewModel _session = SessionViewModel(_authRepo);
  final _theme = ThemeController();

  @override
  void initState() {
    super.initState();
    _api.onSessionExpired = _session.expired;
    _session.addListener(_onSessionChanged);
    _session.restore();
  }

  /// Al cerrar sesión se quitan las pantallas apiladas (detalle, registro…).
  void _onSessionChanged() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _authRepo),
        Provider.value(value: _gameRepo),
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider.value(value: _theme),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) => MaterialApp(
          title: 'TDIMTP',
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(AppPalette.light),
          darkTheme: buildAppTheme(AppPalette.dark),
          themeMode: theme.mode,
          home: const _Root(),
        ),
      ),
    );
  }
}

/// Muestra Login o Home según el estado de la sesión.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    switch (context.watch<SessionViewModel>().status) {
      case SessionStatus.unknown:
        return const Scaffold(
          body: SkyBackdrop(
            petals: 12,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [SpinningSword(size: 112)],
                ),
              ),
            ),
          ),
        );
      case SessionStatus.authenticated:
        return const HomeView();
      case SessionStatus.unauthenticated:
        return const LoginView();
    }
  }
}
