import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/save_summary.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/saves_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../achievements/achievements_view.dart';
import '../news/news_view.dart';
import '../saves/saves_view.dart';
import '../widgets/app_widgets.dart';

/// Área del jugador (AppLayout de la PWA): una banda de vidrio con el jugador y pestañas
/// subrayadas (Resumen, Partidas, Logros, Noticias); debajo, la página sobre el cielo.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _tabs = ['Resumen', 'Partidas', 'Logros', 'Noticias'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: SkyBackdrop(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: _PlayerBand(tabs: _tabs),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: const TabBarView(
                      children: [
                        _DashboardTab(),
                        SavesView(),
                        AchievementsView(),
                        NewsView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerBand extends StatelessWidget {
  const _PlayerBand({required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final username =
        context.select<SessionViewModel, String?>((s) => s.username) ?? '';
    return Glass(
      padding: EdgeInsets.zero,
      borderColor: p.line,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                PlayerAvatar(username),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'CUENTA DE JUGADOR',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.6,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const ThemeToggleButton(),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => context.read<SessionViewModel>().logout(),
                ),
              ],
            ),
          ),
          TabBar(
            // las cuatro pestañas se reparten todo el ancho de la banda
            tabAlignment: TabAlignment.fill,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: [for (final t in tabs) Tab(text: t, height: 44)],
          ),
        ],
      ),
    );
  }
}

