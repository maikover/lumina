import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dictionary_service.dart';

/// Provider for DictionaryService
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  final service = DictionaryService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for word lookup result
final dictionaryLookupProvider = FutureProvider.family<List<WordDefinition>, String>(
  (ref, word) async {
    final service = ref.read(dictionaryServiceProvider);
    return service.lookup(word);
  },
);
