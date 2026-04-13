import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:lumina/src/core/database/providers.dart';
import 'highlight_repository.dart';

/// Provider for HighlightRepository
final highlightRepositoryProvider = Provider<HighlightRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => HighlightRepository(isar: isar),
    loading: () => throw StateError(
      'Database is still initializing. '
      'Ensure the app awaits database initialization before accessing repositories.',
    ),
    error: (e, stack) => Error.throwWithStackTrace(
      StateError('Database initialization failed: $e'),
      stack,
    ),
  );
});