/// Resumen (DashboardPage de la PWA): "continúa jugando" con la última partida y el progreso.
/// Cada bloque carga por su cuenta, así un fallo no oculta al otro.
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => HomeViewModel(ctx.read<GameRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SavesViewModel(ctx.read<GameRepository>())..load(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final p = context.palette;
          final username = context.select<SessionViewModel, String?>(
            (s) => s.username,
          );
          return RefreshIndicator(
            onRefresh: () => Future.wait([
              context.read<HomeViewModel>().load(),
              context.read<SavesViewModel>().load(),
            ]),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              children: [
                PageHeader(
                  title: 'Resumen',
                  sub: username == null
                      ? null
                      : ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (r) => LinearGradient(
                            colors: [p.primary, p.promise],
                          ).createShader(r),
                          child: Text(
                            'Hola, $username',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const Rise(child: _LastSave()),
                const SizedBox(height: 20),
                const Rise(
                  delay: Duration(milliseconds: 120),
                  child: _Summary(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LastSave extends StatelessWidget {
  const _LastSave();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final vm = context.watch<SavesViewModel>();
    SaveSummary? save;
    for (final s in vm.saves) {
      if (save == null || s.updatedAt.isAfter(save.updatedAt)) save = s;
    }
    final loaded =
        vm.saves.isNotEmpty || (!vm.isLoading && vm.errorMessage == null);

    Widget content;
    if (!loaded && vm.errorMessage != null) {
      content = ErrorState(message: vm.errorMessage!, onRetry: vm.load);
    } else if (!loaded) {
      content = const SkeletonList(rows: 2, rowHeight: 40);
    } else if (save == null) {
      content = const EmptyState(
        title: 'Todavía no tienes partidas en la nube',
        text: 'Inicia sesión en el juego y guarda tu partida: aparecerá aquí.',
      );
    } else {
      content = _LastSaveBody(save: save);
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 340),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: p.glassBorder),
        boxShadow: p.shadowLift,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: SkyScene(petals: 10)),
          if (save != null)
            Positioned(
              right: 18,
              top: 26,
              child: FloatingSprite(
                save.activeCharacter == 'HIKARI' ? AppArt.hikari : AppArt.tsuki,
                height: 120,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 150, 14, 14),
            child: Glass(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.promiseSoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'TU ÚLTIMA PARTIDA',
                      style: TextStyle(
                        fontFamily: AppFonts.pixel,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: p.promise,
                      ),
                    ),
                  ),
                  content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastSaveBody extends StatelessWidget {
  const _LastSaveBody({required this.save});

  final SaveSummary save;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partida ${save.slot}',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppChip(
              characterLabel(save.activeCharacter),
              tone: ChipTone.promise,
            ),
            AppChip(chapterLabel(save.currentChapter), tone: ChipTone.primary),
            AppChip(
              formatDuration(save.playTimeSec),
              tone: ChipTone.hud,
              icon: Icons.schedule_rounded,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Guardada el ${formatLongDate(save.updatedAt)}',
          style: TextStyle(fontSize: 14, color: p.textMuted),
        ),
        const SizedBox(height: 16),
        _PlayButton(
          label: 'Ver partida ${save.slot}',
          onTap: () => DefaultTabController.of(context).animateTo(1),
        ),
      ],
    );
  }
}

/// Botón rosa con el ícono de "play" en un círculo.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      child: Material(
        color: p.promise,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: p.glowPromise,
            ),
            padding: const EdgeInsets.fromLTRB(8, 7, 20, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x3DFFFFFF),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: p.onPromise),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: p.onPromise,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final vm = context.watch<HomeViewModel>();
    return Glass(
      padding: const EdgeInsets.all(20),
      borderColor: p.line,
      child: AsyncContent(
        loading: vm.account == null,
        error: vm.account == null ? vm.errorMessage : null,
        onRetry: vm.load,
        builder: () {
          final a = vm.account!;
          final s = a.summary;
          final pct = s.achievementsTotal == 0
              ? 0
              : (s.achievementsUnlocked * 100 / s.achievementsTotal).round();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WidgetTitle(
                'Tu progreso',
                icon: Icons.sports_esports_outlined,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: p.glassInset,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: p.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: p.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Cuenta creada el ${formatLongDate(a.createdAt)}',
                        style: TextStyle(fontSize: 12.5, color: p.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, c) {
                  final w = (c.maxWidth - 12) / 2;
                  Widget tile(Widget t) => SizedBox(width: w, child: t);
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      tile(
                        StatTile(
                          icon: Icons.save_outlined,
                          label: 'Partidas',
                          value: '${s.saves}',
                          tone: p.primary,
                          toneSoft: p.primarySoft,
                        ),
                      ),
                      tile(
                        StatTile(
                          icon: Icons.schedule_rounded,
                          label: 'Tiempo de juego',
                          value: formatDuration(s.playTimeSec),
                          tone: p.hud,
                          toneSoft: p.blue,
                        ),
                      ),
                      tile(
                        StatTile(
                          icon: Icons.flash_on_rounded,
                          label: 'Enemigos derrotados',
                          value: '${s.enemiesDefeated}',
                          tone: p.promise,
                          toneSoft: p.promiseSoft,
                        ),
                      ),
                      tile(
                        StatTile(
                          icon: Icons.handyman_outlined,
                          label: 'Objetos fabricados',
                          value: '${s.itemsCrafted}',
                          tone: p.success,
                          toneSoft: p.mint,
                        ),
                      ),
                      tile(
                        StatTile(
                          icon: Icons.emoji_events_outlined,
                          label: 'Logros',
                          value:
                              '${s.achievementsUnlocked} de ${s.achievementsTotal}',
                          tone: p.onGold,
                          toneSoft: p.gold.withValues(alpha: 0.45),
                          ring: pct,
                        ),
                      ),
                      tile(
                        StatTile(
                          icon: Icons.history_rounded,
                          label: 'Última sesión',
                          value: s.lastSessionAt == null
                              ? 'Todavía no juegas'
                              : formatLongDate(s.lastSessionAt),
                          tone: p.textMuted,
                          toneSoft: p.glassInset,
                          smallValue: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cuadro de estadística del HUD: ícono en su color, etiqueta y cifra en pixel.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
    required this.toneSoft,
    this.ring,
    this.smallValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  final Color toneSoft;

  /// Porcentaje del anillo dorado (logros).
  final int? ring;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.glassStrong,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: p.glassBorder),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: toneSoft,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Icon(icon, size: 16, color: tone),
                ),
                const SizedBox(height: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: smallValue
                        ? const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )
                        : const TextStyle(
                            fontFamily: AppFonts.pixel,
                            fontSize: 26,
                            height: 1.1,
                          ),
                  ),
                ),
              ],
            ),
            if (ring != null)
              Positioned(top: 0, right: 0, child: _Ring(pct: ring!)),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.pct});

  final int pct;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: p.gold.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: pct / 100,
              strokeWidth: 6,
              color: p.gold,
              backgroundColor: p.primarySoft,
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontFamily: AppFonts.pixel,
              fontSize: 11,
              color: p.isDark ? p.gold : p.onGold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carga / error / contenido dentro de un bloque.
class AsyncContent extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.builder,
  });

  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    if (error != null) return ErrorState(message: error!, onRetry: onRetry);
    if (loading) return const SkeletonList(rows: 4);
    return builder();
  }
}
