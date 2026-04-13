import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lumina/src/core/services/toast_service.dart';
import 'package:lumina/src/features/detail/presentation/book_detail_screen.dart';
import '../../../library/domain/shelf_book.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../../../l10n/app_localizations.dart';

/// Read-only detail view for a single [ShelfBook].
///
/// Displays cover, title, authors, description, reading progress, metadata
/// chips, and a read/continue button. Tapping the cover or the button
/// navigates to the reader and then invalidates [bookDetailProvider].
class BookDetailViewBody extends ConsumerStatefulWidget {
  final ShelfBook book;
  final String bookId;

  const BookDetailViewBody({
    super.key,
    required this.book,
    required this.bookId,
  });

  @override
  ConsumerState<BookDetailViewBody> createState() => _BookDetailViewBodyState();
}

class _BookDetailViewBodyState extends ConsumerState<BookDetailViewBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressPercent = (widget.book.readingProgress * 100).toStringAsFixed(2);

    void navigateToReader() {
      context.push('/read/${widget.book.fileHash}').then((_) {
        ref.invalidate(bookDetailProvider(widget.bookId));
      });
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover with Hero animation — tapping opens the reader.
            Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                tag: 'book-cover-${widget.book.id}',
                child: GestureDetector(
                  onTap: navigateToReader,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: BookCover(
                      relativePath: widget.book.coverPath,
                      radius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              widget.book.title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.left,
            ),

            // Authors
            if (widget.book.authors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.book.authors.join(l10n.spliter),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ],

            // Description
            if (widget.book.description != null && widget.book.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              ExpandableText(
                text: _extract(widget.book.description),
                maxLines: 4,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],

            const SizedBox(height: 32),

            // Reading progress badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.book.readingProgress > 0
                        ? l10n.progressPercent(progressPercent)
                        : l10n.notStarted,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metadata chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                _MetadataChip(label: l10n.chaptersCount(widget.book.totalChapters)),
                _MetadataChip(label: l10n.epubVersion(widget.book.epubVersion)),
                _MetadataChip(label: directionToString(widget.book.direction)),
              ],
            ),

            const SizedBox(height: 40),

            // Read / Continue reading button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: navigateToReader,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(
                  widget.book.readingProgress > 0
                      ? l10n.continueReading
                      : l10n.startReading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

            // Export annotations button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showExportDialog(context, widget.book);
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(l10n.exportAnnotations),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 128),
          ],
        ),
      ),
    );
  }

  static String _extract(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) {
      return '';
    }

    String text = htmlContent;

    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(
      RegExp(r'</(p|div|h[1-6]|tr|blockquote)>', caseSensitive: false),
      '\n\n',
    );

    text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');

    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');

    return text.trim();
  }

  void _showExportDialog(BuildContext context, ShelfBook book) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.exportAsTxt),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportAnnotations(context, book, 'txt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.exportAsMd),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportAnnotations(context, book, 'md');
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object_outlined),
              title: Text(l10n.exportAsJson),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportAnnotations(context, book, 'json');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAnnotations(
    BuildContext context,
    ShelfBook book,
    String format,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${book.title.replaceAll(RegExp(r'[^\w\s-]'), '')}_annotations.$format';
      final file = File('${directory.path}/$fileName');

      String content;
      if (format == 'json') {
        content = _generateJsonExport(book);
      } else if (format == 'md') {
        content = _generateMarkdownExport(book);
      } else {
        content = _generateTextExport(book);
      }

      await file.writeAsString(content);

      if (context.mounted) {
        ToastService.showSuccess(l10n.exportSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(l10n.exportError);
      }
    }
  }

  String _generateJsonExport(ShelfBook book) {
    final authorsList = book.authors.map((a) => '"$a"').toList();
    return '''{
  "title": "${book.title}",
  "authors": [$authorsList],
  "exportedAt": "${DateTime.now().toIso8601String()}",
  "progress": ${book.readingProgress},
  "annotations": []
}''';
  }

  String _generateMarkdownExport(ShelfBook book) {
    return '''# Annotations from "${book.title}"

**Authors:** ${book.authors.join(', ')}
**Exported:** ${DateTime.now().toString().split('.').first}
**Reading Progress:** ${(book.readingProgress * 100).toStringAsFixed(1)}%

---

## Notes

(No annotations yet)

---
*Exported from Lumina Reader*
''';
  }

  String _generateTextExport(ShelfBook book) {
    return '''Annotations from: ${book.title}
Authors: ${book.authors.join(', ')}
Exported: ${DateTime.now().toString().split('.').first}
Progress: ${(book.readingProgress * 100).toStringAsFixed(1)}%

---

Notes:
(No annotations yet)

---
Exported from Lumina Reader
''';
  }
}

/// Small outlined chip used to display a single piece of book metadata.
class _MetadataChip extends StatelessWidget {
  final String label;

  const _MetadataChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
