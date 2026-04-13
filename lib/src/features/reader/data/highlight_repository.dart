import 'dart:convert';

import 'package:isar/isar.dart';
import '../domain/highlight.dart';

/// Repository for Highlight CRUD operations
class HighlightRepository {
  final Isar _isar;

  HighlightRepository({required Isar isar}) : _isar = isar;

  /// Get all highlights for a book (excluding deleted)
  Future<List<Highlight>> getHighlightsForBook(String fileHash) async {
    return await _isar.highlights
        .filter()
        .fileHashEqualTo(fileHash)
        .isDeletedEqualTo(false)
        .sortByChapterIndex()
        .thenByStartOffset()
        .findAll();
  }

  /// Get highlights for a specific chapter
  Future<List<Highlight>> getHighlightsForChapter(
    String fileHash,
    int chapterIndex,
  ) async {
    return await _isar.highlights
        .filter()
        .fileHashEqualTo(fileHash)
        .chapterIndexEqualTo(chapterIndex)
        .isDeletedEqualTo(false)
        .sortByStartOffset()
        .findAll();
  }

  /// Add a new highlight
  Future<Highlight> addHighlight({
    required String fileHash,
    required int chapterIndex,
    required int startOffset,
    required int endOffset,
    required String text,
    required String color,
    String? note,
    String type = 'highlight',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final highlight = Highlight()
      ..fileHash = fileHash
      ..chapterIndex = chapterIndex
      ..startOffset = startOffset
      ..endOffset = endOffset
      ..text = text
      ..color = color
      ..note = note
      ..type = type
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = false;

    await _isar.writeTxn(() async {
      await _isar.highlights.put(highlight);
    });

    return highlight;
  }

  /// Update an existing highlight
  Future<void> updateHighlight({
    required int id,
    String? color,
    String? note,
  }) async {
    await _isar.writeTxn(() async {
      final highlight = await _isar.highlights.get(id);
      if (highlight != null) {
        if (color != null) highlight.color = color;
        if (note != null) highlight.note = note;
        highlight.updatedAt = DateTime.now().millisecondsSinceEpoch;
        await _isar.highlights.put(highlight);
      }
    });
  }

  /// Soft delete a highlight
  Future<void> deleteHighlight(int id) async {
    await _isar.writeTxn(() async {
      final highlight = await _isar.highlights.get(id);
      if (highlight != null) {
        highlight.isDeleted = true;
        highlight.updatedAt = DateTime.now().millisecondsSinceEpoch;
        await _isar.highlights.put(highlight);
      }
    });
  }

  /// Hard delete a highlight (permanent)
  Future<void> permanentlyDeleteHighlight(int id) async {
    await _isar.writeTxn(() async {
      await _isar.highlights.delete(id);
    });
  }

  /// Export all highlights for a book as JSON
  Future<String> exportHighlightsAsJson(String fileHash) async {
    final highlights = await getHighlightsForBook(fileHash);
    final data = highlights
        .map((h) => {
              'text': h.text,
              'chapterIndex': h.chapterIndex,
              'color': h.color,
              'note': h.note,
              'createdAt': h.createdAt,
            })
        .toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export all highlights for a book as Markdown
  Future<String> exportHighlightsAsMarkdown(
    String fileHash, {
    String? bookTitle,
  }) async {
    final highlights = await getHighlightsForBook(fileHash);
    final buffer = StringBuffer();

    if (bookTitle != null) {
      buffer.writeln('# Highlights from "$bookTitle"');
    } else {
      buffer.writeln('# Book Highlights');
    }
    buffer.writeln();

    int currentChapter = -1;
    for (final h in highlights) {
      if (h.chapterIndex != currentChapter) {
        currentChapter = h.chapterIndex;
        buffer.writeln('## Chapter $currentChapter');
        buffer.writeln();
      }

      final colorLabel = _colorToLabel(h.color);
      buffer.writeln('> ${h.text}');
      if (h.note != null && h.note!.isNotEmpty) {
        buffer.writeln('> **Note:** ${h.note}');
      }
      buffer.writeln('> *[$colorLabel]*');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _colorToLabel(String hex) {
    switch (hex.toUpperCase()) {
      case '#FFFF00':
        return 'Yellow';
      case '#90EE90':
        return 'Green';
      case '#ADD8E6':
        return 'Blue';
      case '#FFB6C1':
        return 'Pink';
      case '#FFA500':
        return 'Orange';
      case '#DDA0DD':
        return 'Purple';
      default:
        return 'Highlight';
    }
  }
}
