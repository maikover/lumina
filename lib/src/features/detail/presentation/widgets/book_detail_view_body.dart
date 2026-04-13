import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lumina/src/core/services/toast_service.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/bauhaus_components.dart';
import 'package:lumina/src/features/detail/presentation/book_detail_screen.dart';
import '../../../library/domain/shelf_book.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../../../l10n/app_localizations.dart';

/// Read-only detail view for a single [ShelfBook] with Bauhaus styling.
/// Displays cover, title, authors, description, reading progress, metadata
/// chips, and a read/continue button.
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
      final filePath = widget.book.filePath;
      final isPdf = filePath != null &&
          (filePath.toLowerCase().endsWith('.pdf') ||
           filePath.toLowerCase().endsWith('.pdfrx'));

      if (isPdf) {
        final encodedTitle = Uri.encodeComponent(widget.book.title);
        context.push(
          '/read/${Uri.encodeComponent(filePath!)}?pdf=true&title=$encodedTitle',
        ).then((_) {
          ref.invalidate(bookDetailProvider(widget.bookId));
        });
      } else {
        context.push('/read/${widget.book.fileHash}').then((_) {
          ref.invalidate(bookDetailProvider(widget.bookId));
        });
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover with geometric frame - Bauhaus style
            Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                tag: 'book-cover-${widget.book.id}',
                child: GestureDetector(
                  onTap: navigateToReader,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: 0,
                          color: BauhausColors.border,
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: BookCover(
                        relativePath: widget.book.coverPath,
                        radius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title - Bauhaus style
            Text(
              widget.book.title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: BauhausColors.foreground,
              ),
              textAlign: TextAlign.left,
            ),

            // Authors
            if (widget.book.authors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.book.authors.join(l10n.spliter),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: BauhausColors.foreground.withValues(alpha: 0.7),
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
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: BauhausColors.foreground,
                  height: 1.6,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Reading progress - Bauhaus card style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: BauhausColors.border,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 0,
                    color: BauhausColors.border,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BauhausSquare(
                    color: BauhausColors.primaryYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.book.readingProgress > 0
                        ? l10n.progressPercent(progressPercent)
                        : l10n.notStarted,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: BauhausColors.foreground,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metadata chips - Bauhaus style
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                _BauhausMetadataChip(label: l10n.chaptersCount(widget.book.totalChapters)),
                _BauhausMetadataChip(label: l10n.epubVersion(widget.book.epubVersion)),
                _BauhausMetadataChip(label: directionToString(widget.book.direction)),
              ],
            ),

            const SizedBox(height: 40),

            // Read / Continue reading button - Bauhaus style
            SizedBox(
              width: double.infinity,
              child: BauhausButton(
                label: widget.book.readingProgress > 0
                    ? l10n.continueReading
                    : l10n.startReading,
                onPressed: navigateToReader,
                variant: BauhausButtonVariant.primary,
                icon: widget.book.readingProgress > 0
                    ? Icons.play_arrow_outlined
                    : Icons.menu_book_outlined,
              ),
            ),

            // Export annotations button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: BauhausButton(
                label: l10n.exportAnnotations,
                onPressed: () {
                  _showExportDialog(context, widget.book);
                },
                variant: BauhausButtonVariant.outline,
                icon: Icons.download_outlined,
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
      builder: (dialogContext) => Container(
        decoration: const BoxDecoration(
          color: BauhausColors.background,
          border: Border(
            top: BorderSide(
              color: BauhausColors.border,
              width: 4,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const BauhausSquare(
                  color: BauhausColors.primaryRed,
                  size: 20,
                ),
                title: Text(
                  l10n.exportAsTxt.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _exportAnnotations(context, book, 'txt');
                },
              ),
              ListTile(
                leading: const BauhausSquare(
                  color: BauhausColors.primaryBlue,
                  size: 20,
                ),
                title: Text(
                  l10n.exportAsMd.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _exportAnnotations(context, book, 'md');
                },
              ),
              ListTile(
                leading: const BauhausSquare(
                  color: BauhausColors.primaryYellow,
                  size: 20,
                ),
                title: Text(
                  l10n.exportAsJson.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _exportAnnotations(context, book, 'json');
                },
              ),
            ],
          ),
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

|**Authors:** ${book.authors.join(', ')}
|**Exported:** ${DateTime.now().toString().split('.').first}
|**Reading Progress:** ${(book.readingProgress * 100).toStringAsFixed(1)}%

---

## Notes

(No annotations yet)

---
*Exported from Lectra Reader*
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
Exported from Lectra Reader
''';
  }
}

/// Bauhaus-style metadata chip
class _BauhausMetadataChip extends StatelessWidget {
  final String label;

  const _BauhausMetadataChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: BauhausColors.border,
          width: 2,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: BauhausColors.foreground,
        ),
      ),
    );
  }
}
