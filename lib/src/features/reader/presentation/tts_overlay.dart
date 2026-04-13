import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/src/features/reader/data/tts_service_provider.dart';

/// TTS (Text-to-Speech) controls overlay
class TtsOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String? currentText;

  const TtsOverlay({
    super.key,
    required this.onClose,
    this.currentText,
  });

  @override
  ConsumerState<TtsOverlay> createState() => _TtsOverlayState();
}

class _TtsOverlayState extends ConsumerState<TtsOverlay> {
  final TextEditingController _textController = TextEditingController();
  double _rate = 0.5;
  double _pitch = 1.0;
  bool _isSpeaking = false;
  List<String> _languages = [];
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.currentText ?? '';
    _initTts();
  }

  Future<void> _initTts() async {
    final tts = ref.read(ttsServiceProvider);
    await tts.initialize();

    tts.onSpeakStateChanged = (isSpeaking) {
      if (mounted) {
        setState(() {
          _isSpeaking = isSpeaking;
        });
      }
    };

    tts.onLanguagesChanged = (languages) {
      if (mounted) {
        setState(() {
          _languages = languages;
        });
      }
    };

    tts.onRateChanged = (rate) {
      if (mounted) {
        setState(() {
          _rate = rate;
        });
      }
    };

    tts.onPitchChanged = (pitch) {
      if (mounted) {
        setState(() {
          _pitch = pitch;
        });
      }
    };

    setState(() {
      _rate = tts.rate;
      _pitch = tts.pitch;
      _selectedLanguage = tts.currentLanguage;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      ref.read(ttsServiceProvider).stop();
                      widget.onClose();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Text to Speech',
                    style: themeData.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_isSpeaking)
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () {
                        ref.read(ttsServiceProvider).stop();
                      },
                      tooltip: 'Stop',
                    ),
                ],
              ),
            ),

            // Text input
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter text to speak...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Rate slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.speed_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text('Speed:'),
                  Expanded(
                    child: Slider(
                      value: _rate,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: (_rate * 100).round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _rate = value;
                        });
                        ref.read(ttsServiceProvider).setRate(value);
                      },
                    ),
                  ),
                  Text('${(_rate * 100).round()}%'),
                ],
              ),
            ),

            // Pitch slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.tune_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text('Pitch:'),
                  Expanded(
                    child: Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: _pitch.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _pitch = value;
                        });
                        ref.read(ttsServiceProvider).setPitch(value);
                      },
                    ),
                  ),
                  Text(_pitch.toStringAsFixed(1)),
                ],
              ),
            ),

            // Language dropdown
            if (_languages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.language_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text('Language:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        items: _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(
                              lang,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                            ref.read(ttsServiceProvider).setLanguage(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Speak button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isSpeaking ? 'Stop' : 'Speak'),
                  onPressed: () {
                    final tts = ref.read(ttsServiceProvider);
                    if (_isSpeaking) {
                      tts.stop();
                    } else if (_textController.text.isNotEmpty) {
                      tts.speak(_textController.text);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
