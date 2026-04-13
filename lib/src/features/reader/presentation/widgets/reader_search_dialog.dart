import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/l10n/app_localizations.dart';

/// In-reader search dialog that allows finding text within the book
class ReaderSearchDialog extends ConsumerStatefulWidget {
  final Function(String query) onSearch;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int resultCount;
  final int currentIndex;
  final VoidCallback onClose;

  const ReaderSearchDialog({
    super.key,
    required this.onSearch,
    required this.onNext,
    required this.onPrevious,
    required this.resultCount,
    required this.currentIndex,
    required this.onClose,
  });

  @override
  ConsumerState<ReaderSearchDialog> createState() => _ReaderSearchDialogState();
}

class _ReaderSearchDialogState extends ConsumerState<ReaderSearchDialog> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);

    return Dialog(
      backgroundColor: themeData.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: themeData.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.searchInBook,
                    style: themeData.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search input
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => widget.onSearch(_controller.text),
                ),
              ),
              onSubmitted: widget.onSearch,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 12),

            // Results info
            if (_controller.text.isNotEmpty)
              Text(
                widget.resultCount > 0
                    ? l10n.searchResultsCount(widget.resultCount)
                    : l10n.searchNoResults,
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: widget.resultCount > 0 ? widget.onPrevious : null,
                  icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                  label: Text(l10n.searchPrevious),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: widget.resultCount > 0 ? widget.onNext : null,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  label: Text(l10n.searchNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}