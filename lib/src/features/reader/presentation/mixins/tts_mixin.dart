part of '../reader_screen.dart';

/// Mixin for handling Text-to-Speech functionality
mixin _TtsMixin on ConsumerState<ReaderScreen> {
  // State fields that need to be defined in the main class
  BookSession get bookSession;

  /// Whether TTS overlay is visible
  bool _isTtsOverlayVisible = false;
  bool get isTtsOverlayVisible => _isTtsOverlayVisible;

  /// Current selected text for TTS
  String? _ttsCurrentText;
  String? get ttsCurrentText => _ttsCurrentText;

  /// Show TTS overlay
  void showTtsOverlay() {
    if (!bookSession.isLoaded) return;

    setState(() {
      _isTtsOverlayVisible = true;
      _ttsCurrentText = selectedText;
    });
  }

  /// Hide TTS overlay
  void hideTtsOverlay() {
    setState(() {
      _isTtsOverlayVisible = false;
    });
  }
}
