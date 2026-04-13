import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/src/features/reader/data/dictionary_service.dart';
import 'package:lumina/src/features/reader/data/dictionary_service_provider.dart';

/// Dictionary lookup overlay widget
class DictionaryOverlay extends ConsumerStatefulWidget {
  final String word;
  final VoidCallback onClose;

  const DictionaryOverlay({
    super.key,
    required this.word,
    required this.onClose,
  });

  @override
  ConsumerState<DictionaryOverlay> createState() => _DictionaryOverlayState();
}

class _DictionaryOverlayState extends ConsumerState<DictionaryOverlay> {
  @override
  Widget build(BuildContext context) {
    final lookupAsync = ref.watch(dictionaryLookupProvider(widget.word));
    final themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeData.colorScheme.surfaceContainer,
                border: Border(
                  bottom: BorderSide(
                    color: themeData.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.word,
                      style: themeData.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: lookupAsync.when(
                data: (definitions) => _buildDefinitionsList(definitions, themeData),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: themeData.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not find definition',
                        style: themeData.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: themeData.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionsList(List<WordDefinition> definitions, ThemeData themeData) {
    if (definitions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: themeData.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No definitions found',
              style: themeData.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The word "${widget.word}" was not found in the dictionary.',
              style: themeData.textTheme.bodySmall?.copyWith(
                color: themeData.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: definitions.length,
      itemBuilder: (context, index) {
        final definition = definitions[index];
        return _buildWordDefinition(definition, themeData);
      },
    );
  }

  Widget _buildWordDefinition(WordDefinition wordDef, ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word and phonetic
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              wordDef.word,
              style: themeData.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (wordDef.phonetic != null) ...[
              const SizedBox(width: 8),
              Text(
                wordDef.phonetic!,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Meanings
        for (final meaning in wordDef.meanings) ...[
          // Part of speech
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: themeData.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              meaning.partOfSpeech,
              style: themeData.textTheme.labelMedium?.copyWith(
                color: themeData.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Definitions
          for (int i = 0; i < meaning.definitions.length; i++) ...[
            _buildDefinitionItem(meaning.definitions[i], i + 1, themeData),
            if (i < meaning.definitions.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
        ],

        // Source
        if (wordDef.sourceUrl != null) ...[
          const Divider(),
          Row(
            children: [
              Icon(
                Icons.link,
                size: 14,
                color: themeData.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Source: ${wordDef.sourceUrl}',
                  style: themeData.textTheme.bodySmall?.copyWith(
                    color: themeData.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDefinitionItem(Definition def, int index, ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Definition number and text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$index. ',
                style: themeData.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  def.definition,
                  style: themeData.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          // Example
          if (def.example != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '"${def.example}"',
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Synonyms
          if (def.synonyms.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  Text(
                    'Synonyms:',
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  for (final syn in def.synonyms.take(5))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        syn,
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: themeData.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Antonyms
          if (def.antonyms.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  Text(
                    'Antonyms:',
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  for (final ant in def.antonyms.take(5))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ant,
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: themeData.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
