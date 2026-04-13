import 'package:flutter/material.dart';
import 'package:lumina/src/core/theme/app_theme.dart';
import 'package:lumina/src/features/reader/data/reader_scripts.dart';

class EpubTheme {
  final double zoom;
  final bool shouldOverrideTextColor;
  final ColorScheme colorScheme;
  final Color? overridePrimaryColor;
  final EdgeInsets padding;

  /// File name (with extension) of the custom font, or null for epub default.
  final String? fontFileName;

  /// When true, force the custom font on top of the epub's own font rules.
  final bool overrideFontFamily;

  /// Line height multiplier (1.0 to 2.5). Default is 1.5.
  final double lineHeight;

  /// Paragraph spacing multiplier (0.5 to 2.0). Default is 1.0.
  final double paragraphSpacing;

  EpubTheme({
    required this.zoom,
    required this.shouldOverrideTextColor,
    required this.colorScheme,
    this.overridePrimaryColor,
    required this.padding,
    this.fontFileName,
    this.overrideFontFamily = false,
    this.lineHeight = 1.5,
    this.paragraphSpacing = 1.0,
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
    double? lineHeight,
    double? paragraphSpacing,
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
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
    );
  }

  static const Object _kUnset = Object();

  Map<String, dynamic> toThemeMap() {
    return {
      'padding': {'top': padding.top, 'left': padding.left},
      'theme': {
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
        'surfaceContainerHighColor': colorToMap(
          colorScheme.surfaceContainerHigh,
        ),

        'fontFileName': fontFileName,
        'overrideFontFamily': overrideFontFamily,
        'lineHeight': lineHeight,
        'paragraphSpacing': paragraphSpacing,
      },
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
        other.lineHeight == lineHeight &&
        other.paragraphSpacing == paragraphSpacing;
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
    lineHeight,
    paragraphSpacing,
  );
}
