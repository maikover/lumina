import 'package:isar/isar.dart';

part 'highlight.g.dart';

/// Isar collection for storing text highlights/annotations
@collection
class Highlight {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// SHA-256 hash of the EPUB file
  @Index()
  late String fileHash;

  /// Spine/chapter index where the highlight starts
  @Index()
  late int chapterIndex;

  /// Character offset within the chapter where highlight starts
  late int startOffset;

  /// Character offset within the chapter where highlight ends
  late int endOffset;

  /// The actual highlighted text content
  late String text;

  /// Optional note added by user
  String? note;

  /// Highlight color (stored as hex string, e.g., "#FFFF00" for yellow)
  @Index()
  late String color;

  /// Creation timestamp (milliseconds since epoch)
  @Index()
  late int createdAt;

  /// Last modification timestamp (milliseconds since epoch)
  late int updatedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  /// Highlight type: 'highlight' or 'note'
  late String type;
}

/// Predefined highlight colors
class HighlightColors {
  static const String yellow = '#FFFF00';
  static const String green = '#90EE90';
  static const String blue = '#ADD8E6';
  static const String pink = '#FFB6C1';
  static const String orange = '#FFA500';
  static const String purple = '#DDA0DD';

  static const List<String> all = [yellow, green, blue, pink, orange, purple];
}
