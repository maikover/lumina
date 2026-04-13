import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tts_service.dart';

/// Provider for TtsService
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});
