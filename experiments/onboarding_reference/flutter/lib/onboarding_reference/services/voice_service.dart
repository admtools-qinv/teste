abstract class VoiceService {
  Future<void> initialize();
  Future<void> speak(String text, {String? stepId});
  Future<void> stop();
  Future<void> dispose();

  /// Playback progress from 0.0 to 1.0. Empty stream if unsupported.
  Stream<double> get progressStream;
}

class NullVoiceService implements VoiceService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text, {String? stepId}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<double> get progressStream => const Stream.empty();
}
