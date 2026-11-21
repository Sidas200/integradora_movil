import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Marco de inicio de sesión y registro (AuthShell de la PWA): el título en letras, una tarjeta de vidrio
/// con un lado ilustrado (cielo, isla y el personaje) y el formulario debajo.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.sprite,
    required this.artTitle,
    required this.artText,
    required this.child,
    this.showBack = false,
  });

  final String sprite;
  final String artTitle;
  final String artText;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: SkyBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: BrandTitle(width: 220)),
                        const SizedBox(height: 16),
                        Rise(
                          child: Glass(
                            padding: EdgeInsets.zero,
                            radius: AppRadius.xl,
                            strong: false,
                            lift: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      const SkyScene(petals: 12),
                                      // velo de lectura detrás del texto
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            stops: const [0.35, 1],
                                            colors: [
                                              Colors.transparent,
                                              p.isDark
                                                  ? const Color(0xB310182B)
                                                  : const Color(0x8CFFFFFF),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 14,
                                        child: Center(
                                          child: FloatingSprite(
                                            sprite,
                                            height: 100,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ColoredBox(
                                  color: p.glassStrong,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      22,
                                      22,
                                      22,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _ArtCopy(
                                          title: artTitle,
                                          text: artText,
                                        ),
                                        const SizedBox(height: 24),
                                        child,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showBack)
                Positioned(
                  left: 4,
                  top: 4,
                  child: IconButton(
                    tooltip: 'Volver',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              const Positioned(right: 4, top: 4, child: ThemeToggleButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtCopy extends StatelessWidget {
  const _ArtCopy({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: p.promise,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: p.glowPromise,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: p.onPromise),
                const SizedBox(width: 6),
                Text(
                  'TDIMTP',
                  style: TextStyle(
                    fontFamily: AppFonts.pixel,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: p.onPromise,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.4,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: p.text.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta de campo arriba del control, como en la PWA.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, required this.child, this.hint});

  final String text;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          child,
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: TextStyle(
                fontSize: 12.5,
                color: context.palette.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "¿No tienes cuenta? Crea una aquí", separado con una línea fina.
class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(question, style: TextStyle(color: p.textMuted, fontSize: 14)),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}
