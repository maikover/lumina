part of '../reader_screen.dart';

/// Mixin for handling text selection (highlight creation)
mixin _TextSelectionMixin on ConsumerState<ReaderScreen> {
  // State fields that need to be defined in the main class
  BookSession get bookSession;
  bool get showControls;
  bool get isTextSelectionVisible;
  set isTextSelectionVisible(bool v);
  String? get selectedText;
  set selectedText(String? v);

  /// Handle text selection from the webview
  void handleTextSelected(String text) {
    if (!bookSession.isLoaded) return;
    if (showControls) return;

    if (text.isNotEmpty) {
      setState(() {
        selectedText = text;
        isTextSelectionVisible = true;
      });
    }
  }

  /// Clear the current selection
  void clearTextSelection() {
    setState(() {
      selectedText = null;
      isTextSelectionVisible = false;
    });
  }
}
