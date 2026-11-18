import 'package:flutter/material.dart';

class AcrColors {
  // Obsidian Surfaces (ACR Design System)
  static const Color background = Color(0xFF000000);
  static const Color surfaceElevated = Color(0xFF050508);
  static const Color surface = Color(0xFF0D0D11);
  static const Color card = Color(0xFF0D0D11);
  static const Color cardOverlay = Color(0xFF141414);

  // Graphite & Borders
  static const Color graphite = Color(0xFF18181B);
  static const Color graphiteDivider = Color(0xFF262626);
  static const Color subtleBorder = Color(0x14FFFFFF);
  static const Color cardBorder = Color(0x24FFFFFF);

  // Zyphra Orange & Copper / Solar Tokens
  static const Color zyphraOrange = Color(0xFFFF5500);
  static const Color zyphraHover = Color(0xFFFF6600);
  static const Color zyphraPressed = Color(0xFFE04800);
  static const Color zyphraGlow = Color(0x59FF5500);
  static const Color solarTint = Color(0xFFFF8C42);
  static const Color copper = Color(0xFFE7620F);
  static const Color copperDeep = Color(0xFFC54C02);

  // Protocol & Feedback Accents
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanGlow = Color(0x3338BDF8);
  static const Color indigo = Color(0xFF6366F1);
  static const Color emerald = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFFB7185);
  static const Color error = Color(0xFFEF4444);

  // WCAG 2.2 AAA Text Tokens (>= 7.0:1 on #000000 and #0D0D11)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD4D4D8);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color textOnAccent = Color(0xFF000000);
}

class AcrTypography {
  static const String sansFontFamily = 'Inter';
  static const List<String> sansFallback = <String>[
    'Inter',
    'system-ui',
    'sans-serif',
  ];

  static const String monoFontFamily = 'Atkinson Hyperlegible Mono';
  static const List<String> monoFallback = <String>[
    'Atkinson Hyperlegible Mono',
    'JetBrains Mono',
    'monospace',
  ];

  static const TextStyle monoStyle = TextStyle(
    fontFamily: monoFontFamily,
    fontFamilyFallback: monoFallback,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}

class AcrTheme {
  static const BorderSide _focusBorderSide = BorderSide(
    color: AcrColors.zyphraOrange,
    width: 2,
  );

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme.apply(
      fontFamily: AcrTypography.sansFontFamily,
      bodyColor: AcrColors.textPrimary,
      displayColor: AcrColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AcrTypography.sansFontFamily,
      fontFamilyFallback: AcrTypography.sansFallback,
      textTheme: baseTextTheme,
      scaffoldBackgroundColor: AcrColors.background,
      dividerColor: AcrColors.graphiteDivider,
      focusColor: AcrColors.zyphraGlow,
      colorScheme: const ColorScheme.dark(
        primary: AcrColors.zyphraOrange,
        onPrimary: AcrColors.textOnAccent,
        secondary: AcrColors.solarTint,
        onSecondary: AcrColors.textOnAccent,
        surface: AcrColors.surface,
        onSurface: AcrColors.textPrimary,
        error: AcrColors.error,
        onError: AcrColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AcrColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AcrColors.subtleBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AcrColors.surface,
        foregroundColor: AcrColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AcrTypography.sansFontFamily,
          fontFamilyFallback: AcrTypography.sansFallback,
          color: AcrColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AcrColors.graphite;
            }
            if (states.contains(WidgetState.pressed)) {
              return AcrColors.zyphraPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return AcrColors.zyphraHover;
            }
            return AcrColors.zyphraOrange;
          }),
          foregroundColor: const WidgetStatePropertyAll(AcrColors.textOnAccent),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.bold),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return _focusBorderSide;
            }
            return BorderSide.none;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          foregroundColor: const WidgetStatePropertyAll(AcrColors.textPrimary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return _focusBorderSide;
            }
            return const BorderSide(color: AcrColors.cardBorder);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          foregroundColor: const WidgetStatePropertyAll(AcrColors.solarTint),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return _focusBorderSide;
            }
            return BorderSide.none;
          }),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          overlayColor: const WidgetStatePropertyAll(AcrColors.zyphraGlow),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return _focusBorderSide;
            }
            return BorderSide.none;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AcrColors.surface,
        hintStyle: const TextStyle(color: AcrColors.textMuted),
        labelStyle: const TextStyle(color: AcrColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AcrColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AcrColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: _focusBorderSide,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AcrColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AcrColors.cardBorder),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AcrColors.zyphraOrange,
        selectionColor: AcrColors.zyphraGlow,
        selectionHandleColor: AcrColors.zyphraOrange,
      ),
    );
  }
}
