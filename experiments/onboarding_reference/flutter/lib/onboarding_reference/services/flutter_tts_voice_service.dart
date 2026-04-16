import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'voice_service.dart';

class FlutterTtsVoiceService implements VoiceService {
  final FlutterTts _tts;
  bool _configured = false;
  bool _unsupported = false;

  FlutterTtsVoiceService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  @override
  Future<void> initialize() async {
    if (_configured || _unsupported) return;
    try {
      await _tts.setLanguage('en-US');
      final voices = await _tts.getVoices as List?;
      if (voices != null) {
        final enVoice = voices
            .whereType<Map>()
            .where((v) =>
                (v['locale'] as String?)?.toLowerCase().startsWith('en') == true)
            .firstOrNull;
        if (enVoice != null) {
          await _tts.setVoice({
            'name': enVoice['name'] as String,
            'locale': enVoice['locale'] as String,
          });
        }
      }
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _configured = true;
    } on MissingPluginException {
      _unsupported = true;
    }
  }

  @override
  Future<void> speak(String text, {String? stepId}) async {
    await initialize();
    if (_unsupported) return;
    try {
      await _tts.stop();
    } catch (_) {}
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    if (_unsupported) return;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {}

  @override
  Stream<double> get progressStream => const Stream.empty();

  @override
  Stream<int> get positionMsStream => const Stream.empty();
}
