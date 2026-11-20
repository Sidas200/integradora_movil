import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import 'petal_fall.dart';

/// Componentes del diseño "Islas pastel" de la PWA (integradora-web), adaptados a Flutter.

// ---------------------------------------------------------------------------
// Arte
// ---------------------------------------------------------------------------

/// Rutas del arte en pixel (assets/art, copiado de la PWA).
class AppArt {
  static const wordmark = 'assets/art/wordmark-900.webp';
  static const logoMark = 'assets/art/logo-mark.png';
  static const tsuki = 'assets/art/tsuki.webp';
  static const hikari = 'assets/art/hikari.webp';

  static String layer(String name, Brightness b) =>
      'assets/art/$name-${b == Brightness.dark ? 'dark' : 'light'}-800.webp';

  /// Portadas de noticias: se elige una por el slug, igual que en la PWA (covers.ts).
  static const _covers = [
    ('assets/art/cover-bridge-774.webp', Alignment(0, 0)),
    ('assets/art/cover-forge-771.webp', Alignment(0.2, 0)),
    ('assets/art/cover-dusk-800.webp', Alignment(0.5, -0.2)),
    ('assets/art/cover-torii-771.webp', Alignment(0, -0.1)),
    ('assets/art/cover-cliff-774.webp', Alignment(-0.4, 0)),
    ('assets/art/cover-ruins-778.webp', Alignment(-0.4, 0)),
    ('assets/art/key-art-800.webp', Alignment(0.4, -0.2)),
    ('assets/art/story-night-800.webp', Alignment(0, -0.1)),
  ];

  static (String, Alignment) coverOf(String slug) =>
      _covers[slug.codeUnits.fold<int>(0, (a, c) => a + c) % _covers.length];
}

/// Imagen en pixel art sin suavizado.
class PixelImage extends StatelessWidget {
  const PixelImage(
    this.asset, {
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  final String asset;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    fit: fit,
    alignment: alignment,
    width: width,
    height: height,
    filterQuality: FilterQuality.none,
    gaplessPlayback: true,
    excludeFromSemantics: true,
  );
}

/// Logo del juego ("The Day I Made That Promise").
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'The Day I Made That Promise',
    image: true,
    child: Image.asset(
      AppArt.wordmark,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    ),
  );
}

/// Emblema: la espada carmesí sobre la luna, en su cuadro nocturno.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular((size * 0.12).clamp(3, 20)),
    child: PixelImage(AppArt.logoMark, width: size, height: size),
  );
}

/// Cielo detrás de cada pantalla: degradado y tres manchas suaves (global.css, body::before).
class SkyBackdrop extends StatelessWidget {
  const SkyBackdrop({super.key, required this.child, this.petals = 0});

  final Widget child;
  final int petals;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    RadialGradient blob(Alignment at, Color c, double r) => RadialGradient(
      center: at,
      radius: r,
      colors: [c, c.withValues(alpha: 0)],
      stops: const [0, 0.7],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: p.sky,
          stops: const [0, 0.42, 0.72, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: blob(const Alignment(-0.76, -0.84), p.skyBlobs[0], 1.1),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: blob(const Alignment(0.84, -0.56), p.skyBlobs[1], 1),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: blob(const Alignment(0.4, 1), p.skyBlobs[2], 1.1),
            ),
          ),
          if (petals > 0) PetalFall(count: petals),
          child,
        ],
      ),
    );
  }
}

/// Cielo de islas flotantes en capas (cielo, picos lejanos, isla, islotes, nubes), con la isla
/// meciéndose y pétalos cayendo. Decorativo. Igual que `SkyScene` de la PWA.
class SkyScene extends StatefulWidget {
  const SkyScene({
    super.key,
    this.petals = 10,
    this.focus = const Alignment(0.2, 0.4),
  });

  final int petals;

  /// Punto que se conserva al recortar (el mismo en todas las capas, para que se alineen).
  final Alignment focus;

  @override
  State<SkyScene> createState() => _SkySceneState();
}

class _SkySceneState extends State<SkyScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bob.stop();
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final b = p.brightness;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: p.sceneFallback,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            Widget bobbing(Widget child, {bool reverse = false}) =>
                AnimatedBuilder(
                  animation: _bob,
                  builder: (_, child) {
                    final t = Curves.easeInOut.transform(_bob.value);
                    final dy = (reverse ? 1 - t : t) * -0.016 * h;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: child,
                    );
                  },
                  child: child,
                );
            Widget layer(
              String name, {
              double top = -0.08,
              double height = 1.08,
              bool bob = false,
              bool reverse = false,
            }) {
              Widget image = PixelImage(
                AppArt.layer(name, b),
                fit: BoxFit.cover,
                alignment: widget.focus,
              );
              if (bob) image = bobbing(image, reverse: reverse);
              return Positioned(
                left: 0,
                right: 0,
                top: h * top,
                height: h * height,
                child: image,
              );
            }

            return ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  layer('sky', top: 0, height: 1),
                  layer('far'),
                  layer('island', bob: true),
                  layer('near', bob: true, reverse: true),
                  layer('clouds', top: 0, height: 1.04),
                  if (widget.petals > 0) PetalFall(count: widget.petals),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Personaje en pixel art que flota suavemente con su sombra en el suelo.
