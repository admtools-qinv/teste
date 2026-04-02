abstract class VoiceService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
}

class NullVoiceService implements VoiceService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}
