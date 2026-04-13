part of '../reader_screen.dart';

/// Mixin for handling dictionary lookup functionality
mixin _DictionaryMixin on ConsumerState<ReaderScreen> {
  // State fields that need to be defined in the main class
  BookSession get bookSession;

  /// Whether dictionary overlay is visible
  bool _isDictionaryOverlayVisible = false;
  bool get isDictionaryOverlayVisible => _isDictionaryOverlayVisible;

  /// Current word being looked up
  String? _dictionaryCurrentWord;
  String? get dictionaryCurrentWord => _dictionaryCurrentWord;

  /// Show dictionary overlay for a word
  void showDictionaryOverlay(String word) {
    if (!bookSession.isLoaded) return;

    setState(() {
      _isDictionaryOverlayVisible = true;
      _dictionaryCurrentWord = word;
    });
  }

  /// Hide dictionary overlay
  void hideDictionaryOverlay() {
    setState(() {
      _isDictionaryOverlayVisible = false;
      _dictionaryCurrentWord = null;
    });
  }
}
