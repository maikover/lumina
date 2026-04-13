import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bauhaus Design System Theme for Lectra Reader
/// Philosophy: Geometric, Constructivist, Primary Colors
/// - Binary radius: 0 (square) OR 9999px (full circle)
/// - Hard offset shadows: 4px 4px 0px black
/// - Thick borders: 2-4px solid black
/// - Uppercase headers with tight tracking
class AppTheme {
  AppTheme._();

  // Bauhaus tokens
  static const int defaultAnimationDurationMs = 150;
  static const int defaultLongAnimationDurationMs = 250;
  static const int defaultPresentationDurationMs = 3 * 1000;

  // Layout constants
  static const double kBottomAppBarHeight = 48.0 + 16.0 + 16.0;
  static const double kTopAppBarHeight = 64.0;

  // Bauhaus radius: binary - either 0 or 9999
  static const double radiusNone = 0.0;
  static const double radiusCircle = 9999.0;

  // Bauhaus border width
  static const double borderThin = 2.0;
  static const double borderMedium = 3.0;
  static const double borderThick = 4.0;

  // Bauhaus shadows (hard offset, no blur)
  static const BoxShadow shadowSmall = BoxShadow(
    offset: Offset(4.0, 4.0),
    blurRadius: 0,
    spreadRadius: 0,
    color: Color(0xFF121212),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    offset: Offset(6.0, 6.0),
    blurRadius: 0,
    spreadRadius: 0,
    color: Color(0xFF121212),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    offset: Offset(8.0, 8.0),
    blurRadius: 0,
    spreadRadius: 0,
    color: Color(0xFF121212),
  );

  /// Get Outfit text theme with Bauhaus styling
  static TextTheme _getBauhausTextTheme(ColorScheme colorScheme) {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return baseTextTheme.copyWith(
      // Display styles - uppercase, tight tracking, bold
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        color: colorScheme.onSurface,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: colorScheme.onSurface,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      // Headlines - uppercase
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      // Titles
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      // Body
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: colorScheme.onSurfaceVariant,
      ),
      // Labels - uppercase
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: colorScheme.onSurface,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: colorScheme.onSurface,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static ThemeData buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      pageTransitionsTheme: pageTransitionsTheme,
      textTheme: _getBauhausTextTheme(colorScheme),

      // AppBar - Bauhaus style: thick bottom border, no elevation
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: colorScheme.onSurface,
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFF121212),
            width: 4,
          ),
        ),
      ),

      // Input decoration - square, 2px border, no fill
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0xFF121212),
            width: 3,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0xFFD02020),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Elevated button - Bauhaus style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: const BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Outlined button - Bauhaus style
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: const BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Filled button - Bauhaus style
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: const BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Card - Bauhaus style: white bg, 4px border, hard shadow
      cardTheme: CardTheme(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: Color(0xFF121212),
            width: 4,
          ),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),

      // Checkbox - square with checkmark
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(
          color: Color(0xFF121212),
          width: 2,
        ),
      ),

      // Switch - Bauhaus style
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF121212);
          }
          return const Color(0xFFE0E0E0);
        }),
        trackOutlineColor: WidgetStateProperty.all(
          const Color(0xFF121212),
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFF0C020);
          }
          return Colors.transparent;
        }),
      ),

      // Slider - square ends, yellow accent
      sliderTheme: SliderThemeData(
        trackHeight: 8,
        thumbShape: const RectSliderThumbShape(),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: const Color(0xFFF0C020),
        inactiveTrackColor: const Color(0xFFE0E0E0),
        thumbColor: const Color(0xFF121212),
      ),

      // Tab bar
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xFF121212),
            width: 4,
          ),
        ),
      ),

      // Floating action button - circular, primary red
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(
          side: BorderSide(
            color: Color(0xFF121212),
            width: 4,
          ),
        ),
        backgroundColor: const Color(0xFFD02020),
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
      ),

      // Bottom sheet - square corners
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        backgroundColor: Color(0xFFF0F0F0),
      ),

      // Dialog - square corners, thick border
      dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: Color(0xFF121212),
            width: 4,
          ),
        ),
        backgroundColor: Color(0xFFF0F0F0),
      ),

      // Divider - thick black line
      dividerTheme: const DividerThemeData(
        color: Color(0xFF121212),
        thickness: 2,
        space: 1,
      ),

      // Progress indicators - square style
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFFE0E0E0),
        color: Color(0xFF121212),
      ),

      // Snack bar
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: Color(0xFF121212),
            width: 2,
          ),
        ),
        backgroundColor: Color(0xFF121212),
        contentTextStyle: TextStyle(
          color: Color(0xFFF0F0F0),
          fontWeight: FontWeight.w500,
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // Splash - no splash effect
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static PageTransitionsTheme get pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }
}

/// Bauhaus-style rectangular slider thumb
class RectSliderThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;

  const RectSliderThumbShape({
    this.thumbWidth = 16,
    this.thumbHeight = 16,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? const Color(0xFF121212)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: thumbWidth,
        height: thumbHeight,
      ),
      paint,
    );

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: thumbWidth,
        height: thumbHeight,
      ),
      borderPaint,
    );
  }
}
