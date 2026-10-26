import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../achievements/achievements_view.dart';
import '../news/news_view.dart';
import '../saves/saves_view.dart';
import '../widgets/async_body.dart';

/// Pantalla principal con pestañas: Perfil, Partidas, Logros y Noticias.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;

  static const _titles = ['Perfil', 'Partidas', 'Logros', 'Noticias'];
  static const _pages = [
    _ProfileTab(),
    SavesView(),
    AchievementsView(),
    NewsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessionViewModel>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.save), label: 'Partidas'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
          NavigationDestination(icon: Icon(Icons.article), label: 'Noticias'),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => HomeViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.account != null,
          onRetry: vm.load,
          builder: (_) {
            final a = vm.account!;
            final s = a.summary;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  a.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(a.email),
                const SizedBox(height: 8),
                Text('Cuenta creada: ${formatDate(a.createdAt)}'),
                Text('Último inicio de sesión: ${formatDate(a.lastLoginAt)}'),
                const Divider(height: 32),
                Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
                _row('Partidas guardadas', '${s.saves} / 3'),
                _row('Tiempo de juego', formatDuration(s.playTimeSec)),
                _row('Enemigos derrotados', '${s.enemiesDefeated}'),
                _row('Objetos fabricados', '${s.itemsCrafted}'),
                _row(
                  'Logros',
                  '${s.achievementsUnlocked} / ${s.achievementsTotal}',
                ),
                _row('Última sesión', formatDate(s.lastSessionAt)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(value),
  );
}
