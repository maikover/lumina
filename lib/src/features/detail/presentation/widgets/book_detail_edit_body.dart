import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/bauhaus_components.dart';
import '../../../library/domain/shelf_book.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../../../../l10n/app_localizations.dart';

/// Inline-editing form for a [ShelfBook] with Bauhaus styling.
/// Displays the cover (read-only) followed by editable fields for title,
/// authors, and description.
class BookDetailEditBody extends StatelessWidget {
  final ShelfBook book;
  final TextEditingController titleController;
  final TextEditingController authorsController;
  final TextEditingController descriptionController;

  /// Validation error message shown below the title field, or null when valid.
  final String? titleError;

  /// Called every time the title field value changes so the parent can
  /// update [titleError] in response.
  final ValueChanged<String> onTitleChanged;

  const BookDetailEditBody({
    super.key,
    required this.book,
    required this.titleController,
    required this.authorsController,
    required this.descriptionController,
    required this.titleError,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image — read-only with Bauhaus frame
            Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                transitionOnUserGestures: true,
                tag: 'book-cover-${book.id}',
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
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: BookCover(
                      relativePath: book.coverPath,
                      radius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title field - Bauhaus style
            _BauhausTextField(
              controller: titleController,
              label: l10n.title.toUpperCase(),
              errorText: titleError,
              onChanged: onTitleChanged,
              textInputAction: TextInputAction.next,
              maxLines: null,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
              ],
            ),

            const SizedBox(height: 16),

            // Authors field
            _BauhausTextField(
              controller: authorsController,
              label: l10n.authors.toUpperCase(),
              helperText: l10n.authorsTooltip,
              textInputAction: TextInputAction.next,
              maxLines: null,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
              ],
            ),

            const SizedBox(height: 16),

            // Description field
            _BauhausTextField(
              controller: descriptionController,
              label: l10n.bookDescription.toUpperCase(),
              minLines: 5,
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 128),
          ],
        ),
      ),
    );
  }
}

/// Bauhaus-styled text field
class _BauhausTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;

  const _BauhausTextField({
    this.controller,
    this.label,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.maxLines,
    this.minLines,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: errorText != null
                  ? BauhausColors.primaryRed
                  : BauhausColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: errorText != null
                  ? BauhausColors.primaryRed
                  : BauhausColors.border,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: textInputAction,
            maxLines: maxLines,
            minLines: minLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: BauhausColors.foreground,
            ),
            decoration: InputDecoration(
              helperText: helperText,
              helperStyle: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BauhausColors.foreground.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const BauhausSquare(
                color: BauhausColors.primaryRed,
                size: 8,
              ),
              const SizedBox(width: 6),
              Text(
                errorText!,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BauhausColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
