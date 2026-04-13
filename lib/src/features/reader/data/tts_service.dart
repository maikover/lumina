import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for reading book content aloud
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isSpeaking = false;

  // Callbacks
  Function(bool isSpeaking)? onSpeakStateChanged;
  Function(double rate)? onRateChanged;
  Function(double pitch)? onPitchChanged;
  Function(List<String> languages)? onLanguagesChanged;
  Function(String? currentWord)? onProgress;

  double _rate = 0.5;
  double _pitch = 1.0;
  String? _currentLanguage;

  // Getters
  bool get isSpeaking => _isSpeaking;
  double get rate => _rate;
  double get pitch => _pitch;
  String? get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakStateChanged?.call(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakStateChanged?.call(false);
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        onSpeakStateChanged?.call(false);
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('TTS Error: $message');
        _isSpeaking = false;
        onSpeakStateChanged?.call(false);
      });

      _flutterTts.setContinueHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        onProgress?.call(word);
      });

      // Get available languages
      final languages = await _flutterTts.getLanguages;
      if (languages != null) {
        onLanguagesChanged?.call(List<String>.from(languages));
      }

      // Set default values
      await _flutterTts.setSpeechRate(_rate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(1.0);

      // Set iOS specifics
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Start speaking the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    await _flutterTts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    onSpeakStateChanged?.call(false);
  }

  /// Pause speaking
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_rate);
    onRateChanged?.call(_rate);
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
    onPitchChanged?.call(_pitch);
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _flutterTts.setLanguage(language);
  }

  /// Get available languages
  Future<List<String>> getLanguages() async {
    final languages = await _flutterTts.getLanguages;
    if (languages != null) {
      return List<String>.from(languages);
    }
    return [];
  }

  /// Dispose the TTS engine
  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
  }
}
