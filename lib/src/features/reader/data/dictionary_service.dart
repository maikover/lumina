import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Word definition from the Free Dictionary API
class WordDefinition {
  final String word;
  final String? phonetic;
  final List<Meaning> meanings;
  final String? sourceUrl;

  WordDefinition({
    required this.word,
    this.phonetic,
    required this.meanings,
    this.sourceUrl,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      word: json['word'] ?? '',
      phonetic: json['phonetic'],
      meanings: (json['meanings'] as List<dynamic>?)
              ?.map((m) => Meaning.fromJson(m))
              .toList() ??
          [],
      sourceUrl: json['sourceUrls']?.isNotEmpty == true
          ? json['sourceUrls'][0]
          : null,
    );
  }
}

/// Part of speech and its definitions
class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final String? phonetic;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    this.phonetic,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromJson(d))
              .toList() ??
          [],
      phonetic: json['phonetic'],
    );
  }
}

/// A single definition with optional example
class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}

/// Dictionary lookup error
class DictionaryException implements Exception {
  final String message;
  final int? statusCode;

  DictionaryException(this.message, [this.statusCode]);

  @override
  String toString() => 'DictionaryException: $message';
}

/// Service for looking up word definitions using the Free Dictionary API
class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  final http.Client _client;

  DictionaryService({http.Client? client}) : _client = client ?? http.Client();

  /// Look up a word in the dictionary
  /// Returns a list of definitions (usually one entry per dialect, but English usually returns one)
  Future<List<WordDefinition>> lookup(String word) async {
    if (word.trim().isEmpty) {
      throw DictionaryException('Word cannot be empty');
    }

    final encodedWord = Uri.encodeComponent(word.trim().toLowerCase());
    final url = '$_baseUrl/$encodedWord';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => WordDefinition.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Word not found - return empty list, not an error
        return [];
      } else {
        throw DictionaryException(
          'Failed to look up word: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('Network error looking up word: $e');
      throw DictionaryException('Network error: ${e.message}');
    } catch (e) {
      if (e is DictionaryException) rethrow;
      debugPrint('Error looking up word: $e');
      throw DictionaryException('Failed to look up word: $e');
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
