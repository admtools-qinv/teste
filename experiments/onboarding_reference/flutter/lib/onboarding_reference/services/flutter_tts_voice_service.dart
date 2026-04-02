import 'package:flutter_tts/flutter_tts.dart';

import 'voice_service.dart';

class FlutterTtsVoiceService implements VoiceService {
  final FlutterTts _tts;
  bool _configured = false;

  FlutterTtsVoiceService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  @override
  Future<void> initialize() async {
    if (_configured) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _configured = true;
  }

  @override
  Future<void> speak(String text) async {
    await initialize();
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
