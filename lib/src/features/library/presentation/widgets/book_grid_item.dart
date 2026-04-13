import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/middle_ellipsis_two_lines_text.dart';
import '../../domain/shelf_book.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../application/bookshelf_notifier.dart';

/// Book grid item widget with Bauhaus design styling.
/// Displays a single book in the grid with geometric accents.
class BookGridItem extends ConsumerWidget {
  final ShelfBook book;
  final bool isSelectionMode;
  final bool isSelected;
  final ViewMode viewMode;
  final VoidCallback? onLongPress;

  const BookGridItem({
    super.key,
    required this.book,
    required this.isSelectionMode,
    required this.isSelected,
    required this.viewMode,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _handleTap(context, ref),
      onLongPress: onLongPress,

      child: Stack(
        children: [
          // Main mode-specific layout
          switch (viewMode) {
            ViewMode.relaxed => _buildRelaxed(context),
            ViewMode.compact => Positioned.fill(child: _buildCompact(context)),
          },

          // Selection indicator (top-left, all modes)
          if (isSelectionMode)
            Positioned(
              top: 8,
              left: 8,
              child: _buildCheckbox(context),
            ),
        ],
      ),
    );
  }

  /// Relaxed: cover + title + author + progress bar.
  Widget _buildRelaxed(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCoverStack(context, fit: StackFit.expand)),
        const SizedBox(height: 12),
        MiddleEllipsisTwoLinesText(
          book.title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: BauhausColors.foreground,
          ),
        ),
        const SizedBox(height: 4),
        if (book.author.isNotEmpty)
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: BauhausColors.foreground.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (book.readingProgress > 0 && !book.isDeleted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: BauhausColors.muted,
                border: Border.all(
                  color: BauhausColors.border,
                  width: 1,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: book.readingProgress,
                child: Container(
                  color: BauhausColors.primaryYellow,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Compact: cover only, geometric overlay + progress badge.
  Widget _buildCompact(BuildContext context) {
    return _buildCoverStack(
      context,
      fit: StackFit.expand,
      extras: [
        // Bottom geometric bar with title
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 24, 6, 6),
            decoration: const BoxDecoration(
              color: BauhausColors.foreground,
            ),
            child: MiddleEllipsisTwoLinesText(
              book.title,
              style: GoogleFonts.outfit(
                color: BauhausColors.background,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
            ),
          ),
        ),
        // Geometric accent (top-right)
        _buildProgressBadge(context),
      ],
    );
  }

  Widget _buildCoverStack(
    BuildContext context, {
    List<Widget> extras = const [],
    StackFit fit = StackFit.loose,
  }) {
    final maskAndExtras = Stack(
      fit: StackFit.expand,
      children: [
        // Selection color overlay
        if (isSelectionMode)
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? BauhausColors.primaryBlue.withValues(alpha: 0.3)
                  : BauhausColors.foreground.withValues(alpha: 0.1),
              border: isSelected
                  ? Border.all(
                      color: BauhausColors.primaryBlue,
                      width: 3,
                    )
                  : null,
            ),
          ),
        ...extras,
      ],
    );

    return Hero(
      transitionOnUserGestures: true,
      tag: 'book-cover-${book.id}',
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final bool isPush = flightDirection == HeroFlightDirection.push;
        final RenderBox? libraryBox =
            (isPush ? fromHeroContext : toHeroContext).findRenderObject()
                as RenderBox?;
        final RenderBox? detailBox =
            (isPush ? toHeroContext : fromHeroContext).findRenderObject()
                as RenderBox?;

        final Rect libraryRect = libraryBox != null
            ? (libraryBox.localToGlobal(Offset.zero) & libraryBox.size)
            : Rect.zero;
        final Rect detailRect = detailBox != null
            ? (detailBox.localToGlobal(Offset.zero) & detailBox.size)
            : Rect.zero;

        final RectTween trajectoryTween = RectTween(
          begin: libraryRect,
          end: detailRect,
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final libraryOpacity = (1.0 - animation.value).clamp(0.0, 1.0);

            final currentRect =
                trajectoryTween.evaluate(animation) ?? Rect.zero;
            final double statusBarHeight = MediaQuery.paddingOf(
              flightContext,
            ).top;
            final double libraryAppBarBottom =
                statusBarHeight + kToolbarHeight + 48.0;
            final double detailAppBarBottom = statusBarHeight + kToolbarHeight;

            final double currentGlobalY = currentRect.top;

            final double currentCeilingY =
                libraryAppBarBottom +
                (detailAppBarBottom - libraryAppBarBottom) *
                    animation.value;

            final double clipAmount = (currentCeilingY - currentGlobalY)
                .clamp(0.0, double.infinity);

            final contentWidget = Stack(
              fit: StackFit.expand,
              children: [
                BookCover(
                  relativePath: book.coverPath,
                  radius: BorderRadius.zero,
                ),
                Opacity(
                  opacity: libraryOpacity,
                  child: Material(
                    type: MaterialType.transparency,
                    child: maskAndExtras,
                  ),
                ),
              ],
            );

            return ClipRect(
              clipper: _TopClipper(clipAmount),
              child: contentWidget,
            );
          },
        );
      },
      child: Stack(
        fit: fit,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: BauhausColors.border,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(4, 4),
                  blurRadius: 0,
                  color: BauhausColors.border,
                ),
              ],
            ),
            child: BookCover(
              relativePath: book.coverPath,
              radius: BorderRadius.zero,
            ),
          ),
          Positioned.fill(child: maskAndExtras),
        ],
      ),
    );
  }

  /// Progress percentage badge - Bauhaus style
  Widget _buildProgressBadge(BuildContext context) {
    if (book.readingProgress <= 0 || book.isFinished || isSelectionMode) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: BauhausColors.primaryYellow,
          border: Border.all(
            color: BauhausColors.border,
            width: 2,
          ),
        ),
        child: Text(
          '${(book.readingProgress * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.outfit(
            color: BauhausColors.foreground,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: isSelected
            ? BauhausColors.primaryBlue
            : Colors.white,
        border: Border.all(
          color: BauhausColors.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (isSelectionMode) {
      ref.read(bookshelfNotifierProvider.notifier).toggleItemSelection(book);
    } else {
      final notifier = ref.read(bookshelfNotifierProvider.notifier);
      context.push('/book/${book.fileHash}', extra: book).then((_) {
        notifier.reloadQuietly();
      });
    }
  }
}

class _TopClipper extends CustomClipper<Rect> {
  final double clipAmount;

  _TopClipper(this.clipAmount);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, clipAmount, size.width, size.height);
  }

  @override
  bool shouldReclip(_TopClipper oldClipper) =>
      oldClipper.clipAmount != clipAmount;
}