class FloatingSprite extends StatefulWidget {
  const FloatingSprite(this.asset, {super.key, required this.height});

  final String asset;
  final double height;

  @override
  State<FloatingSprite> createState() => _FloatingSpriteState();
}

class _FloatingSpriteState extends State<FloatingSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = Curves.easeInOut.transform(_c.value);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, -8 * t),
                child: PixelImage(widget.asset, height: widget.height),
              ),
              Transform.scale(
                scaleX: 1 - 0.2 * t,
                child: Container(
                  width: widget.height * 0.35,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color.fromRGBO(35, 32, 47, 0.25 - 0.1 * t),
                    boxShadow: const [
                      BoxShadow(color: Color(0x2223202F), blurRadius: 3),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Superficies
// ---------------------------------------------------------------------------

/// Tarjeta de vidrio sobre el cielo.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppRadius.l,
    this.strong = true,
    this.blur = false,
    this.lift = false,
    this.borderColor,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool strong;

  /// Desenfoca lo que hay detrás (más costoso: solo en superficies grandes y fijas).
  final bool blur;
  final bool lift;
  final Color? borderColor;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shape = BorderRadius.circular(radius);
    Widget body = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        splashColor: p.promiseSoft,
        highlightColor: p.primarySoft.withValues(alpha: 0.4),
        child: Padding(padding: padding, child: child),
      ),
    );
    if (blur) {
      body = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: body,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: lift ? p.shadowLift : p.shadowGlass,
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? (strong ? p.glassStrong : p.glass),
            borderRadius: shape,
            border: Border.all(color: borderColor ?? p.glassBorder),
          ),
          child: body,
        ),
      ),
    );
  }
}

