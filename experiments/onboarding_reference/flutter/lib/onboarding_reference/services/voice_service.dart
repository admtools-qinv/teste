abstract class VoiceService {
  Future<void> initialize();
  Future<void> speak(String text, {String? stepId});
  Future<void> stop();
  Future<void> dispose();

  /// Playback progress from 0.0 to 1.0. Empty stream if unsupported.
  Stream<double> get progressStream;

  /// Current playback position in milliseconds. Used for word-level karaoke sync.
  Stream<int> get positionMsStream;
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

  @override
  Stream<int> get positionMsStream => const Stream.empty();
}
