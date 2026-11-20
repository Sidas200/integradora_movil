import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Pétalos de sakura cayendo (el sprite `petal.png` del arte de la PWA): cada pétalo baja
/// meciéndose, gira y "voltea" (escala X) como si diera vueltas en el aire.
class PetalFall extends StatefulWidget {
  const PetalFall({super.key, this.count = 26});

  final int count;

  @override
  State<PetalFall> createState() => _PetalFallState();
}

/// Los sprites se decodifican una sola vez y se comparten entre pantallas.
Future<List<ui.Image>>? _spritesFuture;

Future<List<ui.Image>> _loadSprites() {
  return _spritesFuture ??= Future(() async {
    final data = await rootBundle.load('assets/art/petal.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return [(await codec.getNextFrame()).image];
  });
}

class _Petal {
  late ui.Image sprite;
  late double x,
      y,
      size,
      alpha,
      speed,
      swayAmp,
      swayFreq,
      spin,
      flipFreq,
      phase;
}

class _PetalFallState extends State<PetalFall>
    with SingleTickerProviderStateMixin {
  // Pétalos pequeños y lentos, como en la escena de la PWA.
  static const _sizeRange = (9.0, 19.0);
  static const _speedRange = (28.0, 60.0);

  final _rng = math.Random();
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker;
  List<ui.Image>? _sprites;
  List<_Petal> _petals = const [];
  Size _area = Size.zero;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _loadSprites().then((sprites) {
      if (!mounted) return;
      setState(() => _sprites = sprites);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  double _range((double, double) r) => r.$1 + _rng.nextDouble() * (r.$2 - r.$1);

  void _respawn(_Petal p, {required bool anywhere}) {
    p.sprite = _sprites![_rng.nextInt(_sprites!.length)];
    p.size = _range(_sizeRange);
    // los más pequeños se ven más lejos: más transparentes y lentos
    final depth = (p.size - _sizeRange.$1) / (_sizeRange.$2 - _sizeRange.$1);
    p.alpha = ui.lerpDouble(0.55, 1, depth)!;
    p.x = (-0.1 + _rng.nextDouble() * 1.15) * _area.width;
    p.y = anywhere ? _rng.nextDouble() * _area.height : -p.size;
    p.speed = _range(_speedRange) * ui.lerpDouble(0.7, 1, depth)!;
    p.swayAmp = 12 + _rng.nextDouble() * 26;
    p.swayFreq = 0.4 + _rng.nextDouble() * 0.5;
    p.spin = -70 + _rng.nextDouble() * 140;
    p.flipFreq = 0.6 + _rng.nextDouble();
    p.phase = _rng.nextDouble() * 10;
  }

  void _ensurePetals(Size area) {
    if (_sprites == null || area.isEmpty) return;
    if (_petals.length == widget.count && area == _area) return;
    _area = area;
    _petals = List.generate(widget.count, (_) {
      final p = _Petal();
      _respawn(p, anywhere: true);
      return p;
    });
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    for (final p in _petals) {
      p.y += p.speed * dt; // en Flutter Y crece hacia abajo
      p.x += 15 * dt; // brisa suave hacia la derecha
      if (p.y > _area.height + 40 || p.x > _area.width + 60) {
        _respawn(p, anywhere: false);
      }
    }
    _time.value = elapsed.inMicroseconds / 1e6;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _ensurePetals(constraints.biggest);
            return CustomPaint(
              size: constraints.biggest,
              painter: _PetalPainter(_petals, _time),
            );
          },
        ),
      ),
    );
  }
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.petals, this.time) : super(repaint: time);

  final List<_Petal> petals;
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final paint = Paint()..filterQuality = FilterQuality.none; // pixel art
    for (final p in petals) {
      final img = p.sprite;
      final aspect = img.width / img.height;
      final w = aspect >= 1 ? p.size : p.size * aspect;
      final h = aspect >= 1 ? p.size / aspect : p.size;
      final wave = t * p.swayFreq + p.phase;
      // espiral: vaivén lateral y un poco de ida y vuelta vertical
      final cx = p.x + math.sin(wave) * p.swayAmp;
      final cy = p.y - math.cos(wave * 2) * p.swayAmp * 0.15;
      final angle = (p.phase * 36 + t * p.spin) * math.pi / 180;
      final flip = ui.lerpDouble(
        0.25,
        1,
        math.cos(t * p.flipFreq + p.phase).abs(),
      )!;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.scale(flip, 1);
      paint.color = Color.fromRGBO(255, 255, 255, p.alpha);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter old) => old.petals != petals;
}
