import 'package:flutter/material.dart';
import 'package:lumina/src/core/theme/app_theme.dart';
import 'package:lumina/src/features/reader/data/reader_scripts.dart';

class EpubTheme {
  final double zoom;
  final bool shouldOverrideTextColor;
  final ColorScheme colorScheme;
  final Color? overridePrimaryColor;
  final EdgeInsets padding;

  // File name (with extension) of the custom font, or null for epub default.
  final String? fontFileName;
  final bool overrideFontFamily;

  // When true, the reader uses a scroll-based navigation model instead of paged.
  final bool scroll;

  EpubTheme({
    required this.zoom,
    required this.shouldOverrideTextColor,
    required this.colorScheme,
    this.overridePrimaryColor,
    required this.padding,
    this.fontFileName,
    this.overrideFontFamily = false,
    this.scroll = false,
  });

  bool get isDark => colorScheme.brightness == Brightness.dark;

  Color get surfaceColor => colorScheme.surface;

  ThemeData get themeData => AppTheme.buildTheme(colorScheme);

  EpubTheme copyWith({
    double? zoom,
    bool? shouldOverrideTextColor,
    ColorScheme? colorScheme,
    Color? overridePrimaryColor,
    EdgeInsets? padding,
    Object? fontFileName = _kUnset,
    bool? overrideFontFamily,
    bool? scroll,
  }) {
    return EpubTheme(
      zoom: zoom ?? this.zoom,
      shouldOverrideTextColor:
          shouldOverrideTextColor ?? this.shouldOverrideTextColor,
      colorScheme: colorScheme ?? this.colorScheme,
      overridePrimaryColor: overridePrimaryColor ?? this.overridePrimaryColor,
      padding: padding ?? this.padding,
      fontFileName: identical(fontFileName, _kUnset)
          ? this.fontFileName
          : fontFileName as String?,
      overrideFontFamily: overrideFontFamily ?? this.overrideFontFamily,
      scroll: scroll ?? this.scroll,
    );
  }

  static const Object _kUnset = Object();

  Map<String, dynamic> toThemeMap() {
    return {
      'padding': {'top': padding.top, 'left': padding.left},

      'zoom': zoom,
      'shouldOverrideTextColor': shouldOverrideTextColor,

      'primaryColor': overridePrimaryColor != null
          ? colorToMap(overridePrimaryColor!)
          : colorToMap(colorScheme.primary),
      'onPrimaryColor': colorToMap(colorScheme.onPrimary),
      'secondaryColor': colorToMap(colorScheme.secondary),
      'onSecondaryColor': colorToMap(colorScheme.onSecondary),
      'errorColor': colorToMap(colorScheme.error),
      'onErrorColor': colorToMap(colorScheme.onError),
      'surfaceColor': colorToMap(colorScheme.surface),
      'onSurfaceColor': colorToMap(colorScheme.onSurface),
      'primaryContainerColor': colorToMap(colorScheme.primaryContainer),
      'onSurfaceVariantColor': colorToMap(colorScheme.onSurfaceVariant),
      'outlineVariantColor': colorToMap(colorScheme.outlineVariant),
      'surfaceContainerColor': colorToMap(colorScheme.surfaceContainer),
      'surfaceContainerHighColor': colorToMap(colorScheme.surfaceContainerHigh),

      'fontFileName': fontFileName,
      'overrideFontFamily': overrideFontFamily,
      'scroll': scroll,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EpubTheme &&
        other.zoom == zoom &&
        other.shouldOverrideTextColor == shouldOverrideTextColor &&
        other.colorScheme == colorScheme &&
        other.overridePrimaryColor == overridePrimaryColor &&
        other.padding == padding &&
        other.fontFileName == fontFileName &&
        other.overrideFontFamily == overrideFontFamily &&
        other.scroll == scroll;
  }

  @override
  int get hashCode => Object.hash(
    zoom,
    shouldOverrideTextColor,
    colorScheme,
    overridePrimaryColor,
    padding,
    fontFileName,
    overrideFontFamily,
    scroll,
  );
}
