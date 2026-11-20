import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/achievements_view_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/async_body.dart';

/// Logros (AchievementsPage de la PWA): barra de progreso y placas de trofeo con medallón.
class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  static const _header = PageHeader(title: 'Logros', eyebrow: 'Mi cuenta');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AchievementsViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<AchievementsViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.achievements.isNotEmpty,
          onRetry: vm.load,
          header: _header,
          builder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              _header,
              if (vm.achievements.isEmpty)
                const EmptyState(title: 'Todavía no hay logros publicados.')
              else ...[
                Rise(
                  child: _Quest(
                    unlocked: vm.unlockedCount,
                    total: vm.achievements.length,
                  ),
                ),
                const SizedBox(height: 28),
                for (final (i, a) in vm.achievements.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Rise(
                      delay: Duration(milliseconds: 40 * i.clamp(0, 8)),
                      child: AchievementPlate(achievement: a),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Quest extends StatelessWidget {
  const _Quest({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pct = total == 0 ? 0 : (unlocked * 100 / total).round();
    return Glass(
      padding: const EdgeInsets.all(20),
      borderColor: p.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$unlocked de $total logros desbloqueados',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontFamily: AppFonts.pixel,
                  fontSize: 30,
                  height: 1,
                  color: p.promise,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GradientProgress(value: total == 0 ? 0 : unlocked / total, height: 14),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < total; i++)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    gradient: i < unlocked
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFE08A), Color(0xFFD99A1E)],
                          )
                        : null,
                    color: i < unlocked ? null : p.glass,
                    border: i < unlocked
                        ? Border.all(color: p.gold.withValues(alpha: 0.7))
                        : Border.all(color: p.controlBorder.withValues(alpha: 0.6)),
                    boxShadow: i < unlocked
                        ? [BoxShadow(color: p.gold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Icon(
                    i < unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                    size: 17,
                    color: i < unlocked ? Colors.white : p.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Placa de trofeo (lista de logros de consola): placa oscura con medallón biselado;
/// borde dorado si está desbloqueado, plateado si no y con niebla si es secreto.
/// Se ve igual en los dos temas.
class AchievementPlate extends StatefulWidget {
  const AchievementPlate({super.key, required this.achievement});

  final Achievement achievement;

  @override
  State<AchievementPlate> createState() => _AchievementPlateState();
}

class _AchievementPlateState extends State<AchievementPlate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gleam;

  @override
  void initState() {
    super.initState();
    _gleam = AnimationController(vsync: this, duration: const Duration(seconds: 6));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.achievement.unlocked &&
        !MediaQuery.disableAnimationsOf(context) &&
        !_gleam.isAnimating) {
      _gleam.repeat();
    }
  }

  @override
  void dispose() {
    _gleam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final secret = a.hidden && !a.unlocked;
    final rim = a.unlocked ? const Color(0xFFC9A24A) : const Color(0xFF8E86AE);
    final border = a.unlocked
        ? const Color(0x73C9A24A)
        : const Color(0x598E86AE);

    final (medalRim, medalIcon) = a.unlocked
        ? (const [Color(0xFFF7D982), Color(0xFFB8862B)], const Color(0xFFFFE7A3))
        : secret
        ? (const [Color(0xFFA79FC4), Color(0xFF4F4878)], const Color(0xFFD9D3EC))
        : (const [Color(0xFFC9C3DC), Color(0xFF6E6790)], const Color(0xFFC9C3DC));

    return Semantics(
      label: [
        a.unlocked ? 'Desbloqueado' : 'Bloqueado',
        secret ? 'Logro secreto' : a.name,
        if (!secret && a.description != null) a.description!,
      ].join('. '),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.m),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.7],
            colors: [Color(0xFF2B2456), Color(0xFF1A1636)],
          ),
          border: Border.all(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // línea dorada fina en el borde superior
            Positioned(
              left: 16,
              right: 16,
              top: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [rim.withValues(alpha: 0), rim, rim.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            if (a.unlocked)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _gleam,
                  builder: (_, _) {
                    final t = (_gleam.value - 0.6).clamp(0, 0.4) / 0.4;
                    return FractionalTranslation(
                      translation: Offset(-1 + 3.2 * t, 0),
                      child: const FractionallySizedBox(
                        widthFactor: 0.4,
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x00FFE7A3),
                                Color(0x1FFFE7A3),
                                Color(0x00FFE7A3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
              child: Row(
                children: [
                  _Medallion(
                    rim: medalRim,
                    iconColor: medalIcon,
                    icon: secret
                        ? Icons.help_outline_rounded
                        : Icons.emoji_events_rounded,
                    glow: a.unlocked,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          secret ? '???' : a.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            height: 1.25,
                            color: secret ? const Color(0xFFC9C1DA) : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secret
                              ? 'Logro secreto: se revela al desbloquearlo.'
                              : (a.description ?? ''),
                          style: const TextStyle(
                            color: Color(0xFFC9C1DA),
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Status(unlocked: a.unlocked, date: a.unlockedAt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.unlocked, this.date});

  final bool unlocked;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: unlocked ? null : _DashedRect(const Color(0x80A9A1C2)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: unlocked
            ? BoxDecoration(
                color: const Color(0x29F2C14E),
                borderRadius: BorderRadius.circular(AppRadius.s),
                border: Border.all(color: const Color(0x66F2C14E)),
              )
            : null,
        child: Text(
          unlocked ? 'Desbloqueado el ${formatLongDate(date)}' : 'Bloqueado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: unlocked ? const Color(0xFFF7D982) : const Color(0xFFA9A1C2),
          ),
        ),
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  _DashedRect(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    void dash(Offset a, Offset b) {
      final len = (b - a).distance;
      final dir = (b - a) / len;
      for (double d = 0; d < len; d += 6) {
        canvas.drawLine(a + dir * d, a + dir * (d + 3).clamp(0, len), paint);
      }
    }

    final r = Offset.zero & size;
    dash(r.topLeft, r.topRight);
    dash(r.topRight, r.bottomRight);
    dash(r.bottomRight, r.bottomLeft);
    dash(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}

/// Medallón biselado (esquinas cortadas, como pixel art) con aro y cara interior.
class _Medallion extends StatelessWidget {
  const _Medallion({
    required this.rim,
    required this.iconColor,
    required this.icon,
    required this.glow,
  });

  final List<Color> rim;
  final Color iconColor;
  final IconData icon;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ClipPath(
        clipper: const _Chamfer(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: rim,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipPath(
              clipper: const _Chamfer(10),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.4),
                    colors: [Color(0xFF4A3B7A), Color(0xFF1E1840)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: iconColor,
                    shadows: glow
                        ? const [Shadow(color: Color(0x99F7D982), blurRadius: 6)]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chamfer extends CustomClipper<Path> {
  const _Chamfer(this.cut);

  final double cut;

  @override
  Path getClip(Size s) => Path()
    ..moveTo(cut, 0)
    ..lineTo(s.width - cut, 0)
    ..lineTo(s.width, cut)
    ..lineTo(s.width, s.height - cut)
    ..lineTo(s.width - cut, s.height)
    ..lineTo(cut, s.height)
    ..lineTo(0, s.height - cut)
    ..lineTo(0, cut)
    ..close();

  @override
  bool shouldReclip(_Chamfer old) => old.cut != cut;
}