/// Encabezado de página: "eyebrow" con línea fina y título en Plus Jakarta Sans 800.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.eyebrow, this.sub});

  final String title;
  final String? eyebrow;
  final Widget? sub;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Row(
              children: [
                Container(width: 32, height: 1, color: p.promise),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    eyebrow!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: p.promise,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 30,
                height: 1.15,
                letterSpacing: -0.6,
                color: p.text,
              ),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: TextStyle(color: p.textMuted, height: 1.5),
              child: sub!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Título de un bloque (widget del resumen, sección de partida…).
class WidgetTitle extends StatelessWidget {
  const WidgetTitle(this.text, {super.key, required this.icon, this.trailing});

  final String text;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 19, color: p.promise),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controles
// ---------------------------------------------------------------------------

enum ButtonVariant { primary, promise, outline, ghost, danger }

/// Botón de la PWA: 46 px de alto, esquinas de 6 px, brillo de color y subida al tocarlo.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
    this.height = 46,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// Texto mientras carga ("Entrando…").
  final String? loadingLabel;
  final bool expand;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = widget.onPressed != null && !widget.loading;
    final (bg, fg, border, glow) = switch (widget.variant) {
      ButtonVariant.primary => (
        p.primary,
        p.onPrimary,
        Colors.transparent,
        p.glowPrimary,
      ),
      ButtonVariant.promise => (
        p.promise,
        p.onPromise,
        Colors.transparent,
        p.glowPromise,
      ),
      ButtonVariant.danger => (
        p.danger,
        p.onDanger,
        Colors.transparent,
        const <BoxShadow>[],
      ),
      ButtonVariant.outline => (
        p.glassStrong,
        p.text,
        p.glassBorder,
        p.shadowGlass,
      ),
      ButtonVariant.ghost => (
        Colors.transparent,
        p.text,
        Colors.transparent,
        const <BoxShadow>[],
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.loading
          ? (widget.loadingLabel ?? widget.label)
          : widget.label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: enabled ? 1 : (widget.loading ? 0.8 : 0.55),
        child: AnimatedScale(
          duration: AppMotion.fast,
          curve: AppMotion.ease,
          scale: _pressed ? 0.98 : 1,
          child: Container(
            height: widget.height,
            width: widget.expand ? double.infinity : null,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: border),
              boxShadow: enabled ? glow : const [],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: enabled ? widget.onPressed : null,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                splashColor: fg.withValues(alpha: 0.12),
                highlightColor: fg.withValues(alpha: 0.06),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: widget.expand
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.loading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: fg,
                          ),
                        )
                      else if (widget.icon != null)
                        Icon(widget.icon, size: 18, color: fg),
                      if (widget.loading || widget.icon != null)
                        const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.loading
                              ? (widget.loadingLabel ?? widget.label)
                              : widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: widget.height >= 50 ? 16 : 14,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ],
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

enum ChipTone { neutral, promise, primary, gold, success, hud }

/// Etiqueta pequeña (personaje, capítulo, tiempo…).
class AppChip extends StatelessWidget {
  const AppChip(
    this.label, {
    super.key,
    this.tone = ChipTone.neutral,
    this.icon,
  });

  final String label;
  final ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (tone) {
      ChipTone.neutral => (p.glassStrong, p.text),
      ChipTone.promise => (p.promiseSoft, p.promise),
      ChipTone.primary => (p.primarySoft, p.primary),
      ChipTone.gold => (p.gold, p.onGold),
      ChipTone.success => (p.successSoft, p.success),
      ChipTone.hud => (p.blue, p.hud),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: tone == ChipTone.neutral
            ? Border.all(color: p.glassBorder)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: tone == ChipTone.hud ? 13 : 12.5,
              fontWeight: FontWeight.w700,
              fontFamily: tone == ChipTone.hud ? AppFonts.pixel : null,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de progreso con el degradado rosa → violeta y brillo.
class GradientProgress extends StatelessWidget {
  const GradientProgress({super.key, required this.value, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: p.primarySoft,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 1100),
          curve: AppMotion.ease,
          builder: (_, v, _) => FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                gradient: LinearGradient(colors: [p.primary, p.promiseGlow]),
                boxShadow: [
                  BoxShadow(
                    color: p.promiseGlow.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar con la inicial del jugador sobre el degradado de la promesa.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar(this.username, {super.key, this.size = 44});

  final String username;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.m),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.promise, p.primary],
        ),
      ),
      child: Text(
        username.isEmpty ? '?' : username[0].toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.pixel,
          fontSize: size * 0.44,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Botón para cambiar entre el tema claro (pastel) y el oscuro (noche).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.palette.isDark;
    return IconButton(
      tooltip: dark ? 'Cambiar al tema claro' : 'Cambiar al tema oscuro',
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () =>
          context.read<ThemeController>().toggle(Theme.of(context).brightness),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados
// ---------------------------------------------------------------------------

/// Aviso de error dentro de un formulario (rosa con ícono).
class AlertBox extends StatelessWidget {
  const AlertBox(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: p.errorSoft,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: p.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: p.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error al cargar con botón para reintentar.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.errorSoft,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: p.error.withValues(alpha: 0.35)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: p.error, size: 20),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          AppButton(
            label: 'Reintentar',
            icon: Icons.refresh_rounded,
            variant: ButtonVariant.outline,
            height: 38,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Cuadro de diálogo de RPG con marco de pixel: estado vacío.
class EmptyState extends StatefulWidget {
  const EmptyState({super.key, required this.title, this.text});

  final String title;
  final String? text;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_blink.isAnimating) {
      _blink.repeat();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      decoration: BoxDecoration(
        color: p.glassStrong,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.text, width: 3),
        boxShadow: [
          BoxShadow(color: p.primary, offset: const Offset(4, 4)),
          ...p.shadowGlass,
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 22, 22, 22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '* ',
                style: TextStyle(
                  fontFamily: AppFonts.pixel,
                  fontSize: 19,
                  color: p.promise,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppFonts.pixel,
                        fontSize: 19,
                      ),
                    ),
                    if (widget.text != null) ...[
                      const SizedBox(height: 4),
                      Text(widget.text!, style: TextStyle(color: p.textMuted)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -6,
            bottom: -14,
            child: AnimatedBuilder(
              animation: _blink,
              builder: (_, _) => Opacity(
                opacity: _blink.value < 0.5 ? 1 : 0,
                child: Text(
                  '▼',
                  style: TextStyle(fontSize: 11, color: p.promise),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filas brillantes mientras carga.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.rows = 3, this.rowHeight = 58});

  final int rows;
  final double rowHeight;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Cargando…',
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final x = -2 + 4 * Curves.easeInOut.transform(_c.value);
          return Column(
            children: [
              for (var i = 0; i < widget.rows; i++)
                Container(
                  height: widget.rowHeight,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    border: Border.all(color: p.glassBorder),
                    gradient: LinearGradient(
                      begin: Alignment(x - 1, 0),
                      end: Alignment(x + 1, 0),
                      colors: [p.glass, p.glassStrong, p.glass],
                      stops: const [0.3, 0.5, 0.7],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Aparece subiendo un poco (animación "rise" de la PWA).
class Rise extends StatelessWidget {
  const Rise({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final total = AppMotion.slow + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (_, t, child) {
        final v = AppMotion.ease.transform(
          ((t - start) / (1 - start)).clamp(0, 1),
        );
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
