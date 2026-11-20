import 'package:flutter/material.dart';

/// Tokens del diseño "Islas pastel" de la PWA (integradora-web: src/shared/styles/tokens.css).
/// Tema claro (por defecto): cielo pastel lila/rosa con vidrio blanco.
/// Tema oscuro: noche azul marino con rosa neón.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.sky,
    required this.skyBlobs,
    required this.bg,
    required this.glass,
    required this.glassStrong,
    required this.glassBorder,
    required this.glassSolid,
    required this.glassInset,
    required this.text,
    required this.textMuted,
    required this.controlBorder,
    required this.line,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.promise,
    required this.onPromise,
    required this.promiseGlow,
    required this.promiseSoft,
    required this.hud,
    required this.gold,
    required this.onGold,
    required this.mint,
    required this.blue,
    required this.success,
    required this.successSoft,
    required this.error,
    required this.errorSoft,
    required this.danger,
    required this.onDanger,
    required this.shadowGlass,
    required this.shadowLift,
    required this.glowPromise,
    required this.glowPrimary,
    required this.sceneFallback,
  });

  final Brightness brightness;
  final List<Color> sky;

  /// Manchas suaves del cielo (arriba izq., arriba der., abajo).
  final List<Color> skyBlobs;
  final Color bg;
  final Color glass;
  final Color glassStrong;
  final Color glassBorder;
  final Color glassSolid;
  final Color glassInset;
  final Color text;
  final Color textMuted;
  final Color controlBorder;
  final Color line;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color promise;
  final Color onPromise;
  final Color promiseGlow;
  final Color promiseSoft;
  final Color hud;
  final Color gold;
  final Color onGold;
  final Color mint;
  final Color blue;
  final Color success;
  final Color successSoft;
  final Color error;
  final Color errorSoft;
  final Color danger;
  final Color onDanger;
  final List<BoxShadow> shadowGlass;
  final List<BoxShadow> shadowLift;
  final List<BoxShadow> glowPromise;
  final List<BoxShadow> glowPrimary;

  /// Degradado mientras carga la imagen del cielo.
  final List<Color> sceneFallback;

  bool get isDark => brightness == Brightness.dark;

  static const light = AppPalette(
    brightness: Brightness.light,
    sky: [Color(0xFFFBF0F7), Color(0xFFEEDFF4), Color(0xFFD9D6F6), Color(0xFFC9D4F2)],
    skyBlobs: [Color(0x8CFFBEDE), Color(0x8CBEC8FF), Color(0x99CDE0DA)],
    bg: Color(0xFFF6EEF6),
    glass: Color(0xB8FFFFFF),
    glassStrong: Color(0xDBFFFFFF),
    glassBorder: Color(0xBFFFFFFF),
    glassSolid: Color(0xFFF4F1FB),
    glassInset: Color(0x8CFFFFFF),
    text: Color(0xFF23202F),
    textMuted: Color(0xFF655E75),
    controlBorder: Color(0xFF7E7696),
    line: Color(0x245B45C2),
    primary: Color(0xFF5B45C2),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFECE7FF),
    promise: Color(0xFFC92D65),
    onPromise: Color(0xFFFFFFFF),
    promiseGlow: Color(0xFFE5487E),
    promiseSoft: Color(0xFFFCE3EE),
    hud: Color(0xFF2F6E9E),
    gold: Color(0xFFF2C14E),
    onGold: Color(0xFF23202F),
    mint: Color(0xFFCDE0DA),
    blue: Color(0xFFBBD3E5),
    success: Color(0xFF2C7A5F),
    successSoft: Color(0xFFDDF1E8),
    error: Color(0xFFB4233C),
    errorSoft: Color(0xFFFBE3E7),
    danger: Color(0xFFB4233C),
    onDanger: Color(0xFFFFFFFF),
    shadowGlass: [
      BoxShadow(color: Color(0x0F23202F), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x0D23202F), offset: Offset(0, 2), blurRadius: 8),
    ],
    shadowLift: [
      BoxShadow(color: Color(0x1423202F), offset: Offset(0, 2), blurRadius: 4),
      BoxShadow(color: Color(0x1A23202F), offset: Offset(0, 8), blurRadius: 20),
    ],
    glowPromise: [
      BoxShadow(color: Color(0x38E5487E), offset: Offset(0, 3), blurRadius: 10),
    ],
    glowPrimary: [
      BoxShadow(color: Color(0x2E5B45C2), offset: Offset(0, 3), blurRadius: 10),
    ],
    sceneFallback: [Color(0xFF5568C8), Color(0xFFF3B4D0)],
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    sky: [Color(0xFF0C1226), Color(0xFF161734), Color(0xFF241F4A), Color(0xFF2E2558)],
    skyBlobs: [Color(0x29FF6FAE), Color(0x337864FF), Color(0x1F50A0FF)],
    bg: Color(0xFF10182B),
    glass: Color(0xB81E2442),
    glassStrong: Color(0xE01E2442),
    glassBorder: Color(0x38B3A4FF),
    glassSolid: Color(0xFF1E233E),
    glassInset: Color(0x0DFFFFFF),
    text: Color(0xFFF6F0F8),
    textMuted: Color(0xFFBDB5CF),
    controlBorder: Color(0xFF8E86AE),
    line: Color(0x29B3A4FF),
    primary: Color(0xFFB3A4FF),
    onPrimary: Color(0xFF14111F),
    primarySoft: Color(0x29B3A4FF),
    promise: Color(0xFFFF6FAE),
    onPromise: Color(0xFF14111F),
    promiseGlow: Color(0xFFFF6FAE),
    promiseSoft: Color(0x29FF6FAE),
    hud: Color(0xFF9FD8FF),
    gold: Color(0xFFF2C14E),
    onGold: Color(0xFF23202F),
    mint: Color(0x297FD8B4),
    blue: Color(0x249FD8FF),
    success: Color(0xFF7FD8B4),
    successSoft: Color(0x247FD8B4),
    error: Color(0xFFFF8FA3),
    errorSoft: Color(0x24FF8FA3),
    danger: Color(0xFFB4233C),
    onDanger: Color(0xFFFFFFFF),
    shadowGlass: [
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 10),
    ],
    shadowLift: [
      BoxShadow(color: Color(0x59000000), offset: Offset(0, 2), blurRadius: 4),
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 10), blurRadius: 24),
    ],
    glowPromise: [
      BoxShadow(color: Color(0x80FF6FAE), spreadRadius: 1),
      BoxShadow(color: Color(0x40FF6FAE), offset: Offset(0, 3), blurRadius: 12),
    ],
    glowPrimary: [
      BoxShadow(color: Color(0x66B3A4FF), spreadRadius: 1),
      BoxShadow(color: Color(0x33B3A4FF), offset: Offset(0, 3), blurRadius: 12),
    ],
    sceneFallback: [Color(0xFF1A1550), Color(0xFF6A4BC0)],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Atajo: `context.palette`.
extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Familias tipográficas (assets/fonts, licencia OFL).
class AppFonts {
  /// Interfaz y lectura.
  static const body = 'PlusJakartaSans';

  /// Cifras del juego y "eyebrows".
  static const pixel = 'PixelifySans';
}

/// Radios del diseño: esquinas suaves, cercanas al pixel art.
class AppRadius {
  static const s = 3.0;
  static const m = 5.0;
  static const l = 7.0;
  static const xl = 10.0;
  static const pill = 6.0;
}

/// Duraciones y curvas de movimiento.
class AppMotion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 700);
  static const ease = Cubic(0.2, 0.7, 0.2, 1);
  static const spring = Cubic(0.34, 1.4, 0.5, 1);
}

ThemeData buildAppTheme(AppPalette p) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: p.primary,
        brightness: p.brightness,
      ).copyWith(
        primary: p.primary,
        onPrimary: p.onPrimary,
        secondary: p.promise,
        onSecondary: p.onPromise,
        error: p.error,
        surface: p.glassSolid,
        onSurface: p.text,
        onSurfaceVariant: p.textMuted,
        outline: p.controlBorder,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
    brightness: p.brightness,
  );

  OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.s),
    borderSide: BorderSide(color: c, width: w),
  );

  return base.copyWith(
    extensions: [p],
    scaffoldBackgroundColor: p.bg,
    textTheme: base.textTheme.apply(
      fontFamily: AppFonts.body,
      bodyColor: p.text,
      displayColor: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        letterSpacing: -0.3,
        color: p.text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.glassStrong,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: p.textMuted.withValues(alpha: 0.8)),
      helperStyle: TextStyle(color: p.textMuted, fontSize: 12.5),
      helperMaxLines: 3,
      errorStyle: TextStyle(
        color: p.error,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      errorMaxLines: 3,
      border: border(p.controlBorder),
      enabledBorder: border(p.controlBorder),
      focusedBorder: border(p.primary, 2),
      errorBorder: border(p.error),
      focusedErrorBorder: border(p.error, 2),
      prefixIconColor: p.textMuted,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.primary,
      selectionColor: p.promiseSoft,
      selectionHandleColor: p.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: p.controlBorder, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.promise : p.glassStrong,
      ),
      checkColor: WidgetStatePropertyAll(p.onPromise),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.promise,
      linearTrackColor: p.primarySoft,
      circularTrackColor: Colors.transparent,
      refreshBackgroundColor: p.glassSolid,
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: p.text,
      unselectedLabelColor: p.textMuted,
      labelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: p.promise, width: 2),
        insets: const EdgeInsets.symmetric(horizontal: 12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: p.line,
      overlayColor: WidgetStatePropertyAll(p.primarySoft),
      tabAlignment: TabAlignment.start,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.glassSolid,
      contentTextStyle: TextStyle(color: p.text, fontFamily: AppFonts.body),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
