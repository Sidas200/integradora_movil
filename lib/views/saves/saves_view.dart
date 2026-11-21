import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/save_summary.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/saves_view_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/async_body.dart';

/// Partidas en la nube (SavesPage de la PWA): una tarjeta-póster por ranura, de la 1 a la 3.
class SavesView extends StatelessWidget {
  const SavesView({super.key});

  static const _header = PageHeader(
    title: 'Partidas',
    eyebrow: 'Mi cuenta',
    sub: Text(
      'Tus partidas guardadas en la nube. Se actualizan cada vez que guardas '
      'en el juego con tu cuenta iniciada.',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SavesViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<SavesViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.saves.isNotEmpty,
          onRetry: vm.load,
          header: _header,
          builder: (_) {
            final bySlot = {for (final s in vm.saves) s.slot: s};
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              children: [
                _header,
                if (vm.saves.isEmpty) ...[
                  const EmptyState(
                    title: 'Todavía no tienes partidas en la nube',
                    text:
                        'Inicia sesión en el juego y guarda tu partida: aparecerá aquí.',
                  ),
                  const SizedBox(height: 20),
                ],
                for (var slot = 1; slot <= 3; slot++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Rise(
                      delay: Duration(milliseconds: 90 * (slot - 1)),
                      child: bySlot[slot] == null
                          ? _EmptySlot(slot: slot)
                          : _SlotCard(save: bySlot[slot]!),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.save});

  final SaveSummary save;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final progress = save.milestonesTotal == 0
        ? 0.0
        : save.milestonesCompleted / save.milestonesTotal;
    return Glass(
      strong: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.m),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const SkyScene(petals: 5),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1],
                          colors: [
                            Colors.transparent,
                            p.isDark
                                ? const Color(0x8C10182B)
                                : const Color(0x59FFFFFF),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x8C23202F),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          save.slot.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontFamily: AppFonts.pixel,
                            fontSize: 19,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      characterLabel(save.activeCharacter),
                      tone: ChipTone.promise,
                    ),
                    AppChip(
                      chapterLabel(save.currentChapter),
                      tone: ChipTone.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Partida ${save.slot}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _Fact(
                  icon: Icons.flag_outlined,
                  label: 'Último hito',
                  value: Text(save.lastMilestoneTitle ?? 'Todavía ninguno'),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Fact(
                        label: 'Hitos completados',
                        value: Text(
                          '${save.milestonesCompleted} de ${save.milestonesTotal}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Fact(
                        icon: Icons.schedule_rounded,
                        label: 'Tiempo de juego',
                        value: Text(
                          formatDuration(save.playTimeSec),
                          style: TextStyle(
                            fontFamily: AppFonts.pixel,
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            color: p.hud,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Fact(
                  label: 'Último guardado',
                  value: Text(formatLongDate(save.updatedAt)),
                ),
                const SizedBox(height: 14),
                Semantics(
                  label:
                      'Progreso de la historia: ${(progress * 100).round()} por ciento',
                  child: GradientProgress(value: progress),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.icon});

  final String label;
  final Widget value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: p.textMuted),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                  color: p.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.w600),
          child: value,
        ),
      ],
    );
  }
}

/// Ranura vacía: vidrio con borde punteado y un "+".
class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.slot});

  final int slot;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return CustomPaint(
      painter: _DashedBorder(p.controlBorder),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: p.glassInset,
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.primarySoft,
              ),
              child: Icon(Icons.add_rounded, size: 30, color: p.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Partida $slot',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ranura vacía',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Empieza una partida nueva en el juego para usar esta ranura.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          const Radius.circular(AppRadius.l),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
